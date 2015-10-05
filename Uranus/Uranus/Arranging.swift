import Foundation

public protocol Arranging: class {
    typealias ModelType
    
    static func specificationsForModel(model: ModelType) -> [Specification]
    static func viewFramesForModel(model: ModelType, constrainedToSize: CGSize) -> [CGRect]
    static func sizeForModel(model: ModelType, constrainedToSize: CGSize) -> CGSize
}
