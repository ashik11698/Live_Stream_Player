//
//  SeekPreviewDelegate.swift
//  SeekPreview
//
//  Created by Enrico Zannini on 14/03/2021.
//

import Foundation
import UIKit

/**
 * A delegate that handles preview images loading for us and provides them when requested
 *
 * N.B. You can implement preview images loading as you want, but we suggest you to do it in advance because we will require them synchronously on the main thread
 */
@objc public protocol SeekPreviewDelegate: class {
    /**
     * A method used to request the preview for a specific value.
     *
     * Since you probably don't have a preview for each specific value that the slider can have, you are expected to always return the closest preview for that value.
     *
     * - parameter value: The current value of the slider
     * - returns: The image to display closest to the value of the slider, or nil if it can't display anything
     */
    func getSeekPreview(value: Float) -> UIImage?
}
