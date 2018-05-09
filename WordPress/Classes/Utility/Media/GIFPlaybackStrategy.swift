import Foundation

@objc
enum GIFStrategy: Int {
    case smallGIFs
    case mediumGIFs
    case largeGIFs

    /// Returns the corresponding playback strategy
    ///
    var playbackStrategy: GIFPlaybackStrategy {
        switch self {
        case .smallGIFs:
            return SmallGIFPlaybackStrategy()
        case .mediumGIFs:
            return MediumGIFPlaybackStrategy()
        case .largeGIFs:
            return LargeGIFPlaybackStrategy()
        }
    }
}

public protocol GIFPlaybackStrategy {
    /// Maximum size GIF data can be in order to be animated.
    ///
    var maxSize: Int { get }

    /// The number of frames that should be buffered. A high number will result in more
    /// memory usage and less CPU load, and vice versa. Default is 50.
    ///
    var frameBufferCount: Int { get }

    /// Verifies the GIF data against the `maxSize` var.
    ///
    /// - Parameter data: object containg the GIF
    /// - Returns: **true** if data is under the maximum size limit (inclusive) and **false** if over the limit
    ///
    func verifyDataSize(_ data: Data) -> Bool
}

extension GIFPlaybackStrategy {
    func verifyDataSize(_ data: Data) -> Bool {
        guard data.count <= maxSize else {
            DDLogDebug("⚠️ Maximum GIF data size exceeded \(maxSize) with \(data.count)")
            return false
        }
        return true
    }
}

class SmallGIFPlaybackStrategy: GIFPlaybackStrategy {
    var maxSize = 10_000_000  // in MB
    var frameBufferCount = 50
}

class MediumGIFPlaybackStrategy: GIFPlaybackStrategy {
    var maxSize = 20_000_000  // in MB
    var frameBufferCount = 50
}

class LargeGIFPlaybackStrategy: GIFPlaybackStrategy {
    var maxSize = 40_000_000  // in MB
    var frameBufferCount = 60
}
