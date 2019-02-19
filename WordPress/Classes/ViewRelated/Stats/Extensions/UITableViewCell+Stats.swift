import Foundation

/// Convenience enum to easily indicate what type of rows are being added.
///
enum StatType: Int {
    case insights
    case period
}

extension UITableViewCell {

    func addRows(_ dataRows: [StatsTotalRowData],
                 toStackView rowsStackView: UIStackView,
                 forType statType: StatType,
                 limitRowsDisplayed: Bool = true,
                 rowDelegate: StatsTotalRowDelegate? = nil) {

        let numberOfDataRows = dataRows.count

        guard numberOfDataRows > 0 else {
            let row = StatsNoDataRow.loadFromNib()
            row.configure(forType: statType)
            rowsStackView.addArrangedSubview(row)
            return
        }

        let maxRows = maxRowsToDisplay()

        let numberOfRowsToAdd: Int = {
            if limitRowsDisplayed {
                return numberOfDataRows > maxRows ? maxRows : numberOfDataRows
            }

            return numberOfDataRows
        }()

        for index in 0..<numberOfRowsToAdd {
            let dataRow = dataRows[index]
            let row = StatsTotalRow.loadFromNib()
            row.configure(rowData: dataRow, delegate: rowDelegate)

            // Don't show the separator line on the last row.
            if index == (numberOfRowsToAdd - 1) {
                row.showSeparator = false
            }

            rowsStackView.addArrangedSubview(row)
        }

        // If there are more data rows, show 'View more'.
        if limitRowsDisplayed && numberOfDataRows > maxRows {
            addViewMoreToStackView(rowsStackView, withStatSection: dataRows.first?.statSection)
        }
    }

    func removeRowsFromStackView(_ rowsStackView: UIStackView) {
        rowsStackView.arrangedSubviews.forEach {
            rowsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }

    func addViewMoreToStackView(_ rowsStackView: UIStackView, withStatSection statSection: StatSection?) {
        let row = ViewMoreRow.loadFromNib()
        row.configure(statSection: statSection)
        rowsStackView.addArrangedSubview(row)
    }

    func maxRowsToDisplay() -> Int {
        return 6
    }

}
