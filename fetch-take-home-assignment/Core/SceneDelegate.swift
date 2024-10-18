//
//  SceneDelegate.swift
//  fetch-take-home-assignment
//
//  Created by Charles Prutting on 10/15/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var diContainer: DIContainer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let diContainer = DIContainer()
            self.diContainer = diContainer
            
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            
            let recipesViewModel = RecipesViewModel(recipeAPI: diContainer.recipeAPI, imageLoaderRepository: diContainer.imageLoaderRepository)
            let recipesViewController = RecipesViewController(viewModel: recipesViewModel)
            
            let nav = UINavigationController(rootViewController: recipesViewController)
            
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
    
}

