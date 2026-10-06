# TrisNotificationKit

TrisNotificationKit is a small, reusable Swift Package for iOS local notifications.

It provides a thin wrapper around `UserNotifications` for checking notification permission, requesting permission, sending immediate local notifications, scheduling one-time local notifications, cancelling pending notifications, and removing delivered notifications.

The package is intentionally domain-agnostic. It does not know about workouts, places, arrivals, departures, or any other app-specific concept. Host apps and feature packages provide their own notification title and body.

This makes the package reusable from modules such as TrisPlaceRecognitionKit, WakTrainer, or any other iOS app/SPM that needs local notifications without owning `UNUserNotificationCenter` directly.

## Requirements

- iOS 17+
- Swift Package Manager

## Installation

Add the package in Xcode with **File > Add Package Dependencies** and use:

```text
https://github.com/iosdevbyul/TrisNotificationKit
```

If you manage dependencies in `Package.swift`, the current repository can be added from `main`:

```swift
dependencies: [
    .package(
        url: "https://github.com/iosdevbyul/TrisNotificationKit",
        branch: "main"
    )
]
```

Then add the library product to the consuming target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(
            name: "TrisNotificationKit",
            package: "TrisNotificationKit"
        )
    ]
)
```

Import it where needed:

```swift
import TrisNotificationKit
```

## Permission Model

TrisNotificationKit does **not** request notification permission automatically.

Calling `send` or `schedule` never triggers the system permission prompt. The host app decides when permission should be requested and must call `requestPermission()` explicitly.

### Check Permission Status

```swift
let notificationService = LocalNotificationService()

let status = await notificationService.permissionStatus()

switch status {
case .notDetermined:
    print("Permission has not been requested.")

case .denied:
    print("Notification permission is denied.")

case .authorized:
    print("Notification permission is authorized.")

case .provisional:
    print("Notification permission is provisional.")

case .ephemeral:
    print("Notification permission is ephemeral.")

case .unknown:
    print("Notification permission status is unknown.")
}
```

### Request Permission

`requestPermission()` requests alert and sound authorization.

```swift
let notificationService = LocalNotificationService()

let granted = try await notificationService.requestPermission()
```

The package does not decide when this method should be called. Permission timing belongs to the host app.

## Immediate Notification

Send an immediate local notification:

```swift
let notificationService = LocalNotificationService()

try await notificationService.send(
    title: "Workout time",
    body: "Your workout is ready to start."
)
```

An immediate notification uses a `UNNotificationRequest` with no trigger.

## Identifiers

Every notification request has an identifier.

### Provide an Identifier

Use an explicit identifier when the caller needs deterministic cancellation or replacement behavior:

```swift
let identifier = try await notificationService.send(
    title: "Workout time",
    body: "Your workout is ready to start.",
    identifier: "workout.reminder"
)
```

### Generate an Identifier Automatically

When the identifier is omitted, `LocalNotificationService` generates a UUID string and returns it:

```swift
let identifier = try await notificationService.send(
    title: "Workout time",
    body: "Your workout is ready to start."
)
```

Store the returned identifier if you may need to cancel or remove that notification later.

## Scheduled Notification

Schedule a one-time local notification for a specific `Date`:

```swift
let identifier = try await notificationService.schedule(
    title: "Workout reminder",
    body: "It is time for your planned workout.",
    at: notificationDate
)
```

You can also provide your own identifier:

```swift
try await notificationService.schedule(
    title: "Workout reminder",
    body: "It is time for your planned workout.",
    at: notificationDate,
    identifier: "workout.evening"
)
```

Scheduled notifications use `UNCalendarNotificationTrigger` with `repeats: false`.

## Sound

Calls that omit the `sound` argument keep the existing behavior and use the default system notification sound.

Enable sound explicitly:

```swift
try await notificationService.send(
    title: "Reminder",
    body: "This notification uses the default sound.",
    sound: true
)
```

Send a silent notification:

```swift
try await notificationService.send(
    title: "Background update",
    body: "This notification is silent.",
    sound: false
)
```

The same option is available for scheduled notifications:

```swift
try await notificationService.schedule(
    title: "Silent reminder",
    body: "This scheduled notification is silent.",
    at: notificationDate,
    sound: false
)
```

`sound: true` uses `UNNotificationSound.default`. `sound: false` leaves the notification sound unset.

## Cancel a Pending Notification

Remove a pending notification request by identifier:

```swift
notificationService.cancel(
    identifier: "workout.evening"
)
```

This removes the matching pending request from `UNUserNotificationCenter`.

## Remove a Delivered Notification

Remove a notification that has already been delivered:

```swift
notificationService.removeDelivered(
    identifier: "workout.evening"
)
```

Pending cancellation and delivered-notification removal are intentionally separate operations.

## Host-Owned Content

TrisNotificationKit does not generate, localize, or rewrite notification content.

The caller supplies the exact `title` and `body`:

```swift
try await notificationService.send(
    title: title,
    body: body
)
```

This keeps app-specific wording and localization outside the package.

For example:

- TrisPlaceRecognitionKit can decide how an arrival or departure should be described.
- WakTrainer can decide how a workout reminder should be described.
- TrisNotificationKit only handles the local-notification delivery mechanism.

## Public API

### `NotificationPermissionStatus`

```swift
public enum NotificationPermissionStatus: Sendable, Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
    case unknown
}
```

### `LocalNotificationServiceProtocol`

The protocol exposes:

```swift
func permissionStatus() async -> NotificationPermissionStatus

func requestPermission() async throws -> Bool

func send(
    title: String,
    body: String,
    identifier: String
) async throws -> String

func send(
    title: String,
    body: String,
    identifier: String,
    sound: Bool
) async throws -> String

func schedule(
    title: String,
    body: String,
    at date: Date,
    identifier: String
) async throws -> String

func schedule(
    title: String,
    body: String,
    at date: Date,
    identifier: String,
    sound: Bool
) async throws -> String

func cancel(identifier: String)

func removeDelivered(identifier: String)
```

### `LocalNotificationService`

`LocalNotificationService` is the default implementation.

```swift
let notificationService = LocalNotificationService()
```

In addition to the protocol operations, it provides UUID-generating convenience overloads:

```swift
func send(
    title: String,
    body: String
) async throws -> String

func send(
    title: String,
    body: String,
    sound: Bool
) async throws -> String

func schedule(
    title: String,
    body: String,
    at date: Date
) async throws -> String

func schedule(
    title: String,
    body: String,
    at date: Date,
    sound: Bool
) async throws -> String
```

## Architecture

The package keeps Apple's notification center behind a small internal client abstraction:

```text
Host App / Feature SPM
        |
        v
LocalNotificationServiceProtocol
        |
        v
LocalNotificationService
        |
        v
NotificationCenterClient
        |
        v
SystemNotificationCenterClient
        |
        v
UNUserNotificationCenter.current()
```

`NotificationCenterClient` and `SystemNotificationCenterClient` are implementation details of the package.

This keeps `UNUserNotificationCenter.current()` out of the public service API and makes `LocalNotificationService` testable with a mock client.

## Testing and CI

The unit tests cover:

- permission-status mapping
- alert/sound authorization options
- immediate notification requests
- UUID identifier generation
- one-time calendar scheduling
- default notification sound
- silent notifications
- pending-notification cancellation
- delivered-notification removal

GitHub Actions runs the package tests for pull requests and pushes to `main`.

The CI workflow selects an available iPhone Simulator dynamically and runs the package with `xcodebuild`, so it does not depend on one hard-coded simulator model or iOS runtime.
