import XCTest
import UserNotifications
@testable import TrisNotificationKit

final class LocalNotificationServiceTests: XCTestCase {

    func testPermissionStatusReturnsNotDetermined() async {
        let client = MockNotificationCenterClient()
        client.authorizationStatusValue = .notDetermined

        let service = LocalNotificationService(
            client: client
        )

        let status = await service.permissionStatus()

        XCTAssertEqual(
            status,
            .notDetermined
        )
    }

    func testPermissionStatusReturnsDenied() async {
        let client = MockNotificationCenterClient()
        client.authorizationStatusValue = .denied

        let service = LocalNotificationService(
            client: client
        )

        let status = await service.permissionStatus()

        XCTAssertEqual(
            status,
            .denied
        )
    }

    func testPermissionStatusReturnsAuthorized() async {
        let client = MockNotificationCenterClient()
        client.authorizationStatusValue = .authorized

        let service = LocalNotificationService(
            client: client
        )

        let status = await service.permissionStatus()

        XCTAssertEqual(
            status,
            .authorized
        )
    }

    func testRequestPermissionUsesAlertAndSoundOptions() async throws {
        let client = MockNotificationCenterClient()
        client.requestAuthorizationResult = true

        let service = LocalNotificationService(
            client: client
        )

        let granted = try await service.requestPermission()

        XCTAssertTrue(granted)

        XCTAssertEqual(
            client.requestedAuthorizationOptions,
            [.alert, .sound]
        )
    }

    func testSendCreatesImmediateNotificationRequest() async throws {
        let client = MockNotificationCenterClient()

        let service = LocalNotificationService(
            client: client
        )

        let identifier = try await service.send(
            title: "Test Title",
            body: "Test Body",
            identifier: "test.notification"
        )

        XCTAssertEqual(
            identifier,
            "test.notification"
        )

        let request = try XCTUnwrap(
            client.addedRequests.first
        )

        XCTAssertEqual(
            request.identifier,
            "test.notification"
        )

        XCTAssertEqual(
            request.content.title,
            "Test Title"
        )

        XCTAssertEqual(
            request.content.body,
            "Test Body"
        )

        XCTAssertNil(
            request.trigger
        )

        XCTAssertEqual(
            request.content.sound,
            .default
        )
    }

    func testSendWithoutIdentifierGeneratesIdentifier() async throws {
        let client = MockNotificationCenterClient()

        let service = LocalNotificationService(
            client: client
        )

        let identifier = try await service.send(
            title: "Test Title",
            body: "Test Body"
        )

        XCTAssertFalse(
            identifier.isEmpty
        )

        let request = try XCTUnwrap(
            client.addedRequests.first
        )

        XCTAssertEqual(
            request.identifier,
            identifier
        )
    }

    func testScheduleCreatesCalendarNotificationRequest() async throws {
        let client = MockNotificationCenterClient()

        let service = LocalNotificationService(
            client: client
        )

        let calendar = Calendar(
            identifier: .gregorian
        )

        let date = try XCTUnwrap(
            calendar.date(
                from: DateComponents(
                    year: 2026,
                    month: 10,
                    day: 10,
                    hour: 18,
                    minute: 30,
                    second: 0
                )
            )
        )

        let identifier = try await service.schedule(
            title: "Scheduled Title",
            body: "Scheduled Body",
            at: date,
            identifier: "scheduled.notification"
        )

        XCTAssertEqual(
            identifier,
            "scheduled.notification"
        )

        let request = try XCTUnwrap(
            client.addedRequests.first
        )

        XCTAssertEqual(
            request.identifier,
            "scheduled.notification"
        )

        XCTAssertEqual(
            request.content.title,
            "Scheduled Title"
        )

        XCTAssertEqual(
            request.content.body,
            "Scheduled Body"
        )

        let trigger = try XCTUnwrap(
            request.trigger as? UNCalendarNotificationTrigger
        )

        XCTAssertFalse(
            trigger.repeats
        )

        XCTAssertEqual(
            trigger.dateComponents.year,
            2026
        )

        XCTAssertEqual(
            trigger.dateComponents.month,
            10
        )

        XCTAssertEqual(
            trigger.dateComponents.day,
            10
        )

        XCTAssertEqual(
            trigger.dateComponents.hour,
            18
        )

        XCTAssertEqual(
            trigger.dateComponents.minute,
            30
        )
    }

    func testCancelRemovesPendingNotification() {
        let client = MockNotificationCenterClient()

        let service = LocalNotificationService(
            client: client
        )

        service.cancel(
            identifier: "pending.notification"
        )

        XCTAssertEqual(
            client.removedPendingIdentifiers,
            ["pending.notification"]
        )
    }

    func testRemoveDeliveredRemovesDeliveredNotification() {
        let client = MockNotificationCenterClient()

        let service = LocalNotificationService(
            client: client
        )

        service.removeDelivered(
            identifier: "delivered.notification"
        )

        XCTAssertEqual(
            client.removedDeliveredIdentifiers,
            ["delivered.notification"]
        )
    }
}

private final class MockNotificationCenterClient: NotificationCenterClient {

    var authorizationStatusValue: UNAuthorizationStatus = .notDetermined

    var requestAuthorizationResult = false

    var requestedAuthorizationOptions: UNAuthorizationOptions?

    var addedRequests: [UNNotificationRequest] = []

    var removedPendingIdentifiers: [String] = []

    var removedDeliveredIdentifiers: [String] = []

    func authorizationStatus() async -> UNAuthorizationStatus {
        authorizationStatusValue
    }

    func requestAuthorization(
        options: UNAuthorizationOptions
    ) async throws -> Bool {
        requestedAuthorizationOptions = options

        return requestAuthorizationResult
    }

    func add(
        _ request: UNNotificationRequest
    ) async throws {
        addedRequests.append(
            request
        )
    }

    func removePendingNotificationRequests(
        withIdentifiers identifiers: [String]
    ) {
        removedPendingIdentifiers.append(
            contentsOf: identifiers
        )
    }

    func removeDeliveredNotifications(
        withIdentifiers identifiers: [String]
    ) {
        removedDeliveredIdentifiers.append(
            contentsOf: identifiers
        )
    }
}
