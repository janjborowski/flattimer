//
//  CircleTimerViewModel.swift
//  FlatTimer
//
//  Created by Jan Borowski on 15.07.2018.
//  Copyright © 2018 Jan Borowski. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class CircleTimerViewModel {

    enum State {

        case animated
        case stopped
        case noAnimation

        var isRunning: Bool {
            return self == .animated
        }

    }

    private let perSecond: TimeInterval = 25
    let maxSeconds = 12

    private let bag = DisposeBag()
    private let executionInProgress = BehaviorSubject<State>(value: .noAnimation)
    private let timerInterval = PublishSubject<Int>()

    private var secondsToIntervals: Observable<Int> {
        return secondsToStart.map { [weak self] (seconds) -> Int in
            guard let perSecond = self?.perSecond else {
                return seconds
            }

            return Int(perSecond) * seconds
        }
    }

    let secondsToStart: BehaviorSubject<Int>

    var executionState: Observable<State> {
        return executionInProgress.asObservable()
    }

    var timerDisplayValue: Observable<String> {
        return Observable.merge(secondsToIntervals, timerInterval)
            .map { Double($0) }
            .map { [weak self] (interval) -> String in
                guard let perSecond = self?.perSecond else {
                    return ""
                }

                let seconds = floor(interval / perSecond)
                let partialSeconds = Int(((interval / perSecond) - seconds) * 100)
                return String(format: "%02.0f", seconds) + ":" + String(format: "%02d", partialSeconds)
        }
    }

    var statusBarStyle: UIStatusBarStyle {
        return (try? executionInProgress.value().isRunning) ?? false ? .lightContent : .default
    }

    init() {
        secondsToStart = BehaviorSubject(value: maxSeconds)

        let period = 1.0 / perSecond
        let timer = Observable<Int>.timer(0, period: period, scheduler: MainScheduler.instance)
        let reversedTimer = Observable.combineLatest(secondsToIntervals, timer)
            .map { $0.0 - $0.1 }

        let countdown = executionInProgress.filter { $0.isRunning }
            .flatMap { [weak self] (_) -> Observable<Int> in
                return reversedTimer.takeWhile { [weak self] (_) -> Bool in
                        let currentValue = try? self?.executionInProgress.value().isRunning
                        return (currentValue ?? false) ?? false
                    }
            }
            .filter { $0 >= 0 }

        countdown.bind(to: timerInterval)
            .disposed(by: bag)

        countdown.filter { $0 <= 0 }
            .map { _ in State.noAnimation }
            .bind(to: executionInProgress)
            .disposed(by: bag)

        executionInProgress.filter { !$0.isRunning }
            .withLatestFrom(secondsToIntervals)
            .bind(to: timerInterval)
            .disposed(by: bag)
    }

    func startTimer() {
        executionInProgress.onNext(.animated)
    }

    func stopTimer() {
        executionInProgress.onNext(.stopped)
    }

}
