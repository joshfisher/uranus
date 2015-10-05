import Foundation

public struct ImageView {
    
    public var backgroundColor: UIColor?
    
    public var image: UIImage?
    public var size: CGSize?
    public var contentMode: UIViewContentMode
    public var clipsToBounds: Bool
    
    public init(image: UIImage?, size: CGSize? = nil, contentMode: UIViewContentMode = UIViewContentMode.ScaleToFill, clipsToBounds: Bool = true) {
        self.image = image
        self.size = size
        self.contentMode = contentMode
        self.clipsToBounds = clipsToBounds
    }
}

extension UIImageView: Composable {
    
    public func configureWithComponent(component: ImageView) -> () {
        backgroundColor = component.backgroundColor
        image = component.image
        contentMode = component.contentMode
        clipsToBounds = component.clipsToBounds
    }
    
    public func setHighlighted(highlighted: Bool, animated: Bool) -> () {
        
    }
    
    public func setSelected(selected: Bool, animated: Bool) -> () {
        
    }
    
    public func prepareForReuse() -> () {
        
    }
    
    public static func sizeForComponent(component: ImageView, constrainedToSize: CGSize) -> CGSize {
        let size: CGSize
        if let explicitSize = component.size {
            size = explicitSize
        }
        else if let imageSize = component.image?.size {
            size = CGSize(width: constrainedToSize.width, height: pixelRound(constrainedToSize.width * imageSize.height / imageSize.width))
        }
        else {
            size = CGSize.zero
        }
        return size
    }
}
