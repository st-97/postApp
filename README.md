PostsApp

A modern iOS application built using UIKit, MVVM, and Coordinator architecture, featuring Posts, Favorites, Authentication, and offline-first support using Realm with reactive programming powered by RxSwift.

------------------------------------------------------------
FEATURES
------------------------------------------------------------

- Login / Authentication flow
- Fetch and display posts from API
- Add / remove favorites
- Offline persistence using Realm
- Reactive UI updates using RxSwift / RxCocoa
- Coordinator-based navigation flow
- Tab bar architecture (Posts + Favorites)
- Post detail screen with comments
- Swipe to delete favorites
- Smooth and reactive table updates

------------------------------------------------------------
ARCHITECTURE
------------------------------------------------------------

AppCoordinator
   ↓
LoginCoordinator / MainTabCoordinator
   ↓
PostsCoordinator / FavoritesCoordinator
   ↓
ViewControllers (Storyboard + XIB Cells)
   ↓
ViewModels (RxSwift)
   ↓
Repository Layer
   ↓
NetworkService + Realm Database

Design Patterns Used:
- MVVM
- Coordinator Pattern
- Repository Pattern
- Dependency Injection
- Reactive Programming (RxSwift)

------------------------------------------------------------
PROJECT STRUCTURE
------------------------------------------------------------

App
- AppDelegate.swift
- SceneDelegate.swift

Coordinator
- AppCoordinator.swift
- LoginCoordinator.swift
- MainTabCoordinator.swift
- PostsCoordinator.swift
- FavoritesCoordinator.swift

Modules

Login
- LoginViewController.swift
- LoginViewModel.swift
- LoginViewModelProtocol.swift

Posts
- PostsViewController.swift
- PostsViewModel.swift
- PostDetailViewController.swift
- PostDetailViewModel.swift
- PostDetailsViewModel.swift

Favorites
- FavoritesViewController.swift
- FavoritesViewModel.swift

Data
- PostRepo.swift
- Post.swift

Core

Networking
- NetworkService.swift
- Endpoints.swift
- NetworkErrors.swift

Database
- RealmObjects.swift
- Databaseservice.swift

AppSession
- SessionManager.swift

UIComponents

Cells
- PostTableViewCell.swift
- PostTableViewCell.xib
- CommentsCell.swift
- CommentsCell.xib

General
- PAButton.swift
- PATextField.swift
- PAErrorLabel.swift

Utils
- AppTheme.swift

Storyboards
- Main.storyboard
- LaunchScreen.storyboard

Assets
- AppIcon
- AccentColor

------------------------------------------------------------
NETWORKING
------------------------------------------------------------

- URLSession based networking
- Endpoint abstraction
- Centralized error handling

------------------------------------------------------------
DATABASE (REALM)
------------------------------------------------------------

- Offline storage for posts
- Favorite persistence
- Object mapping between Realm and domain models

------------------------------------------------------------
NAVIGATION FLOW
------------------------------------------------------------

App Launch
   ↓
AppCoordinator
   ↓
Login OR MainTabCoordinator
   ↓
Posts Tab / Favorites Tab
   ↓
Post Detail Screen

------------------------------------------------------------
TECH STACK
------------------------------------------------------------

- Swift 5+
- UIKit (Storyboard + XIB)
- RxSwift / RxCocoa
- RealmSwift
- URLSession
- MVVM Architecture
- Coordinator Pattern

------------------------------------------------------------
HIGHLIGHTS
------------------------------------------------------------

- Clean scalable architecture
- Fully reactive UI updates
- Offline-first support
- Modular design
- Production-ready structure
- Separation of concerns (UI / Logic / Data)

------------------------------------------------------------
TESTING
------------------------------------------------------------

- Unit Tests (PostsAppTests)
- UI Tests (PostsAppUITests)
- Launch Tests

------------------------------------------------------------
AUTHOR
------------------------------------------------------------

Shaikh Taha

------------------------------------------------------------
NOTE
------------------------------------------------------------

This project is built as a production-grade iOS architecture template demonstrating real-world scalable patterns used in professional applications.
