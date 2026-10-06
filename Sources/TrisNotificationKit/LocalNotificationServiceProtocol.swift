import Foundation

public protocol LocalNotificationServiceProtocol: AnyObject {

    func permissionStatus() async -> NotificationPermissionStatus

    func requestPermission() async throws -> Bool

    @discardableResult
    func send(
        title: String,
        body: String,
        identifier: String
    ) async throws -> String

    @discardableResult
    func send(
        title: String,
        body: String,
        identifier: String,
        sound: Bool
    ) async throws -> String

    @discardableResult
    func schedule(
        title: String,
        body: String,
        at date: Date,
        identifier: String
    ) async throws -> String

    @discardableResult
    func schedule(
        title: String,
        body: String,
        at date: Date,
        identifier: String,
        sound: Bool
    ) async throws -> String

    func cancel(identifier: String)

    func removeDelivered(identifier: String)
}
