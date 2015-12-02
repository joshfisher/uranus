import Foundation

internal protocol SpecificationProtocol {
    var internalSizingBlock: (constrainedToSize: CGSize) -> CGSize { get }
}

public enum Specification {
    case Layout(LayoutSpecification)
    case Component(ComponentSpecification)
}

public class LayoutSpecification: SpecificationProtocol {
    
    internal typealias InternalSpecificationsBlock = () -> [Specification]
    internal typealias InternalFramesBlock = (constrainedToSize: CGSize) -> [CGRect]
    internal typealias InternalSizingBlock = (constrainedToSize: CGSize) -> CGSize
    
    public let model: Any
    public let arrangingClass: AnyClass
    
    internal let internalSpecificationsBlock: InternalSpecificationsBlock
    internal let internalFramesBlock: InternalFramesBlock
    internal let internalSizingBlock: InternalSizingBlock
    
    public init<ModelType, ArrangingType: Arranging where ModelType == ArrangingType.ModelType>(model: ModelType, arrangingClass: ArrangingType.Type) {
        self.model = model
        self.arrangingClass = arrangingClass
        
        self.internalSpecificationsBlock = {() -> [Specification] in
            return arrangingClass.specificationsForModel(model)
        }
        
        self.internalFramesBlock = {(constrainedToSize) -> [CGRect] in
            return arrangingClass.viewFramesForModel(model, constrainedToSize: constrainedToSize)
        }
        
        self.internalSizingBlock = {(constrainedToSize) -> CGSize in
            return arrangingClass.sizeForModel(model, constrainedToSize: constrainedToSize)
        }
    }
}

public class ComponentSpecification: SpecificationProtocol {
    
    internal typealias InternalViewCreationBlock = () -> UIView
    internal typealias InternalConfigurationBlock = (view: UIView) -> ()
    internal typealias InternalSizingBlock = (constrainedToSize: CGSize) -> CGSize
    
    public let model: Any
    public let viewClass: AnyClass
    
    internal let internalViewCreationBlock: InternalViewCreationBlock
    internal let internalConfigurationBlock: InternalConfigurationBlock
    internal let internalSizingBlock: InternalSizingBlock
    
    public init<ComponentType, ViewType: Composable where ViewType: UIView, ComponentType == ViewType.ComponentType>(model: ComponentType, viewClass: ViewType.Type) {
        self.model = model
        self.viewClass = viewClass
        
        self.internalViewCreationBlock = {() -> UIView in
            return viewClass.init(frame: CGRect.zero)
        }
        
        self.internalConfigurationBlock = {(view) -> () in
            if let castedView = view as? ViewType {
                castedView.configureWithComponent(model)
            }
        }
        
        self.internalSizingBlock = {(constrainedToSize) -> CGSize in
            return viewClass.sizeForComponent(model, constrainedToSize: constrainedToSize)
        }
    }
}

public func componentSpecificationsForSpecifications(specifications: [Specification]) -> [ComponentSpecification] {
    let componentSpecifications = specifications.flatMap({(specification) -> [ComponentSpecification] in
        switch specification {
            case .Layout(let layoutSpecification):
                return componentSpecificationsForSpecifications(layoutSpecification.internalSpecificationsBlock())
            case .Component(let componentSpecification):
                return [componentSpecification]
        }
    })
    return componentSpecifications
}

internal func specificationProtocolFromSpecification(specification: Specification) -> SpecificationProtocol {
    switch specification {
        case .Layout(let layoutSpecification):
            return layoutSpecification
        case .Component(let componentSpecification):
            return componentSpecification
    }
}
