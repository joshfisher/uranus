import Foundation

public struct TextView: Component {
    public typealias ViewType = UITextView
    
    weak var delegate: UITextViewDelegate?
    
    var text: String?
    var font: UIFont?
    var textColor: UIColor?
    var textAlignment: NSTextAlignment?
    
    var attributedText: NSAttributedString?
    
    public var editable: Bool?
    public var selectable: Bool?
    
    public init(text: String?, font: UIFont? = nil, textColor: UIColor? = nil, textAlignment: NSTextAlignment? = nil, lineBreakMode: NSLineBreakMode? = nil) {
        self.text = text
        self.font = font
        self.textColor = textColor
        self.textAlignment = textAlignment
        self.attributedText = nil
    }
    
    public init(attributedText: NSAttributedString) {
        self.text = nil
        self.font = nil
        self.textColor = nil
        self.textAlignment = nil
        self.attributedText = attributedText
    }
}

extension UITextView: Composable {
    
    public func configureWithComponent(component: TextView) -> () {
        if let text = component.attributedText {
            attributedText = text
        }
        else {
            text = component.text
            font = component.font ?? UIFont.systemFontOfSize(UIFont.systemFontSize())
            textColor = component.textColor ?? UIColor.blackColor()
            textAlignment = component.textAlignment ?? NSTextAlignment.Left
            editable = component.editable ?? true
            selectable = component.selectable ?? true
        }
    }
    
    public func setHighlighted(highlighted: Bool, animated: Bool) -> () {
        
    }
    
    public func setSelected(selected: Bool, animated: Bool) -> () {
        
    }
    
    public func prepareForReuse() -> () {
        
    }
    
    public static func sizeForComponent(component: TextView, constrainedToSize: CGSize) -> CGSize {
        struct Sizing {
            static let textView = UITextView(frame: CGRectZero)
        }
        
        Sizing.textView.configureWithComponent(component)
        return Sizing.textView.sizeThatFits(constrainedToSize)
    }
}
