import UIKit
import Checkout

/**
 This class is for billing form list view model logic.
 */

final class DefaultBillingFormViewModel: BillingFormViewModel {

    // MARK: - Properties

    var style: BillingFormStyle
    var updateRow: (() -> Void)?
    var updatedRow: Int? {
        didSet { updateRow?() }
    }
    
    var errorFlagOfCellType = [Int: Bool]()
    var textValueOfCellType = [Int: String]()
    
    weak var editDelegate: BillingFormViewModelEditingDelegate?
    weak var textFieldDelegate: BillingFormTextFieldDelegate?
    weak var delegate: BillingFormViewModelDelegate?

    private var initialCountry: String
    private var initialRegionCode: String?
    private var countryCode: Int = 0

    // MARK: - Public methods

    /**
     Initializes view model with some required protocols

     - Parameters:
        - style: The bill form view Style implementation.
        - initialCountry: //TODO: will be implemented in country ticket
        - initialRegionCode: //TODO: will be implemented in country next ticket
        - delegate: Optional billing form view Model delegate
      */
    
    init(style: BillingFormStyle,
         initialCountry: String = "",
         initialRegionCode: String? = nil,
         delegate: BillingFormViewModelDelegate? = nil) {
        self.style = style
        self.initialCountry = initialCountry
        self.initialRegionCode = initialRegionCode
        self.delegate = delegate
    }
    
    func getHeaderView(delegate: BillingFormHeaderCellDelegate?) -> UIView {
        var style = style.header
        let isDoneButtonEnabled = textValueOfCellType.values.count == self.style.cells.count
        style.doneButton.isEnabled = isDoneButtonEnabled

        let view = BillingFormHeaderCell(style: style, delegate: delegate)
        view.update(style: style)
        self.editDelegate = view
        return view
    }

    func getCell(tableView: UITableView, indexPath: IndexPath, sender: UIViewController?) -> UITableViewCell {
        guard style.cells.count > indexPath.row else { return UITableViewCell() }

        if style.cells[indexPath.row].index == BillingFormCell.country(nil).index {
            return getCountryCell(tableView: tableView, indexPath: indexPath, sender: sender)
        }
        return getTextFieldCell(tableView: tableView, indexPath: indexPath, sender: sender)
    }

    // MARK: - Private methods

    /// Text field cell
    private func getTextFieldCell(tableView: UITableView, indexPath: IndexPath, sender: UIViewController?) -> UITableViewCell {

        /// update style
        updateFilledFields(for: indexPath.row)
        let cellStyle = updateTextFieldStyle(for: indexPath.row)

        // cell
        let cell: CellTextField = tableView.dequeueReusable(for: indexPath)
        cell.delegate = sender as? CellTextFieldDelegate
        cell.update(type: style.cells[indexPath.row],
                    style: cellStyle,
                    tag: indexPath.row)
        return cell
    }

    /// country selection button
    private func getCountryCell(tableView: UITableView, indexPath: IndexPath, sender: UIViewController?) -> UITableViewCell {

        /// update style
        updateFilledFields(for: indexPath.row)
        let cellStyle = updateCountrySelectionStyle(for: indexPath.row)

        /// table view cell
        let cell: CellButton = tableView.dequeueReusable(for: indexPath)
        cell.delegate = sender as? CellButtonDelegate
        cell.update(type: style.cells[indexPath.row],
                    style: cellStyle,
                    tag: indexPath.row)
        return cell
    }

    /// update filled fields with error
    private func updateFilledFields(for row: Int) {
        if style.cells[row].style?.isOptional ?? false {
            let index = style.cells[row].index
            textValueOfCellType[index, default: ""] += ""
            errorFlagOfCellType[index] = false
        }
    }

    /// update text fields with pre-filled text
    private func updateTextFieldStyle(for row: Int) -> CellTextFieldStyle? {
        var viewStyle = style.cells[row].style as? CellTextFieldStyle
        if let text = textValueOfCellType[row] {
            viewStyle?.textfield.text = text
        }
        viewStyle?.error.isHidden = !(errorFlagOfCellType[row] ?? false)
        return viewStyle
    }

