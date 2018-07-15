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

    private let timeLength: TimeInterval = 12
    private let perSecond: TimeInterval = 25

    private let bag = DisposeBag()

    private let executionInProgress = BehaviorSubject<Bool>(value: false)
    private let timerInterval = PublishSubject<Int>()

    var isExecuting: Observable<Bool> {
        return executionInProgress.asObservable()
    }

    var statusBarStyle: UIStatusBarStyle {
        return (try? executionInProgress.value()) ?? false ? .lightContent : .default
    }

    var timerDisplayValue: Observable<String> {
        let perSecondObservable = Observable.of(perSecond)
        return Observable.combineLatest(timerInterval, perSecondObservable)
            .map { (data) -> String in
                let interval = data.0
                let perSecond = data.1
                let seconds = interval / Int(perSecond)
                let partialSeconds = Int((Double(interval) / perSecond - Double(seconds)) * 100)
                return String(format: "%02d", seconds) + ":" + String(format: "%02d", partialSeconds)
            }
    }

    init() {
        let period = 1.0 / perSecond
        let maxLength = Int(timeLength * perSecond)
        let lengthObservable = Observable.of(maxLength)
        let timer = Observable<Int>.timer(0, period: period, scheduler: MainScheduler.instance)

        let reversedTimer = Observable.combineLatest(lengthObservable, timer)
            .map { $0.0 - $0.1 }

        let countdown = executionInProgress.filter { $0 }
            .flatMap { [weak self] (_) -> Observable<Int> in
                return reversedTimer.takeWhile { [weak self] (_) -> Bool in
                        let currentValue = try? self?.executionInProgress.value()
                        return (currentValue ?? false) ?? false
                    }
            }
            .filter { $0 >= 0 }

        countdown.bind(to: timerInterval)
            .disposed(by: bag)

        countdown.filter { $0 <= 0 }
            .map { _ in false }
            .bind(to: executionInProgress)
            .disposed(by: bag)

        executionInProgress.filter { !$0 }
            .map { _ in maxLength }
            .bind(to: timerInterval)
            .disposed(by: bag)
    }

    func startTimer() {
        executionInProgress.onNext(true)
    }

    func stopTimer() {
        executionInProgress.onNext(false)
    }

}
