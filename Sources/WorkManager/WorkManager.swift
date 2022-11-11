// Create by Amit Samant on 07/11/22
//
// WorkManager.swift
// WorkManager
//
// Using Swift 5.0
// Copyright © 2022 PT GoJek Indonesia. All rights reserved.
// Licensed under Apache License v2.0
//

import Foundation

public final class WorkManager {
    
    private init() {}
    public static let shared: WorkManager = .init()
    
    private var taskMap: [String: Atomic<Task>] = [:]
    private let workManagerQueue = DispatchQueue(label: "workmanager.taskmap.concurrent", attributes: .concurrent)
    
    public func enqueueUniquePeriodicWork(id: String, interval: TimeInterval, work: @escaping () -> Void, doesNotPerformOnLowPower: Bool = true, onQueue queue: DispatchQueue = DispatchQueue.global(qos: .background)) {
        var task: Atomic<Task>?
        workManagerQueue.sync {
            task = self.taskMap[id]
        }
        if let existingTask = task {
            existingTask.mutate { task in
                task.op = work
                task.doesNotPerformOnLowPower = doesNotPerformOnLowPower
                task.scheduleTimeInterval = interval
                task.schedule()
            }
        } else {
            let newTask = Task(op: work, doesNotPerformOnLowPower: doesNotPerformOnLowPower, id: id, scheduleTimeInterval: interval, queue: queue)
            workManagerQueue.async(flags: .barrier) {
                self.taskMap[id] = Atomic<Task>(newTask)
            }
            newTask.schedule()
        }
    }
    
    public func cancelQueuedPeriodicWork(withId id: String) {
        workManagerQueue.sync {
            taskMap[id]?.value.cancel()
        }
        workManagerQueue.async(flags: .barrier) {
            self.taskMap[id] = nil
        }
    }
}

// MARK: - Task Implementation
extension WorkManager {
    
    public class Task {
        var op: () -> Void
        var doesNotPerformOnLowPower: Bool
        var id: String
        var scheduleTimeInterval: TimeInterval
        var queue: DispatchQueue
        
        private var currentWorkItem: DispatchWorkItem?
        private var lastRunTimeKey: String {
            id + "TimeKey"
        }
        private var lastRunTime: Date? {
            get {
                UserDefaults.standard.value(forKey: lastRunTimeKey) as? Date
            }
            set {
                UserDefaults.standard.set(newValue, forKey: lastRunTimeKey)
            }
        }
        
        public init(op: @escaping () -> Void, doesNotPerformOnLowPower: Bool, id: String, scheduleTimeInterval: TimeInterval, queue: DispatchQueue) {
            self.op = op
            self.doesNotPerformOnLowPower = doesNotPerformOnLowPower
            self.id = id
            self.scheduleTimeInterval = scheduleTimeInterval
            self.queue = queue
            NotificationCenter.default.addObserver(self, selector: #selector(schedule), name: Notification.Name.NSProcessInfoPowerStateDidChange, object: nil)
            
        }
        
        public func perform() {
            if doesNotPerformOnLowPower && ProcessInfo.processInfo.isLowPowerModeEnabled {
                return
            }
            op()
        }
        
        private func reschedule() {
            lastRunTime = Date()
            schedule()
        }
        
        private func performAndReschedule() {
            perform()
            reschedule()
        }
        
        private func scheduleTimer(timeIntervalSinceLastRun: TimeInterval? = nil) {
            // If the required time have not been elapsed the diffrence of time will be user to set a timer after which the startTracing will be called, this is for scenarios where the app has not been killed more than 24 hours, this timer will run every 24 hours and will push out the data
            let timeIntervalSinceLastRun = timeIntervalSinceLastRun ?? 0
            let diffTimeInterval = scheduleTimeInterval - timeIntervalSinceLastRun
            let workItem = DispatchWorkItem(block: self.performAndReschedule)
            queue.asyncAfter(
                deadline: .now() + diffTimeInterval,
                execute: workItem
            )
            currentWorkItem?.cancel()
            currentWorkItem = workItem
        }
        
        private func timeDependentScheduleOrRun(lastRunTime: Date) {
            let timeIntervalSinceLastRun = abs(lastRunTime.timeIntervalSinceNow)
            if timeIntervalSinceLastRun >= scheduleTimeInterval {
                performAndReschedule()
            } else {
                scheduleTimer(timeIntervalSinceLastRun: timeIntervalSinceLastRun)
            }
        }
        
        public func cancel() {
            lastRunTime = nil
            currentWorkItem?.cancel()
        }
        
        @objc public func schedule() {
            guard let lastRunTime = lastRunTime else {
                scheduleTimer()
                return
            }
            timeDependentScheduleOrRun(lastRunTime: lastRunTime)
        }
    }
}

// MARK: - Atomic implementation
extension WorkManager {
    
    final class Atomic<T> {
        
        private let dispatchQueue = DispatchQueue(label: "workmanager.atomic", attributes: .concurrent)
        private var _value: T
        
        init(_ value: T) {
            self._value = value
        }
        
        var value: T { dispatchQueue.sync { _value } }
        
        func mutate(execute task: (inout T) -> Void) {
            dispatchQueue.sync(flags: .barrier) { task(&_value) }
        }
        
        func mapValue<U>(handler: ((T) -> U)) -> U {
            dispatchQueue.sync { handler(_value) }
        }
        
    }
}
