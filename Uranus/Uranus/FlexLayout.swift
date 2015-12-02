import Foundation
import Mars

public enum FlexLayoutType {
    case Dynamic
    case Fixed
    case Full
}

public enum FlexVerticalAlignment {
    case Bottom
    case Center
    case Top
}

// MARK: - FlexSpecification -

public class FlexSpecification {
    
    public static let AutomaticMargins = UIEdgeInsets(top: CGFloat.max, left: CGFloat.max, bottom: CGFloat.max, right: CGFloat.max)
    
    public let specification: Specification
    public let margins: UIEdgeInsets
    public let padding: UIEdgeInsets
    public let layoutType: FlexLayoutType
    public let verticalAlignment: FlexVerticalAlignment
    
    public let widthConstraint: CGFloat?
    public let widthPercentConstraint: CGFloat?
    
    public let flexible: Bool
    public let growthFactor: CGFloat
    
    public init(specification: Specification, layoutType: FlexLayoutType = .Dynamic, margins: UIEdgeInsets = FlexSpecification.AutomaticMargins, padding: UIEdgeInsets = UIEdgeInsetsZero, verticalAlignment: FlexVerticalAlignment = .Top, widthConstraint: CGFloat? = nil, widthPercentConstraint: CGFloat? = nil, flexible: Bool = false, growthFactor: CGFloat = 1.0) {
        self.specification = specification
        self.layoutType = layoutType
        self.margins = margins
        self.padding = padding
        self.verticalAlignment = verticalAlignment
        self.widthConstraint = widthConstraint
        self.widthPercentConstraint = widthPercentConstraint
        self.flexible = flexible
        self.growthFactor = growthFactor
    }
    
    public convenience init<ComponentType: Component where ComponentType.ViewType: UIView, ComponentType.ViewType.ComponentType == ComponentType>(component: ComponentType, layoutType: FlexLayoutType = .Dynamic, margins: UIEdgeInsets = FlexSpecification.AutomaticMargins, padding: UIEdgeInsets = UIEdgeInsetsZero, verticalAlignment: FlexVerticalAlignment = .Top, widthConstraint: CGFloat? = nil, widthPercentConstraint: CGFloat? = nil, flexible: Bool = false, growthFactor: CGFloat = 1.0) {
        let specification = Specification.Component(ComponentSpecification(model: component, viewClass: ComponentType.ViewType.self))
        self.init(specification: specification, layoutType: layoutType, margins: margins, padding: padding, verticalAlignment: verticalAlignment, widthConstraint: widthConstraint, widthPercentConstraint: widthPercentConstraint, flexible: flexible, growthFactor: growthFactor)
    }
    
    public convenience init<LayoutType: Layout where LayoutType.ArrangingType.ModelType == LayoutType>(layout: LayoutType, layoutType: FlexLayoutType = .Dynamic, margins: UIEdgeInsets = FlexSpecification.AutomaticMargins, padding: UIEdgeInsets = UIEdgeInsetsZero, verticalAlignment: FlexVerticalAlignment = .Top, widthConstraint: CGFloat? = nil, widthPercentConstraint: CGFloat? = nil, flexible: Bool = false, growthFactor: CGFloat = 1.0) {
        let specification = Specification.Layout(LayoutSpecification(model: layout, arrangingClass: LayoutType.ArrangingType.self))
        self.init(specification: specification, layoutType: layoutType, margins: margins, padding: padding, verticalAlignment: verticalAlignment, widthConstraint: widthConstraint, widthPercentConstraint: widthPercentConstraint, flexible: flexible, growthFactor: growthFactor)
    }
}

// MARK: - FlexLayoutModel -

public struct FlexLayoutModel: Layout {
    public typealias ArrangingType = FlexLayout
    
    let specifications: [FlexSpecification]
    let automaticMarginsApplyToEdges: Bool
    
    public init(specifications: [FlexSpecification], automaticMarginsApplyToEdges: Bool = true) {
        self.specifications = specifications
        self.automaticMarginsApplyToEdges = automaticMarginsApplyToEdges
    }
}

// MARK: - FlexLayout -

public class FlexLayout: Arranging {

    private static let StandardPadding = CGFloat(10.0)
    private static let NoConstraint = CGFloat.max
    
