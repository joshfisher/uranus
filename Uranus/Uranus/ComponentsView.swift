import Foundation
import Mars

public class ComponentsView: UIView {
    private static let AnimationDuration: NSTimeInterval = 0.33
    
    private var views: [UIView] = []
    private var specification: LayoutSpecification?
    
    public override required init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() -> () {
        super.layoutSubviews()
        if let specification = specification {
            let frames = specification.internalFramesBlock(constrainedToSize: bounds.size)
            let layoutDirection = userInterfaceLayoutDirection()
            for (view, frame) in views.zip(frames) {
                view.frame = layoutDirectionAdjustedLayoutForFrame(frame, layoutDirection: layoutDirection)
            }
        }
    }
    
    internal func configureWithLayoutSpecification(layoutSpecification: LayoutSpecification) {
        configureWithLayoutSpecification(layoutSpecification, animated: false)
    }
    
    internal func configureWithLayoutSpecification(layoutSpecification: LayoutSpecification, animated: Bool) {
        if animated {
            configureWithLayoutSpecificationAnimated(layoutSpecification)
        }
        else {
            configureWithLayoutSpecificationWithoutAnimation(layoutSpecification)
        }
    }
    
    internal func configureWithLayoutSpecificationWithoutAnimation(layoutSpecification: LayoutSpecification) {
        specification = layoutSpecification
        
        let components = componentSpecificationsForSpecifications(layoutSpecification.internalSpecificationsBlock())
        if viewNeedsToBeResetForComponentSpecifications(components) {
            for view in views {
                view.removeFromSuperview()
            }
            views.removeAll(keepCapacity: true)
            
            for component in components {
                let view = component.internalViewCreationBlock()
                addSubview(view)
                views.append(view)
            }
        }
        
        for (view, component) in views.zip(components) {
            component.internalConfigurationBlock(view: view)
        }
    }
    
