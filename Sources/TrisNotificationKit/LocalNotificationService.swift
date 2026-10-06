//
//  LocalNotificationService.swift
//  TrisNotificationKit
//
//  Created by COMATOKI on 2026-10-06.
//

import Foundation
import UserNotifications

public final class LocalNotificationService: LocalNotificationServiceProtocol {

    private let client: any NotificationCenterClient

    public init() {
        self.client = SystemNotificationCenterClient()
    }

    init(
        client: any NotificationCenterClient
    ) {
        self.client = client
    }

    public func permissionStatus() async -> NotificationPermissionStatus {
        let status = await client.authorizationStatus()

        switch status {
        case .notDetermined:
            return .notDetermined

        case .denied:
            return .denied

        case .authorized:
            return .authorized

        case .provisional:
            return .provisional

        case .ephemeral:
            return .ephemeral

        @unknown default:
            return .unknown
        }
    }

    public func requestPermission() async throws -> Bool {
        try await client.requestAuthorization(
            options: [
                .alert,
                .sound
            ]
        )
    }

    @discardableResult
    public func send(
        title: String,
        body: String,
        identifier: String
    ) async throws -> String {
        try await send(
            title: title,
            body: body,
            identifier: identifier,
            sound: true
        )
    }

    @discardableResult
    public func send(
        title: String,
        body: String,
        identifier: String,
        sound: Bool
    ) async throws -> String {
        let content = makeContent(
            title: title,
            body: body,
            sound: sound
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )

        try await client.add(request)

        return identifier
    }

    @discardableResult
    public func schedule(
        title: String,
        body: String,
        at date: Date,
        identifier: String
    ) async throws -> String {
        try await schedule(
            title: title,
            body: body,
            at: date,
            identifier: identifier,
            sound: true
        )
    }

    @discardableResult
    public func schedule(
        title: String,
        body: String,
        at date: Date,
        identifier: String,
        sound: Bool
    ) async throws -> String {
        let content = makeContent(
            title: title,
            body: body,
            sound: sound
        )

        let dateComponents = Calendar.current.dateComponents(
            [
                .year,
                .month,
                .day,
                .hour,
                .minute,
                .second
            ],
            from: date
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        try await client.add(request)

        return identifier
    }

    public func cancel(
        identifier: String
    ) {
        client.removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )
    }

    public func removeDelivered(
        identifier: String
    ) {
        client.removeDeliveredNotifications(
            withIdentifiers: [identifier]
        )
    }

    private func makeContent(
        title: String,
        body: String,
        sound: Bool
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()

        content.title = title
        content.body = body
        content.sound = sound ? .default : nil

        return content
    }
}

public extension LocalNotificationService {

    @discardableResult
    func send(
        title: String,
        body: String
    ) async throws -> String {
        try await send(
            title: title,
            body: body,
            identifier: UUID().uuidString,
            sound: true
        )
    }

    @discardableResult
    func send(
        title: String,
        body: String,
        sound: Bool
    ) async throws -> String {
        try await send(
            title: title,
            body: body,
            identifier: UUID().uuidString,
            sound: sound
        )
    }

    @discardableResult
    func schedule(
        title: String,
        body: String,
        at date: Date
    ) async throws -> String {
        try await schedule(
            title: title,
            body: body,
            at: date,
            identifier: UUID().uuidString,
            sound: true
        )
    }

    @discardableResult
    func schedule(
        title: String,
        body: String,
        at date: Date,
        sound: Bool
    ) async throws -> String {
        try await schedule(
            title: title,
            body: body,
            at: date,
            identifier: UUID().uuidString,
            sound: sound
        )
    }
}
