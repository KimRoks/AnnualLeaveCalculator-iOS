//
//  SceneDelegate.swift
//  AnnualLeaveCalculator
//
//  Created by 김경록 on 8/11/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        
        let repository = AnnualLeaveRepositoryImpl()
        let useCase = DefaultAnnualLeaveCalculatorUseCase(annualLeaveRepository: repository)
        let logger = FirebaseAnalyticsLogger()
        let mainViewModel = MainViewModel(calculatorUseCase: useCase, logger: logger)
        let rootViewController = MainViewController(viewModel: mainViewModel)
        let navigationController = LawdingNavigationController(rootViewController: rootViewController)
        window.overrideUserInterfaceStyle = .light
        self.window = window
        
        let splash = SplashViewController()
        window.rootViewController = splash
        
        splash.start(
            minimumDuration: 1.0,
            completion: {
                let main = navigationController
                UIView.transition(
                    with: window,
                    duration: 0.3,
                    options: [.transitionCrossDissolve],
                    animations: {
                        UIView.performWithoutAnimation {
                            window.rootViewController = main
                            window.layoutIfNeeded()
                        }
                    },
                    completion: nil
                )
            }
        )
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        guard let scene = scene as? UIWindowScene else { return }
        let minSupported = "1.1.3"
        let appStoreId = "6751892414"
        let message = "필수 업데이트 적용을 위해 최신 버전으로 업데이트 해주세요."
        
        ForceUpdateGatekeeper.shared.evaluateAndPresentIfNeeded(
            minSupportedVersion: minSupported,
            appStoreId: appStoreId,
            message: message,
            in: scene
        )
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

