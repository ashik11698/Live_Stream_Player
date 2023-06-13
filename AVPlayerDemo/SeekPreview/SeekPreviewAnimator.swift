//
//  SeekPreviewAnimator.swift
//  SeekPreview
//
//  Created by Enrico Zannini on 14/03/2021.
//

import UIKit

/**
 * An animator protocol that handles show/hide for the preview
 */
public protocol SeekPreviewAnimator {
    /**
     * Shows the preview
     *
     * - parameter preview: The actual view holding the preview images
     * - parameter animated: A flag that informs if the show action should be animated or not
     */
    func showPreview(_ preview: UIView, animated: Bool)
    /**
     * Hides the preview
     *
     * - parameter preview: The actual view holding the preview images
     * - parameter animated: A flag that informs if the hide action should be animated or not
     */
    func hidePreview(_ preview: UIView, animated: Bool)
}

/**
 * An animator that scales, moves up and fades the preview.
 */
open class ScaleMoveUpAnimator: ScalePreviewAnimator {
    
    override func smallTransform(view: UIView) -> CGAffineTransform {
        return super.smallTransform(view: view)
            .concatenating(CGAffineTransform(translationX: 0, y: view.frame.height/3))
    }
}

/**
* An animator that scales and fades the preview.
*/
open class ScalePreviewAnimator: BaseAnimator, SeekPreviewAnimator {
    
    public func showPreview(_ preview: UIView, animated: Bool) {
        self.animate(animated: animated) {
            preview.transform = CGAffineTransform.identity
            preview.alpha = 1
        }
    }
    
    public func hidePreview(_ preview: UIView, animated: Bool) {
        self.animate(animated: animated) {
            preview.transform = self.smallTransform(view: preview)
            preview.alpha = 0
        }
    }
    
    func smallTransform(view: UIView) -> CGAffineTransform {
        return CGAffineTransform(scaleX: 0.3, y: 0.3)
    }
}

/**
 * An animator that just fades the preview.
 */
open class FadePreviewAnimator: BaseAnimator, SeekPreviewAnimator {
    
    public func showPreview(_ preview: UIView, animated: Bool) {
        fade(view: preview, alpha: 1, animated: animated)
    }
    
    public func hidePreview(_ preview: UIView, animated: Bool) {
        fade(view: preview, alpha: 0, animated: animated)
    }
    
    private func fade(view: UIView, alpha: CGFloat, animated: Bool) {
        self.animate(animated: animated) {
            view.alpha = alpha
        }
    }
}

/**
 * Utility class to handle the animated/not animated block.
 */
open class BaseAnimator {
    
    let duration: TimeInterval
    
    /**
     * Creates the animator with a default animation duration
     *
     * - parameter duration: The duration of all animations
     */
    public init(duration: TimeInterval) {
        self.duration = duration
    }
    
    func animate(animated: Bool, block: @escaping () -> Void) {
        if animated {
            UIView.animate(withDuration: self.duration, animations: block)
        } else {
            block()
        }
    }
    
    
}
