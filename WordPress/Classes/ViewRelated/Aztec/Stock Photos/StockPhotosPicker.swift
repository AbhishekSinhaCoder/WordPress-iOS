import WPMediaPicker

protocol StockPhotosPickerDelegate: AnyObject {
    func stockPhotosPicker(_ picker: StockPhotosPicker, didFinishPicking assets: [StockPhotosMedia])
}

/// Presents the Stock Photos main interface
final class StockPhotosPicker: NSObject {
    private lazy var dataSource: StockPhotosDataSource = {
        return StockPhotosDataSource(service: stockPhotosService)
    }()

    private lazy var stockPhotosService: StockPhotosService = {
        guard let api = self.blog?.wordPressComRestApi() else {
            //TO DO. Present a user facing error (although in theory we shoul dnever reach this case if we limit Stock Photos to Jetpack blogs only
            return StockPhotosServiceMock()
        }

        return DefaultStockPhotosService(api: api)
    }()

    weak var delegate: StockPhotosPickerDelegate?
    private var blog: Blog?

    private let searchHint = StockPhotosPlaceholder()

    func presentPicker(origin: UIViewController, blog: Blog) {
        self.blog = blog
        let options = WPMediaPickerOptions()
        options.showMostRecentFirst = true
        options.filter = [.all]
        options.allowCaptureOfMedia = false
        options.showSearchBar = true

        let picker = WPNavigationMediaPickerViewController(options: options)
        picker.delegate = self
        picker.startOnGroupSelector = false
        picker.showGroupSelector = false
        picker.dataSource = dataSource

        origin.present(picker, animated: true) {
            picker.mediaPicker.searchBar?.becomeFirstResponder()
        }
    }
}

extension StockPhotosPicker: WPMediaPickerViewControllerDelegate {
    func mediaPickerController(_ picker: WPMediaPickerViewController, didFinishPicking assets: [WPMediaAsset]) {
        guard let stockPhotosMedia = assets as? [StockPhotosMedia] else {
            assertionFailure("assets should be of type `[StockPhotosMedia]`")
            return
        }
        delegate?.stockPhotosPicker(self, didFinishPicking: stockPhotosMedia)
        picker.dismiss(animated: true)
        dataSource.clearSearch(notifyObservers: false)
        hideKeyboard(from: picker.searchBar)
    }

    func emptyView(forMediaPickerController picker: WPMediaPickerViewController) -> UIView? {
        return searchHint
    }

    func mediaPickerControllerDidCancel(_ picker: WPMediaPickerViewController) {
        picker.dismiss(animated: true)
        dataSource.clearSearch(notifyObservers: false)
        hideKeyboard(from: picker.searchBar)
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, didSelect asset: WPMediaAsset) {
        hideKeyboard(from: picker.searchBar)
    }

    func mediaPickerController(_ picker: WPMediaPickerViewController, didDeselect asset: WPMediaAsset) {
        hideKeyboard(from: picker.searchBar)
    }

    private func hideKeyboard(from view: UIView?) {
        if let view = view, view.isFirstResponder {
            //Fix animation conflict between dismissing the keyboard and showing the accessory input view
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                view.resignFirstResponder()
            }
        }
    }
}
