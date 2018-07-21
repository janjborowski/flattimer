//
//  CircleTimerViewController.swift
//  FlatTimer
//
//  Created by Jan Borowski on 15.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class CircleTimerViewController: UIViewController {

    private let bag = DisposeBag()

    var viewModel: CircleTimerViewModel!

    @IBOutlet weak var circleTimerView: CircleTimerView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewModel.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()

        circleTimerView.numberOfMarkers = viewModel.maxSeconds
    }

    private func subscribe() {
        let executionInProgress = viewModel.isExecuting.filter { $0 }
        let noExecution = viewModel.isExecuting.filter { !$0 }

        executionInProgress.map { _ in "STOP" }
            .bind(to: startButton.rx.title(for: .normal))
            .disposed(by: bag)

        noExecution.map { _ in "START" }
            .bind(to: startButton.rx.title(for: .normal))
            .disposed(by: bag)

        executionInProgress.subscribe(onNext: { [weak self] (_) in
                self?.startButton.backgroundColor = .darkOrange
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.backgroundColor = .darkBlue
                })
                self?.setNeedsStatusBarAppearanceUpdate()
            })
            .disposed(by: bag)

        noExecution.subscribe(onNext: { [weak self] (_) in
                self?.startButton.backgroundColor = .lightOrange
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.backgroundColor = .darkOrange
                })
                self?.setNeedsStatusBarAppearanceUpdate()
            })
            .disposed(by: bag)

        let buttonTapOnExecuting = startButton.rx.tap.asObservable()
            .withLatestFrom(viewModel.isExecuting).share()

        buttonTapOnExecuting.filter { !$0 }
            .withLatestFrom(viewModel.secondsToStart)
            .subscribe(onNext: { [weak self] (interval) in
                self?.circleTimerView.startAnimation(duration: TimeInterval(interval))
                self?.viewModel.startTimer()
            })
            .disposed(by: bag)

        buttonTapOnExecuting.filter { $0 }
            .subscribe(onNext: { [weak self] (_) in
                self?.viewModel.stopTimer()
                self?.circleTimerView.stopAnimation()
            })
            .disposed(by: bag)

        circleTimerView.part
            .bind(to: viewModel.secondsToStart)
            .disposed(by: bag)

        viewModel.isExecuting
            .bind(to: circleTimerView.isBlocked)
            .disposed(by: bag)

        viewModel.timerDisplayValue
            .bind(to: timerLabel.rx.text)
            .disposed(by: bag)
    }

}
