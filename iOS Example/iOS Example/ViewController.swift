import UIKit
import Uranus

class ViewController: UIViewController {
    
    var componentsView: ComponentsView!
    var layout: FlexLayoutModel!
    
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
        
        let c1 = FlexSpecification(component: label, layoutType: .Dynamic)
        let c2 = FlexSpecification(component: imageView, layoutType: .Full)
        let c3 = FlexSpecification(component: cancelButton, layoutType: .Dynamic, flexible: true)
        let c4 = FlexSpecification(component: acceptButton, layoutType: .Dynamic, flexible: true)
        
        layout = FlexLayoutModel(specifications: [c1, c2, c3, c4])
        componentsView.configureWithLayout(layout)
    }
    
    override func viewDidLayoutSubviews() -> () {
        componentsView.frame = CGRect(x: 0.0, y: topLayoutGuide.length, width: view.frame.size.width, height: view.frame.size.height - topLayoutGuide.length)
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