    private typealias Constraint = (flexSpecification: FlexSpecification, size: CGSize)
    private typealias Sizing = (flexSpecification: FlexSpecification, size: CGSize, margins: UIEdgeInsets)
    private typealias Layout = (boundingBoxes: [CGRect], viewFrames: [CGRect])
    
    public static func specificationsForModel(model: FlexLayoutModel) -> [Specification] {
        return model.specifications.map({$0.specification})
    }
    
    public static func viewFramesForModel(model: FlexLayoutModel, constrainedToSize: CGSize) -> [CGRect] {
        return layoutForModel(model, constrainedToSize: constrainedToSize).viewFrames
    }
    
    public static func sizeForModel(model: FlexLayoutModel, constrainedToSize: CGSize) -> CGSize {
        let layoutInformation = layoutForModel(model, constrainedToSize: constrainedToSize)
        let width = layoutInformation.boundingBoxes.reduce(CGFloat(0.0), combine: {max($0, $1.maxX)})
        let height = layoutInformation.boundingBoxes.reduce(CGFloat(0.0), combine: {max($0, $1.maxY)})
        return CGSize(width: width, height: height)
    }
    
    // MARK: Margins
    
    private static func automaticMarginForComponent(model: FlexLayoutModel, margin: CGFloat, isEdgeElement: Bool) -> CGFloat {
        return (isEdgeElement) ? (model.automaticMarginsApplyToEdges) ? StandardPadding : 0.0 : StandardPadding / 2.0
    }
    
