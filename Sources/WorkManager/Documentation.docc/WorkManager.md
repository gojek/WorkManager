# ``WorkManager``

WorkManager is a task scheduler, it allows apps to schedule periodic tasks to perform in certain intervals
of duration, while persisting the tasks throughout app launches, and termination cycles.

WorkManager uses UserDeafult to store the last run time and the interval every time the app comes to the
foreground your app passes control to WorkManager to let it evaluate and run if the task needed to be run
again.

## Usage

### Enqueuing task

WorkManager needs you to register a closure with a unique task id, preferably during the app launch sequence, suggested place would be before returning from `application(_:, didFinishLaunchingWithOptions:) -> Bool`.

```swift
import WorkManager

// Scheduling to perform in every 2 days
WorkManager.shared.enqueueUniquePeriodicWork(id: "com.unique.task.id", interval: 2 * 24 * 60 * 60) {
    cleanUpDisk()
}
```

### Cancelling Task

In case you want to cancel a scheduled task on the fly you could pass the unique id of the task to WorkManager and call cancel

```swift
WorkManager.shared.cancelQueuedPeriodicWork(withId: "com.unique.task.id")
```

WorkManager As of now only performs the tasks in the foreground, it will evaluate every launch time if the time interval has passed against the last run time, which is a response to which it will perform your registered closure.

## Topics

### Types

- ``WorkManager/WorkManager/Task``
