import UIKit

public final class DefaultEditBillingDetailsButtonStyle: ElementButtonStyle {
    public var textAlignment: NSTextAlignment = .natural
    public var image: UIImage? = Constants.Bundle.Images.rightArrow.image?.imageFlippedForRightToLeftLayoutDirection()
    public var text: String = Constants.LocalizationKeys.PaymentForm.BillingSummary.editBillingAddress
    public var font = FramesUIStyle.Font.actionDefault
    public var textColor: UIColor = FramesUIStyle.Color.textActionSecondary
    public var disabledTextColor: UIColor = .clear
    public var disabledTintColor: UIColor = .clear
    public var activeTintColor: UIColor = FramesUIStyle.Color.actionPrimary
    public var imageTintColor: UIColor = FramesUIStyle.Color.iconAction
    public var backgroundColor: UIColor = .clear
    public var isHidden = false
    public var isEnabled = true
    public var height: Double = Constants.Style.PaymentForm.InputBillingFormButton.height.rawValue
    public var width: Double = Constants.Style.PaymentForm.InputBillingFormButton.width.rawValue
    public var textLeading: CGFloat = Constants.Style.PaymentForm.InputBillingFormButton.textLeading.rawValue
    public var borderStyle: ElementBorderStyle = DefaultBorderStyle(normalColor: .clear,
                                                                   focusColor: .clear,
                                                                   errorColor: .clear)
}
