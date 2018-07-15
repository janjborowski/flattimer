//
//  DIContainer.swift
//  FlatTimer
//
//  Created by Jan Borowski on 15.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import Swinject
import SwinjectStoryboard

final class DIContainer {

    let container = SwinjectStoryboard.defaultContainer

    init() {
        registerViewModels()
        registerControllers()
    }

    private func registerViewModels() {
        container.register(CircleTimerViewModel.self) { (resolver) in
            return CircleTimerViewModel()
        }
    }

    private func registerControllers() {
        container.storyboardInitCompleted(CircleTimerViewController.self) { (resolver, controller) in
            controller.viewModel = resolver.resolve(CircleTimerViewModel.self)!
        }
    }

}
