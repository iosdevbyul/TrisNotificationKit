//
//  SystemNotificationCenterClient.swift
//  TrisNotificationKit
//
//  Created by COMATOKI on 2026-10-06.
//

import UserNotifications

final class SystemNotificationCenterClient: NotificationCenterClient {

    private let center: UNUserNotificationCenter

    init(
        center: UNUserNotificationCenter = .current()
    ) {
        self.center = center
    }

    func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()

        return settings.authorizationStatus
    }

    func requestAuthorization(
        options: UNAuthorizationOptions
    ) async throws -> Bool {
        try await center.requestAuthorization(
            options: options
        )
    }

    func add(
        _ request: UNNotificationRequest
    ) async throws {
        try await center.add(request)
    }

    func removePendingNotificationRequests(
        withIdentifiers identifiers: [String]
    ) {
        center.removePendingNotificationRequests(
            withIdentifiers: identifiers
        )
    }

    func removeDeliveredNotifications(
        withIdentifiers identifiers: [String]
    ) {
        center.removeDeliveredNotifications(
            withIdentifiers: identifiers
        )
    }
}
