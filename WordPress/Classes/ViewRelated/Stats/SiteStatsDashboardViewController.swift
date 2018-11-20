import UIKit
import WordPressComStatsiOS

class SiteStatsDashboardViewController: UIViewController {

    // MARK: - Properties

    @objc var siteID: NSNumber?
    @objc var siteTimeZone: TimeZone?
    @objc var oauth2Token: String?

    @IBOutlet weak var filterTabBar: FilterTabBar!
    @IBOutlet weak var insightsContainerView: UIView!
    @IBOutlet weak var statsContainerView: UIView!

    var insightsTableViewController: SiteStatsInsightsTableViewController?

    // TODO: replace UITableViewController with real controller names that
    // corresponds to Stats.

    var statsTableViewController: UITableViewController?

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFilterBar()
        getSelectedPeriodFromUserDefaults()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let insightsTableVC = segue.destination as? SiteStatsInsightsTableViewController {
            insightsTableVC.statsService = initStatsService()
            insightsTableViewController = insightsTableVC
        }
    }

}

// MARK: - Private Extension

private extension SiteStatsDashboardViewController {

    struct Constants {
        static let userDefaultsKey = "LastSelectedStatsPeriodType"
        static let progressViewInitialProgress = Float(0.03)
        static let progressViewHideDelay = 1
        static let progressViewHideDuration = 0.15
        static let cacheExpirationInterval = Double(300)
    }

    enum StatsPeriodType: Int {
        case insights = 0
        case days = 1
        case weeks = 2
        case months = 3
        case years = 4

        static let allPeriods = [StatsPeriodType.insights, .days, .weeks, .months, .years]

        var filterTitle: String {
            switch self {
            case .insights: return NSLocalizedString("Insights", comment: "Title of Insights stats filter.")
            case .days: return NSLocalizedString("Days", comment: "Title of Days stats filter.")
            case .weeks: return NSLocalizedString("Weeks", comment: "Title of Weeks stats filter.")
            case .months: return NSLocalizedString("Months", comment: "Title of Months stats filter.")
            case .years: return NSLocalizedString("Years", comment: "Title of Years stats filter.")
            }
        }
    }

    var currentSelectedPeriod: StatsPeriodType {
        get {
            let selectedIndex = filterTabBar?.selectedIndex ?? StatsPeriodType.insights.rawValue
            return StatsPeriodType(rawValue: selectedIndex) ?? .insights
        }
        set {
            filterTabBar?.setSelectedIndex(newValue.rawValue)
            setContainerViewVisibility()
            saveSelectedPeriodToUserDefaults()
        }
    }

    func setContainerViewVisibility() {
        statsContainerView.isHidden = currentSelectedPeriod == .insights
        insightsContainerView.isHidden = !statsContainerView.isHidden
    }

    func shouldShowProgressView(viewController: UIViewController) -> Bool {

        var shouldShow = false

        if viewController == insightsTableViewController {
            shouldShow = !insightsContainerView.isHidden
        } else if viewController == statsTableViewController {
            shouldShow = !statsContainerView.isHidden
        }

        return shouldShow
    }

    func initStatsService() -> WPStatsService? {

        guard let siteID = siteID,
            let siteTimeZone = siteTimeZone,
            let oauth2Token = oauth2Token else {
            return nil
        }

        return WPStatsService.init(siteId: siteID,
                                   siteTimeZone: siteTimeZone,
                                   oauth2Token: oauth2Token,
                                   andCacheExpirationInterval: Constants.cacheExpirationInterval)
    }
}

// MARK: - FilterTabBar Support

private extension SiteStatsDashboardViewController {

    func setupFilterBar() {
        filterTabBar.tintColor = WPStyleGuide.wordPressBlue()
        filterTabBar.deselectedTabColor = WPStyleGuide.greyDarken10()
        filterTabBar.dividerColor = WPStyleGuide.greyLighten20()

        filterTabBar.items = StatsPeriodType.allPeriods.map { $0.filterTitle }
        filterTabBar.addTarget(self, action: #selector(selectedFilterDidChange(_:)), for: .valueChanged)
    }

    @objc func selectedFilterDidChange(_ filterBar: FilterTabBar) {
        currentSelectedPeriod = StatsPeriodType(rawValue: filterBar.selectedIndex) ?? StatsPeriodType.insights

        // TODO: reload view based on selected tab
    }

}

// MARK: - User Defaults Support

private extension SiteStatsDashboardViewController {

    func saveSelectedPeriodToUserDefaults() {
        UserDefaults.standard.set(currentSelectedPeriod.rawValue, forKey: Constants.userDefaultsKey)
    }

    func getSelectedPeriodFromUserDefaults() {
        currentSelectedPeriod = StatsPeriodType(rawValue: UserDefaults.standard.integer(forKey: Constants.userDefaultsKey)) ?? .insights
    }
}
