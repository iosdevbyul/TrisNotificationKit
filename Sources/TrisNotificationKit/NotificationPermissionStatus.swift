//
//  NotificationPermissionStatus.swift
//  TrisNotificationKit
//
//  Created by COMATOKI on 2026-10-06.
//

public enum NotificationPermissionStatus: Sendable, Equatable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
    case unknown
}
