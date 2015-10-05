import Foundation

public struct Label {
    
    public var backgroundColor: UIColor?
    
    public var text: String?
    public var font: UIFont?
    public var textColor: UIColor?
    public var textAlignment: NSTextAlignment?
    public var lineBreakMode: NSLineBreakMode?
    
    public var attributedText: NSAttributedString?
    
    public init(text: String?, font: UIFont? = nil, textColor: UIColor? = nil, textAlignment: NSTextAlignment? = nil, lineBreakMode: NSLineBreakMode? = nil) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.lineBreakMode = lineBreakMode
        self.attributedText = nil
    }
    
    public init(attributedText: NSAttributedString) {
        self.text = nil
        self.font = nil
        self.textColor = nil
        self.textAlignment = nil
        self.lineBreakMode = nil
        self.attributedText = attributedText
    }
}

extension UILabel: Composable {
    
    public func configureWithComponent(component: Label) -> () {
        backgroundColor = component.backgroundColor ?? UIColor.clearColor()
        
        if let text = component.attributedText {
            attributedText = text
        }
        else {
            text = component.text
            font = component.font ?? UIFont.systemFontOfSize(UIFont.systemFontSize())
            textColor = component.textColor ?? UIColor.blackColor()
            textAlignment = component.textAlignment ?? NSTextAlignment.Left
            lineBreakMode = component.lineBreakMode ?? NSLineBreakMode.ByTruncatingMiddle
        }
    }
    
    public func setHighlighted(highlighted: Bool, animated: Bool) -> () {
        
    }
    
    public func setSelected(selected: Bool, animated: Bool) -> () {
        
    }
    
    public func prepareForReuse() -> () {
        
    }
    
    public static func sizeForComponent(component: Label, constrainedToSize: CGSize) -> CGSize {
        struct Sizing {
            static let label = UILabel(frame: CGRectZero)
        }
        
        Sizing.label.configureWithComponent(component)
        return Sizing.label.sizeThatFits(constrainedToSize)
    }
}