    /// update country selection with pre-filled text
    private func updateCountrySelectionStyle(for row: Int) -> CellButtonStyle? {
        var viewStyle = style.cells[row].style as? CellButtonStyle
        if let text = textValueOfCellType[row] {
            viewStyle?.button.text = text
        }
        viewStyle?.error.isHidden = !(errorFlagOfCellType[row] ?? false)
        return viewStyle
    }


    // MARK: - Text Field logic

    func validate(text: String?, cellStyle: BillingFormCell, row: Int)  {
        guard cellStyle.index <= errorFlagOfCellType.count,
              cellStyle.index >= 0,
              let style = cellStyle.style,
              !style.isOptional else {
            errorFlagOfCellType[cellStyle.index] = false
            return
        }
        errorFlagOfCellType[cellStyle.index] = cellStyle.validator.validate(text: text)
    }

    func validateTextFieldByCharacter(textField: UITextField, replacementString string: String) {
        guard let type = (textField as? BillingFormTextField)?.type else { return }

        validate(text: string , cellStyle: type, row: textField.tag)

        let shouldRemoveText = (textField.text?.count ?? 1 == 1) && !(type.style?.isOptional ?? false)

        if !string.isEmpty {
            textValueOfCellType[type.index] = string
        } else if shouldRemoveText {
            textValueOfCellType[type.index] = nil
        }

        let hasErrorValue = errorFlagOfCellType.isEmpty || errorFlagOfCellType.values.allSatisfy({$0})

        let areAllFieldsAreFulfilled = textValueOfCellType.values.count == style.cells.count && !hasErrorValue

        editDelegate?.didFinishEditingBillingForm(successfully:  areAllFieldsAreFulfilled)
    }

    private func validateTextOnEndEditing(textField: BillingFormTextField) {
        guard let type = textField.type else { return }

        validate(text: textField.text , cellStyle: type, row: textField.tag)

        let shouldSaveText = !(textField.text?.isEmpty ?? true) || (type.style?.isOptional ?? false)

        textValueOfCellType[type.index] =  shouldSaveText ? textField.text : nil

        updatedRow = textField.type?.index
    }
}

// MARK: - Table View Delegate

extension DefaultBillingFormViewModel: BillingFormTableViewDelegate {
    func tableView(estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(numberOfRowsInSection section: Int) -> Int {
        style.cells.count
    }

    func tableView(tableView: UITableView, cellForRowAt indexPath: IndexPath, sender: UIViewController) -> UITableViewCell {
        getCell(tableView: tableView, indexPath: indexPath, sender: sender)
    }
}

// MARK: - Text View Delegate

extension DefaultBillingFormViewModel: BillingFormTextFieldDelegate {
    func textFieldShouldEndEditing(textField: BillingFormTextField, replacementString: String) {
        validateTextOnEndEditing(textField: textField)
    }

    func textFieldShouldChangeCharactersIn(textField: UITextField, replacementString string: String) {
        validateTextFieldByCharacter(textField: textField, replacementString: string)
    }
}

// MARK: - Billing form view controller Delegate

extension DefaultBillingFormViewModel: BillingFormViewControllerDelegate {
    func update(country: String, regionCode: String) {
        let index = BillingFormCell.country(nil).index
        textValueOfCellType[index] = country
        updatedRow = index
    }

    func getViewForHeader(sender: UIViewController) -> UIView? {
        return getHeaderView(delegate: sender as? BillingFormHeaderCellDelegate)
    }

    func doneButtonIsPressed(sender: UIViewController) {
        
        let phone = Phone(
            number: textValueOfCellType[BillingFormCell.phoneNumber(nil).index],
            country: nil)
        
        let address = Address(
            addressLine1: textValueOfCellType[BillingFormCell.addressLine1(nil).index],
            addressLine2: textValueOfCellType[BillingFormCell.addressLine2(nil).index],
            city: textValueOfCellType[BillingFormCell.city(nil).index],
            state: textValueOfCellType[BillingFormCell.state(nil).index],
            zip: textValueOfCellType[BillingFormCell.postcode(nil).index],
            country: nil)

        delegate?.onTapDoneButton(address: address, phone: phone)
        sender.dismiss(animated: true)
    }
    
    func cancelButtonIsPressed(sender: UIViewController) {
        sender.dismiss(animated: true)
    }
}
