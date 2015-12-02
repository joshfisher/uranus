import Foundation

public struct Button: Component {
    public typealias ViewType = UIButton
    
    public var backgroundColor: UIColor?
    
    private var titleDictionary: [UInt: String] = [:]
    private var titleColorDictionary: [UInt: UIColor] = [:]
    private var imageDictionary: [UInt: UIImage] = [:]
    private var backgroundImageDictionary: [UInt: UIImage] = [:]
    private var attributedTitleDictionary: [UInt: NSAttributedString] = [:]
    
    public init() {
        
    }
    
    public mutating func setTitle(title: String?, forState state: UIControlState) -> () {
        setObject(title, inDictionary: &titleDictionary, forState: state)
    }

    public mutating func setTitleColor(color: UIColor?, forState state: UIControlState) -> () {
        setObject(color, inDictionary: &titleColorDictionary, forState: state)
    }

    public mutating func setImage(image: UIImage?, forState state: UIControlState) -> () {
        setObject(image, inDictionary: &imageDictionary, forState: state)
    }

    public mutating func setBackgroundImage(image: UIImage?, forState state: UIControlState) -> () {
        setObject(image, inDictionary: &backgroundImageDictionary, forState: state)
    }

    public mutating func setAttributedTitle(title: NSAttributedString!, forState state: UIControlState) -> () {
        setObject(title, inDictionary: &attributedTitleDictionary, forState: state)
    }

    public func titleForState(state: UIControlState) -> String? {
        return objectInDictionary(titleDictionary, forState: state)
    }

    public func titleColorForState(state: UIControlState) -> UIColor? {
        return objectInDictionary(titleColorDictionary, forState: state)
    }

    public func imageForState(state: UIControlState) -> UIImage? {
        return objectInDictionary(imageDictionary, forState: state)
    }

    public func backgroundImageForState(state: UIControlState) -> UIImage? {
        return objectInDictionary(backgroundImageDictionary, forState: state)
    }

    private func setObject<T>(object: T?, inout inDictionary dictionary: [UInt: T], forState state: UIControlState) -> () {
        if let object = object {
            dictionary[state.rawValue] = object
        }
        else {
            dictionary.removeValueForKey(state.rawValue)
        }
    }
    
    private func objectInDictionary<T>(dictionary: [UInt: T], forState state: UIControlState) -> T? {
        return dictionary[state.rawValue]
    }
}

extension UIButton: Composable {
    
    public func configureWithComponent(component: Button) -> () {
        backgroundColor = component.backgroundColor
        
        configureWithDictionary(component.titleDictionary, setter: setTitle)
        configureWithDictionary(component.titleColorDictionary, setter: setTitleColor)
        configureWithDictionary(component.imageDictionary, setter: setImage)
        configureWithDictionary(component.backgroundImageDictionary, setter: setBackgroundImage)
    }
    
    public func setHighlighted(highlighted: Bool, animated: Bool) -> () {
        
    }
    
    public func setSelected(selected: Bool, animated: Bool) -> () {
        
    }
    
    public func prepareForReuse() -> () {
        
    }
    
    public static func sizeForComponent(component: Button, constrainedToSize: CGSize) -> CGSize {
        struct Sizing {
            static let button = UIButton(frame: CGRectZero)
        }
        
        Sizing.button.configureWithComponent(component)
        return Sizing.button.sizeThatFits(constrainedToSize)
    }
    
    private func configureWithDictionary<T>(dictionary: [UInt: T], setter: (T?, UIControlState) -> ()) -> () {
        for (key, value) in dictionary {
            setter(value, UIControlState(rawValue: key))
        }
    }
}
