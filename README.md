# WorkManager

[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager) [![Build](https://github.com/gojekfarm/WorkManager/actions/workflows/Build.yml/badge.svg)](https://github.com/gojekfarm/WorkManager/actions/workflows/Build.yml) [![CocoaPods Version](https://img.shields.io/cocoapods/v/WorkManager.svg?style=flat)](http://cocoadocs.org/docsets/WorkManager)

WorkManager is a task scheduler, it allows apps to schedule periodic tasks to perform in certain intervals of duration, while persisting the tasks throughout app launches, and termination cycles.

WorkManager uses UserDeafult to store the last run time and the interval every time the app comes to the foreground your app passes control to WorkManager to let it evaluate and run if the task needed to be run again.

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into `swift`.
To add a package dependency to your Xcode project, select File > Swift Packages > Add Package Dependency and enter below repository URL

```
https://github.com/gojek/WorkManager.git
```


Once you have your Swift package set up, adding WorkManager as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/gojek/WorkManager.git", .upToNextMajor(from: "0.10.0"))
]
```

### Cocoapods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate WorkManager into your Xcode project using CocoaPods, specify the following pod in your Podfile:

```ruby
pod 'WorkManager'
```

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

## Contributing

As the creators, and maintainers of this project, we're glad to invite contributors to help us stay up to date. Please take a moment to review [the contributing document](https://github.com/gojek/WorkManager/blob/main/.github/CONTRIBUTING.md) in order to make the contribution process easy and effective for everyone involved.

- If you **found a bug**, open an [issue](https://github.com/gojek/WorkManager/issues).
- If you **have a feature request**, open an [issue](https://github.com/gojek/WorkManager/issues).
- If you **want to contribute**, submit a [pull request](https://github.com/gojek/WorkManager/pulls).

## License

**WorkManager** is available under the MIT license. See the [LICENSE](https://github.com/gojek/WorkManager/blob/main/LICENSE) file for more info.