    private static func adjustedMarginsForComponent(model: FlexLayoutModel, margins: UIEdgeInsets, isTopEdge: Bool, isLeftEdge: Bool, isBottomEdge: Bool, isRightEdge: Bool) -> UIEdgeInsets {
        let top = adjustedTopMarginForComponent(model, margins: margins, isEdgeElement: isTopEdge)
        let left = adjustedLeftMarginForComponent(model, margins: margins, isEdgeElement: isLeftEdge)
        let bottom = adjustedBottomMarginForComponent(model, margins: margins, isEdgeElement: isBottomEdge)
        let right = adjustedRightMarginForComponent(model, margins: margins, isEdgeElement: isRightEdge)
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
    
    private static func adjustedTopMarginForComponent(model: FlexLayoutModel, margins: UIEdgeInsets, isEdgeElement: Bool) -> CGFloat {
        return (margins.top == FlexSpecification.AutomaticMargins.top) ? automaticMarginForComponent(model, margin: margins.top, isEdgeElement: isEdgeElement) : margins.top
    }
    
    private static func adjustedLeftMarginForComponent(model: FlexLayoutModel, margins: UIEdgeInsets, isEdgeElement: Bool) -> CGFloat {
        return (margins.left == FlexSpecification.AutomaticMargins.left) ? automaticMarginForComponent(model, margin: margins.left, isEdgeElement: isEdgeElement) : margins.left
    }
    
    private static func adjustedBottomMarginForComponent(model: FlexLayoutModel, margins: UIEdgeInsets, isEdgeElement: Bool) -> CGFloat {
        return (margins.bottom == FlexSpecification.AutomaticMargins.bottom) ? automaticMarginForComponent(model, margin: margins.bottom, isEdgeElement: isEdgeElement) : margins.bottom
    }
    
    private static func adjustedRightMarginForComponent(model: FlexLayoutModel, margins: UIEdgeInsets, isEdgeElement: Bool) -> CGFloat {
        return (margins.right == FlexSpecification.AutomaticMargins.right) ? automaticMarginForComponent(model, margin: margins.right, isEdgeElement: isEdgeElement) : margins.right
    }
    
    // MARK: Layout
    
    private static func sizeConstraintForModel(model: FlexLayoutModel, flexSpecification: FlexSpecification, maxWidth: CGFloat) -> Constraint {
        let margins = adjustedMarginsForComponent(model, margins: flexSpecification.margins, isTopEdge: true, isLeftEdge: true, isBottomEdge: true, isRightEdge: true)
        let padding = flexSpecification.padding
        let availableWidth = maxWidth - margins.left - margins.right
        
        let size: CGSize
        
        switch flexSpecification.layoutType {
            case .Dynamic:
                let specification = specificationProtocolFromSpecification(flexSpecification.specification)
                size = specification.internalSizingBlock(constrainedToSize: CGSize(width: availableWidth, height: CGFloat.max))
            case .Fixed:
                if let widthConstraint = flexSpecification.widthConstraint {
                    size = CGSize(width: widthConstraint, height: NoConstraint)
                }
                else if let widthPercentConstraint = flexSpecification.widthPercentConstraint {
                    size = CGSize(width: pixelFloor(widthPercentConstraint * maxWidth), height: NoConstraint)
                }
                else {
                    fatalError("You cannot use FlexLayoutType.Flexible without a width constraint.")
                }
            case .Full:
                size = CGSize(width: availableWidth, height: NoConstraint)
        }
        
        let width = min(size.width + padding.left + padding.right, availableWidth)
        let height = (size.height == NoConstraint) ? size.height : size.height + padding.top + padding.bottom
        
        return Constraint(flexSpecification, CGSize(width: width, height: height))
    }
    
    private static func layoutForModel(model: FlexLayoutModel, constrainedToSize: CGSize) -> Layout {
        let constraints = model.specifications.map({(flexSpecification) -> Constraint in
            return self.sizeConstraintForModel(model, flexSpecification: flexSpecification, maxWidth: constrainedToSize.width)
        })
        
        var lines: [[Constraint]] = []
        var currentLine: [Constraint] = []
        var remainingWidth = constrainedToSize.width
        
        for constraint in constraints {
            let leftMargin = adjustedLeftMarginForComponent(model, margins: constraint.flexSpecification.margins, isEdgeElement: (currentLine.count == 0))
            let leftEdgeMargin = adjustedLeftMarginForComponent(model, margins: constraint.flexSpecification.margins, isEdgeElement: true)
            let rightMargin = adjustedLeftMarginForComponent(model, margins: constraint.flexSpecification.margins, isEdgeElement: false)
            let rightEdgeMargin = adjustedLeftMarginForComponent(model, margins: constraint.flexSpecification.margins, isEdgeElement: true)
            
            if remainingWidth >= constraint.size.width + leftMargin + rightEdgeMargin {
                currentLine.append(constraint)
                remainingWidth -= constraint.size.width + leftMargin + rightMargin
            }
            else {
                lines.append(currentLine)
                currentLine.removeAll(keepCapacity: true)
                currentLine.append(constraint)
                remainingWidth = constrainedToSize.width - constraint.size.width - leftEdgeMargin - rightMargin
            }
        }
        
        if (currentLine.count > 0) {
            lines.append(currentLine)
        }
        
        var viewFrames: [CGRect] = []
        var boundingBoxes: [CGRect] = []
        var yOrigin = CGFloat(0.0)
        
        for (index, line) in lines.enumerate() {
            let isTopLine = (index == 0)
            let isBottomLine = (index == lines.count - 1)
            
            let lineLayout = lineLayoutWithModel(model, constraints: line, lineWidth: constrainedToSize.width, top: yOrigin, isTopLine: isTopLine, isBottomLine: isBottomLine)
            
            viewFrames.appendContentsOf(lineLayout.viewFrames)
            boundingBoxes.appendContentsOf(lineLayout.boundingBoxes)
            
            yOrigin = lineLayout.boundingBoxes.reduce(yOrigin, combine: {max($0, $1.maxY)})
        }
        
        return Layout(boundingBoxes: boundingBoxes, viewFrames: viewFrames)
    }
    
    private static func lineSizingsForModel(model: FlexLayoutModel, constraints: [Constraint], lineWidth: CGFloat, isTopLine: Bool, isBottomLine: Bool) -> [Sizing] {
        let margins = constraints.enumerate().map({(index, constraint) -> UIEdgeInsets in
            return self.adjustedMarginsForComponent(model, margins: constraint.flexSpecification.margins, isTopEdge: isTopLine, isLeftEdge: (index == 0), isBottomEdge: isBottomLine, isRightEdge: (index == constraints.count - 1))
        })
        
        var widths = constraints.map({(constraint) -> CGFloat in
            return constraint.size.width
        })
        
        let flexibleItems = constraints.enumerate().filter({(index, constraint) -> Bool in
            return constraint.flexSpecification.flexible
        })
        
        if flexibleItems.count > 0 {
            let widthsIncludingMargins = widths.zip(margins).map({(width, margins) -> CGFloat in
                return width + margins.left + margins.right
            })
            
            let remainingWidth = widthsIncludingMargins.reduce(lineWidth, combine: {$0 - $1})
            let totalGrowthFactor = flexibleItems.reduce(0.0, combine: {$0 + $1.element.flexSpecification.growthFactor})
            let additionalWidthPerGrowthFactor = remainingWidth / totalGrowthFactor
            
            var distributedWidth = CGFloat(0.0)
            for (index, flexibleItem) in flexibleItems.enumerate() {
                let additionalWidth: CGFloat
                if index != flexibleItems.count - 1 {
                    additionalWidth = pixelFloor(additionalWidthPerGrowthFactor * flexibleItem.element.flexSpecification.growthFactor)
                    distributedWidth += additionalWidth
                }
                else {
                    additionalWidth = remainingWidth - distributedWidth
                }
                widths[flexibleItem.index] += additionalWidth
            }
        }
        
        let heights = constraints.zip(widths).map({(constraint, width) -> CGFloat in
            if constraint.size.height != self.NoConstraint {
                return constraint.size.height
            }
            else {
                let specification = specificationProtocolFromSpecification(constraint.flexSpecification.specification)
                return specification.internalSizingBlock(constrainedToSize: CGSize(width: width, height: CGFloat.max)).height
            }
        })
        
        let sizes = widths.zip(heights).map({(width, height) -> CGSize in
            return CGSize(width: width, height: height)
        })
        
        let sizings = constraints.zip(sizes, margins).map({(constraint, size, margins) -> Sizing in
            return Sizing(flexSpecification: constraint.flexSpecification, size: size, margins: margins)
        })
        
        return sizings
    }
    
    private static func lineBoundingBoxesForSizings(sizings: [Sizing], lineWidth: CGFloat, top: CGFloat) -> [CGRect] {
        var x = CGFloat(0.0)
        let intialBoundingBoxes = sizings.map({(sizing) -> CGRect in
            let width = sizing.size.width + sizing.margins.left + sizing.margins.right
            let height = sizing.size.height + sizing.margins.top + sizing.margins.bottom
            let frame = CGRect(x: x, y: top, width: width, height: height)
            x += width
            return frame
        })
        
        let lineHeight = intialBoundingBoxes.reduce(CGFloat(0.0), combine: {max($0, $1.size.height)})
        
        let boundingBoxes = zip(sizings, intialBoundingBoxes).map({(sizing, boundingBox) -> CGRect in
            var frame = boundingBox
            switch sizing.flexSpecification.verticalAlignment {
                case .Top:
                    break
                case .Center:
                    frame.origin.y = pixelFloor(frame.origin.y + (lineHeight - frame.size.height) / 2.0)
                case .Bottom:
                    frame.origin.y = frame.origin.y + lineHeight - frame.size.height
            }
            return frame
        })
        
        return boundingBoxes
    }
    
    private static func lineViewFramesForSizings(sizings: [Sizing], boundingBoxes: [CGRect]) -> [CGRect] {
        let viewFrames = zip(sizings, boundingBoxes).flatMap({(sizing, boundingBox) -> [CGRect] in
            let frames: [CGRect]
            
            let x = boundingBox.origin.x + sizing.margins.left
            let y = boundingBox.origin.y + sizing.margins.top
            
            switch sizing.flexSpecification.specification {
                case .Layout(let layoutSpecification):
                    frames = layoutSpecification.internalFramesBlock(constrainedToSize: sizing.size).map({(frame) -> CGRect in
                        var adjustedFrame = frame
                        adjustedFrame.origin.x += x
                        adjustedFrame.origin.y += y
                        return adjustedFrame
                    })
                    
                case .Component(_):
                    frames = [CGRect(x: x, y: y, width: sizing.size.width, height: sizing.size.height)]
                }
            
            return frames
        })
        
        return viewFrames
    }
    
    private static func lineLayoutWithModel(model: FlexLayoutModel, constraints: [Constraint], lineWidth: CGFloat, top: CGFloat, isTopLine: Bool, isBottomLine: Bool) -> Layout {
        let sizings = lineSizingsForModel(model, constraints: constraints, lineWidth: lineWidth, isTopLine: isTopLine, isBottomLine: isBottomLine)
        let boundingBoxes = lineBoundingBoxesForSizings(sizings, lineWidth: lineWidth, top: top)
        let viewFrames = lineViewFramesForSizings(sizings, boundingBoxes: boundingBoxes)
        
        return Layout(boundingBoxes: boundingBoxes, viewFrames: viewFrames)
    }
}
