import Foundation
import Mars

public class ComponentsView: UIView {
    
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
                if layoutDirection == UIUserInterfaceLayoutDirection.RightToLeft {
                    view.frame = self.rightToLeftAdjustedFrameForFrame(frame)
                }
                else {
                    view.frame = frame
                }
            }
        }
    }
    
    internal func configureWithLayoutSpecification(layoutSpecification: LayoutSpecification) {
        specification = layoutSpecification
        
        let componentSpecifications = componentSpecificationsForSpecifications(layoutSpecification.internalSpecificationsBlock())
        
        if viewNeedsToBeResetForComponentSpecifications(componentSpecifications) {
            for view in views {
                view.removeFromSuperview()
            }
            views.removeAll(keepCapacity: true)
            
            for componentSpecification in componentSpecifications {
                let view = componentSpecification.internalViewCreationBlock()
                addSubview(view)
                views.append(view)
            }
        }
        
        for (view, componentSpecification) in views.zip(componentSpecifications) {
            componentSpecification.internalConfigurationBlock(view: view)
        }
    }
    
    public func configureWithLayout<LayoutType: Layout where LayoutType.ArrangingType.ModelType == LayoutType>(layout: LayoutType) {
        configureWithLayoutSpecification(LayoutSpecification(model: layout, arrangingClass: LayoutType.ArrangingType.self))
    }
    
    internal static func sizeForLayoutSpecification(layoutSpecification: LayoutSpecification, constrainedToSize: CGSize) -> CGSize {
        return layoutSpecification.internalSizingBlock(constrainedToSize: constrainedToSize)
    }
    
    public static func sizeForLayout<LayoutType: Layout where LayoutType.ArrangingType.ModelType == LayoutType>(layout: LayoutType, constrainedToSize: CGSize) -> CGSize {
        return sizeForLayoutSpecification(LayoutSpecification(model: layout, arrangingClass: LayoutType.ArrangingType.self), constrainedToSize: constrainedToSize)
    }
    
    private func viewNeedsToBeResetForComponentSpecifications(componentSpecifications: [ComponentSpecification]) -> Bool {
        return componentSpecifications.count != views.count || componentSpecifications.zip(views).any({(c: ComponentSpecification, v: UIView) -> Bool in
            return c.viewClass !== v.dynamicType
        })
    }
    
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
    
    private func rightToLeftAdjustedFrameForFrame(inputFrame: CGRect) -> CGRect {
        return CGRect(x: frame.size.width - inputFrame.origin.x - inputFrame.size.width, y: inputFrame.origin.y, width: inputFrame.size.width, height: inputFrame.size.height)
    }
}