    internal func configureWithLayoutSpecificationAnimated(layoutSpecification: LayoutSpecification) {
        let oldComponents = componentSpecificationsForSpecifications(specification?.internalSpecificationsBlock() ?? [])
        let newComponents = componentSpecificationsForSpecifications(layoutSpecification.internalSpecificationsBlock())
        
        specification = layoutSpecification
        
        let oldIndexToNewIndex = matchingComponentIndexLookupForComponents(oldComponents, destination: newComponents)
        
        var removedViews: [UIView] = []
        var reusedViews: [Int: UIView] = [:]
        var newViews: [Int: UIView] = [:]
        
        for (index, view) in views.enumerate() {
            if let newIndex = oldIndexToNewIndex[index] {
                reusedViews[newIndex] = view
            }
            else {
                removedViews.append(view)
            }
        }
        
        views.removeAll(keepCapacity: true)
        
        for (index, component) in newComponents.enumerate() {
            if let view = reusedViews[index] {
                views.append(view)
            }
            else {
                let view = component.internalViewCreationBlock()
                addSubview(view)
                views.append(view)
                newViews[index] = view
            }
        }
        
        let layoutDirection = userInterfaceLayoutDirection()
        let frames = layoutSpecification.internalFramesBlock(constrainedToSize: bounds.size)
        
        for (index, view) in newViews {
            let component = newComponents[index]
            component.internalConfigurationBlock(view: view)
            view.frame = layoutDirectionAdjustedLayoutForFrame(frames[index], layoutDirection: layoutDirection)
            view.alpha = 0.0
        }
        
        UIView.animateWithDuration(ComponentsView.AnimationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            for (index, view) in reusedViews {
                let component = newComponents[index]
                component.internalConfigurationBlock(view: view)
                view.frame = self.layoutDirectionAdjustedLayoutForFrame(frames[index], layoutDirection: layoutDirection)
            }
            
            for (_, view) in newViews {
                view.alpha = 1.0
            }
            
            for view in removedViews {
                view.alpha = 0.0
            }
        }, completion: {(finished) in
            for view in removedViews {
                view.removeFromSuperview()
            }
        })
    }
    
    public func configureWithLayout<LayoutType: Layout where LayoutType.ArrangingType.ModelType == LayoutType>(layout: LayoutType) {
        configureWithLayoutSpecification(LayoutSpecification(model: layout, arrangingClass: LayoutType.ArrangingType.self))
    }
    
    public func configureWithLayout<LayoutType: Layout where LayoutType.ArrangingType.ModelType == LayoutType>(layout: LayoutType, animated: Bool) {
        configureWithLayoutSpecification(LayoutSpecification(model: layout, arrangingClass: LayoutType.ArrangingType.self), animated: animated)
    }
    
    internal static func sizeForLayoutSpecification(layoutSpecification: LayoutSpecification, constrainedToSize: CGSize) -> CGSize {
        return layoutSpecification.internalSizingBlock(constrainedToSize: constrainedToSize)
    }
    
    public static func sizeForLayout<LayoutType: Layout where LayoutType.ArrangingType.ModelType == LayoutType>(layout: LayoutType, constrainedToSize: CGSize) -> CGSize {
        return sizeForLayoutSpecification(LayoutSpecification(model: layout, arrangingClass: LayoutType.ArrangingType.self), constrainedToSize: constrainedToSize)
    }
    
    // MARK: Layout
    
    private func userInterfaceLayoutDirection() -> UIUserInterfaceLayoutDirection {
        let layoutDirection: UIUserInterfaceLayoutDirection
        if #available(iOS 9, *) {
            layoutDirection = UIView.userInterfaceLayoutDirectionForSemanticContentAttribute(self.semanticContentAttribute)
        }
        else {
            layoutDirection = UIApplication.sharedApplication().userInterfaceLayoutDirection
        }
        return layoutDirection
    }
    
    private func layoutDirectionAdjustedLayoutForFrame(frame: CGRect, layoutDirection: UIUserInterfaceLayoutDirection) -> CGRect {
        return (layoutDirection == UIUserInterfaceLayoutDirection.RightToLeft) ? rightToLeftAdjustedFrameForFrame(frame) : frame
    }
    
    private func rightToLeftAdjustedFrameForFrame(inputFrame: CGRect) -> CGRect {
        return CGRect(x: frame.size.width - inputFrame.origin.x - inputFrame.size.width, y: inputFrame.origin.y, width: inputFrame.size.width, height: inputFrame.size.height)
    }
    
    // MARK: Animation
    
    private func identifierForComponent(component: ComponentSpecification) -> String {
        return "\(component.viewClass)"
    }
    
    private func componentIdentifierToIndiciesMapWithComponents(components: [ComponentSpecification]) -> [String: [Int]] {
        var identifierToIndicies: [String: [Int]] = [:]
        for (index, component) in components.enumerate() {
            let key = identifierForComponent(component)
            if identifierToIndicies[key] == nil {
                identifierToIndicies[key] = []
            }
            identifierToIndicies[key]!.append(index)
        }
        return identifierToIndicies
    }
    
    private func matchingComponentIndexLookupForComponents(source: [ComponentSpecification], destination: [ComponentSpecification]) -> [Int: Int] {
        var destinationMap = componentIdentifierToIndiciesMapWithComponents(destination)
        var sourceToDestination: [Int: Int] = [:]
        for (sourceIndex, component) in source.enumerate() {
            let key = identifierForComponent(component)
            if let indicies = destinationMap[key] where indicies.count > 0 {
                let destinationIndex = destinationMap[key]!.removeFirst()
                sourceToDestination[sourceIndex] = destinationIndex
            }
        }
        return sourceToDestination
    }
    
    // MARK: Convenience
    
    private func viewNeedsToBeResetForComponentSpecifications(componentSpecifications: [ComponentSpecification]) -> Bool {
        return componentSpecifications.count != views.count || componentSpecifications.zip(views).any({(c: ComponentSpecification, v: UIView) -> Bool in
            return c.viewClass !== v.dynamicType
        })
    }
}
