import Foundation

public protocol Composable: class {
    typealias ComponentType
    
    init(frame: CGRect)
    
    func configureWithComponent(component: ComponentType) -> ()
    func setHighlighted(highlighted: Bool, animated: Bool) -> ()
    func setSelected(selected: Bool, animated: Bool) -> ()
    func prepareForReuse() -> ()
    
    static func sizeForComponent(component: ComponentType, constrainedToSize: CGSize) -> CGSize
}

public protocol Component {
    typealias ViewType: Composable
}
