//
//  AppDelegate.swift
//  PostsApp
//
//  Created by Shaikh Taha on 29/04/2026.
//

import UIKit
import RealmSwift
 
@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
 
     
 
    var window: UIWindow?
 
     
 
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureRealm()
         return true
    }
 
     
 
    private func configureRealm() {
         
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { _, oldSchemaVersion in
                 
                if oldSchemaVersion < 1 { }
            }
        )
        Realm.Configuration.defaultConfiguration = config
    }

}
