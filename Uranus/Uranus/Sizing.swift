import Foundation

private struct Sizing {
    private static let screenScale = UIScreen.mainScreen().scale
}

internal func pixelFloor(value: CGFloat) -> CGFloat {
    return floor(value * Sizing.screenScale) / Sizing.screenScale
}

internal func pixelRound(value: CGFloat) -> CGFloat {
    return round(value * Sizing.screenScale) / Sizing.screenScale
}

internal func pixelCeil(value: CGFloat) -> CGFloat {
    return ceil(value * Sizing.screenScale) / Sizing.screenScale
}
