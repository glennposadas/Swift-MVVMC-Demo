import Foundation
import RxSwift
import SideMenu

class AppCoordinator: BaseCoordinator<Void> {

    private let sessionService: SessionService
    
    private var drawerMenu: UISideMenuNavigationController? {
        return SideMenuManager.default.menuLeftNavigationController
    }
    
    init(sessionService: SessionService) {
        self.sessionService = sessionService
    }
    
    override func start() -> Maybe<Void> {
        self.sessionService.sessionState == nil
            ? self.showSignIn()
            : self.showDashboard()
        
        self.subscribeToSessionChanges()
        
        return Maybe.never()
    }
    
    private func subscribeToSessionChanges() {
        self.sessionService.didSignIn
            .subscribe(onNext: { [weak self] in self?.showDashboard() })
            .disposed(by: self.disposeBag)
        
        self.sessionService.didSignOut
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                
                if self.drawerMenu?.isHidden ?? true {
                    self.showSignIn()
                } else {
                    self.drawerMenu?.dismiss(animated: true, completion: self.showSignIn)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func showSignIn() {
        self.removeChildCoordinators()
        self.coordinate(to: AppDelegate.container.resolve(SignInCoordinator.self)!)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    private func showDashboard() {
        self.removeChildCoordinators()
        self.coordinate(to: AppDelegate.container.resolve(DrawerMenuCoordinator.self)!)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}