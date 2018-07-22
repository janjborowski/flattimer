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

    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var circleTimerView: CircleTimerView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return viewModel.statusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()

        circleTimerView.update(numberOfMarkers: viewModel.maxSeconds)
    }

    private func subscribe() {
        let isRunning = viewModel.executionState.map { $0.isRunning }
        let running = isRunning.filter { $0 }
        let notRunning = isRunning.filter { !$0 }

        running.map { _ in "STOP" }
            .bind(to: startButton.rx.title(for: .normal))
            .disposed(by: bag)

        notRunning.map { _ in "START" }
            .bind(to: startButton.rx.title(for: .normal))
            .disposed(by: bag)

        running.subscribe(onNext: { [weak self] (_) in
                self?.startButton.backgroundColor = .darkOrange
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.backgroundColor = .darkBlue
                })
                self?.setNeedsStatusBarAppearanceUpdate()
            })
            .disposed(by: bag)

        notRunning.subscribe(onNext: { [weak self] (_) in
                self?.startButton.backgroundColor = .lightOrange
                UIView.animate(withDuration: 0.2, animations: {
                    self?.view.backgroundColor = .darkOrange
                })
                self?.setNeedsStatusBarAppearanceUpdate()
            })
            .disposed(by: bag)

        isRunning.bind(to: circleTimerView.isBlocked)
            .disposed(by: bag)

        viewModel.executionState
            .filter { $0 == .noAnimation }
            .skip(1)
            .subscribe(onNext: { [weak self] (_) in
                guard let weakSelf = self else {
                    return
                }

                weakSelf.executeFlashAnimation()
            })
            .disposed(by: bag)


        let buttonTapOnExecuting = startButton.rx.tap.asObservable()
            .withLatestFrom(isRunning).share()

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

        viewModel.timerDisplayValue
            .bind(to: timerLabel.rx.text)
            .disposed(by: bag)
    }

    private func executeFlashAnimation() {
        guard let flashView = flashView else {
            return
        }

        flashView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            flashView.alpha = 1
        }) { (_) in
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                flashView.alpha = 0
            }, completion: { (_) in
                flashView.isHidden = true
            })
        }
    }

}
