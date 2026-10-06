//
//  NotificationCenterClient.swift
//  TrisNotificationKit
//
//  Created by COMATOKI on 2026-10-06.
//

import UserNotifications

protocol NotificationCenterClient {

    func authorizationStatus() async -> UNAuthorizationStatus

    func requestAuthorization(
        options: UNAuthorizationOptions
    ) async throws -> Bool

    func add(
        _ request: UNNotificationRequest
    ) async throws

    func removePendingNotificationRequests(
        withIdentifiers identifiers: [String]
    )

    func removeDeliveredNotifications(
        withIdentifiers identifiers: [String]
    )
}
