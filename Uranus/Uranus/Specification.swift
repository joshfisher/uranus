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
    
    public let arrangingModel: Any
    public let arrangingClass: AnyClass
    
    internal let internalSpecificationsBlock: InternalSpecificationsBlock
    internal let internalFramesBlock: InternalFramesBlock
    internal let internalSizingBlock: InternalSizingBlock
    
    public init<ModelType, ArrangingType: Arranging where ModelType == ArrangingType.ModelType>(arrangingModel: ModelType, arrangingClass: ArrangingType.Type) {
        self.arrangingModel = arrangingModel
        self.arrangingClass = arrangingClass
        
        self.internalSpecificationsBlock = {() -> [Specification] in
            return arrangingClass.specificationsForModel(arrangingModel)
        }
        
        self.internalFramesBlock = {(constrainedToSize) -> [CGRect] in
            return arrangingClass.viewFramesForModel(arrangingModel, constrainedToSize: constrainedToSize)
        }
        
        self.internalSizingBlock = {(constrainedToSize) -> CGSize in
            return arrangingClass.sizeForModel(arrangingModel, constrainedToSize: constrainedToSize)
        }
    }
}

public class ComponentSpecification: SpecificationProtocol {
    
    internal typealias InternalViewCreationBlock = () -> UIView
    internal typealias InternalConfigurationBlock = (view: UIView) -> ()
    internal typealias InternalSizingBlock = (constrainedToSize: CGSize) -> CGSize
    
    public let component: Any
    public let viewClass: AnyClass
    
    internal let internalViewCreationBlock: InternalViewCreationBlock
    internal let internalConfigurationBlock: InternalConfigurationBlock
    internal let internalSizingBlock: InternalSizingBlock
    
    public init<ComponentType, ViewType: Composable where ViewType: UIView, ComponentType == ViewType.ComponentType>(component: ComponentType, viewClass: ViewType.Type) {
        self.component = component
        self.viewClass = viewClass
        
        self.internalViewCreationBlock = {() -> UIView in
            return viewClass.init(frame: CGRect.zero)
        }
        
        self.internalConfigurationBlock = {(view) -> () in
            if let castedView = view as? ViewType {
                castedView.configureWithComponent(component)
            }
        }
        
        self.internalSizingBlock = {(constrainedToSize) -> CGSize in
            return viewClass.sizeForComponent(component, constrainedToSize: constrainedToSize)
        }
    }
}

public func Layout<ModelType, ArrangingType: Arranging where ModelType == ArrangingType.ModelType>(arrangingModel arrangingModel: ModelType, arrangingClass: ArrangingType.Type) -> Specification {
    return Specification.Layout(LayoutSpecification(arrangingModel: arrangingModel, arrangingClass: arrangingClass))
}

public func Component<ComponentType, ViewType: Composable where ViewType: UIView, ComponentType == ViewType.ComponentType>(component component: ComponentType, viewClass: ViewType.Type) -> Specification {
    return Specification.Component(ComponentSpecification(component: component, viewClass: viewClass))
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
