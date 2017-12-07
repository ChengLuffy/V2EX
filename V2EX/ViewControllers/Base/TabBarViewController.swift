import UIKit
import RxSwift
import RxCocoa
import RxOptional

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setAppearance()
        setupTabBar()
        clickBackTop()
        listenNotification()
    }
    
    func listenNotification() {
        
        NotificationCenter.default.rx
            .notification(Notification.Name.V2.UnreadNoticeName)
            .subscribeNext { [weak self] notification in
                guard let count = notification.object as? Int else {
                    return
                }
                
                // 消息控制器显示 badge
                self?.childViewControllers.forEach({ viewController in
                    if viewController.isKind(of: NavigationViewController.self),
                        let nav = viewController as? NavigationViewController,
                        let topVC = nav.topViewController,
                        topVC.isKind(of: MessageViewController.self) {
                        // 如果当前的 badge == 解析到的未读通知， 代表可能已经提示过一次了， 此时不再提示。
                        if viewController.tabBarItem.badgeValue != count.description {
                            HUD.showInfo("您有 \(count) 条未读提醒")
                        }
                        viewController.tabBarItem.badgeValue = count.description
                        return
                    }
                })
            }.disposed(by: rx.disposeBag)
    }
}

extension TabBarViewController {
    
    fileprivate func setAppearance() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : UIColor.hex(0x8a8a8a)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor : Theme.Color.globalColor], for: .selected)

        ThemeStyle.style.asObservable()
            .subscribeNext { [weak self] theme in
                self?.tabBar.barStyle = theme == .day ? .default : .black
            }.disposed(by: rx.disposeBag)
        
        tabBar.isTranslucent = false
    }
    
    fileprivate func setupTabBar() {

        addChildViewController(childController: HomeViewController(),
                               title: "首页",
                               normalImage: #imageLiteral(resourceName: "list"),
                               selectedImageName: #imageLiteral(resourceName: "list_selected"))

        addChildViewController(childController: NodesViewController(),
                               title: "节点",
                               normalImage: #imageLiteral(resourceName: "navigation"),
                               selectedImageName: #imageLiteral(resourceName: "navigation_selected"))

        addChildViewController(childController: MessageViewController(),
                               title: "消息",
                               normalImage: #imageLiteral(resourceName: "notifications"),
                               selectedImageName: #imageLiteral(resourceName: "notifications_selected"))

        addChildViewController(childController: MoreViewController(),
                               title: "更多",
                               normalImage: #imageLiteral(resourceName: "more"),
                               selectedImageName: #imageLiteral(resourceName: "more_selected"))
    }
    
    private func addChildViewController(childController: UIViewController, title: String, normalImage: UIImage?, selectedImageName: UIImage?) {
        childController.tabBarItem.image = normalImage?.withRenderingMode(.alwaysOriginal)
        childController.tabBarItem.selectedImage = selectedImageName?.withRenderingMode(.alwaysOriginal)
        childController.title = title
        let nav = NavigationViewController(rootViewController: childController)
        nav.navigationBar.isTranslucent = false
        addChildViewController(nav)
    }
    
    private func clickBackTop() {
        self.rx.didSelect
            .scan((nil, nil)) { state, viewController in
                return (state.1, viewController)
            }
            // 如果第一次选择视图控制器或再次选择相同的视图控制器
            .filter { state in state.0 == nil || state.0 === state.1 }
            .map { state in state.1 }
            .filterNil()
            .subscribe(onNext: { [weak self] viewController in
                self?.scrollToTop(viewController)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func scrollToTop(_ viewController: UIViewController) {
        if viewController.isKind(of: HomeViewController.self) {
            NotificationCenter.default.post(.init(name: Notification.Name.V2.DidSelectedHomeTabbarItemName))
            return
        }
        if let navigationController = viewController as? UINavigationController {
            let topViewController = navigationController.topViewController
            let firstViewController = navigationController.viewControllers.first
            if let viewController = topViewController, topViewController === firstViewController {
                self.scrollToTop(viewController)
            }
            return
        }
        guard let scrollView = viewController.view.subviews.first as? UIScrollView else { return }
        scrollView.scrollToTop()
    }
}
