import UIKit
import Uranus

class ViewController: UIViewController {
    
    var componentsView: ComponentsView!
    var specification: LayoutSpecification!
    
    var layoutDirectionBarButtonItem: UIBarButtonItem?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        if #available(iOS 9, *) {
            layoutDirectionBarButtonItem = UIBarButtonItem(title: "Force RTL On", style: UIBarButtonItemStyle.Plain, target: self, action: "toggleRTL")
            navigationItem.rightBarButtonItem = layoutDirectionBarButtonItem
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() -> () {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        componentsView = ComponentsView(frame: CGRect.zero)
        view.addSubview(componentsView)
        
        var label = Label(text: "This is a label", font: UIFont.systemFontOfSize(20.0))
        label.backgroundColor = UIColor.blueColor().colorWithAlphaComponent(0.2)
        
        let imageView = ImageView(image: UIImage(named: "image"), contentMode: UIViewContentMode.ScaleAspectFill)
        
        var cancelButton = Button()
        cancelButton.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.2)
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        var acceptButton = Button()
        acceptButton.backgroundColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
        acceptButton.setTitle("Okay", forState: UIControlState.Normal)
        acceptButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        let c1 = FlexSpecification(specification: Component(component: label, viewClass: UILabel.self), layoutType: .Dynamic)
        let c2 = FlexSpecification(specification: Component(component: imageView, viewClass: UIImageView.self), layoutType: .Full)
        let c3 = FlexSpecification(specification: Component(component: cancelButton, viewClass: UIButton.self), layoutType: .Dynamic, flexible: true)
        let c4 = FlexSpecification(specification: Component(component: acceptButton, viewClass: UIButton.self), layoutType: .Dynamic, flexible: true)
        
        let model = FlexLayoutModel(specifications: [c1, c2, c3, c4])
        
        specification = LayoutSpecification(arrangingModel: model, arrangingClass: FlexLayout.self)
        componentsView.configureWithLayoutSpecification(specification)
    }
    
    override func viewDidLayoutSubviews() -> () {
        componentsView.frame = CGRect(x: 0.0, y: topLayoutGuide.length, width: view.frame.size.width, height: ComponentsView.sizeForLayoutSpecification(specification, constrainedToSize: view.bounds.size).height)
    }
    
    @available(iOS 9, *)
    func toggleRTL() -> () {
        if componentsView.semanticContentAttribute == UISemanticContentAttribute.ForceRightToLeft {
            componentsView.semanticContentAttribute = UISemanticContentAttribute.Unspecified
            layoutDirectionBarButtonItem?.title = "Force RTL On"
        }
        else {
            componentsView.semanticContentAttribute = UISemanticContentAttribute.ForceRightToLeft
            layoutDirectionBarButtonItem?.title = "Force RTL Off"
        }
    }
}
