import WordPressAuthenticator


protocol JetpackRemoteInstallDelegate: class {
    func jetpackRemoteInstallCompleted()
    func jetpackRemoteInstallCanceled()
}

class JetpackRemoteInstallViewController: UIViewController {
    private weak var delegate: JetpackRemoteInstallDelegate?
    private var promptType: JetpackLoginPromptType
    private var blog: Blog
    private let jetpackView = JetpackRemoteInstallView()
    private let viewModel: JetpackRemoteInstallViewModel

    @IBOutlet private var segmented: UISegmentedControl!

    init(blog: Blog, delegate: JetpackRemoteInstallDelegate?, promptType: JetpackLoginPromptType) {
        self.blog = blog
        self.delegate = delegate
        self.promptType = promptType
        self.viewModel = JetpackRemoteInstallViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupUI()
        setupViewModel()
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        jetpackView.toggleHidingImageView(for: newCollection)
    }
}

// MARK: - Private functions

private extension JetpackRemoteInstallViewController {
    func setupNavigationBar() {
        title = NSLocalizedString("Jetpack", comment: "Title for the Jetpack Installation")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancel))
    }

    func setupUI() {
        view.backgroundColor = WPStyleGuide.itsEverywhereGrey()

        jetpackView.delegate = self
        add(jetpackView)

        jetpackView.toggleHidingImageView(for: traitCollection)

        view.bringSubviewToFront(segmented)
    }

    func setupViewModel() {
        viewModel.onChangeState = { [weak self] state in
            DispatchQueue.main.async {
                self?.jetpackView.setupView(for: state)
            }

            if case let .failure(error) = state {
                if error.isBlockingError {
                    self?.openInstallJetpackURL()
                }
            }
        }
        viewModel.viewReady()
    }

    func openInstallJetpackURL() {
        let controller = JetpackConnectionWebViewController(blog: blog)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    @objc func cancel() {
        delegate?.jetpackRemoteInstallCanceled()
    }
}

// MARK: - Jetpack Connection Web Delegate

extension JetpackRemoteInstallViewController: JetpackConnectionWebDelegate {
    func jetpackConnectionCanceled() {
        delegate?.jetpackRemoteInstallCanceled()
    }

    func jetpackConnectionCompleted() {
        delegate?.jetpackRemoteInstallCompleted()
    }
}

// MARK: - Jetpack View delegate

extension JetpackRemoteInstallViewController: JetpackRemoteInstallViewDelegate {
    func mainButtonDidTouch() {

    }

    func customerSupportButtonDidTouch() {

    }
}

// This is just for manual testing purpose
// It will be removed
private extension JetpackRemoteInstallViewController {
    @IBAction func stateChange(_ sender: UISegmentedControl) {
        viewModel.testState(sender.selectedSegmentIndex)
    }
}