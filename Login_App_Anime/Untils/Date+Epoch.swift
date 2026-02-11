//
//  Date+Epoch.swift
//  Utils-iOS
//
//  Created by IgniteCoders on 10/03/24.
//
//  Epoch-related helpers for Foundation.Date.
//

import Foundation

extension Date {
    
    // MARK: - Epoch time helpers
    
    /// Milliseconds elapsed since 1970-01-01 00:00:00 UTC.
    ///
    /// Calculated as `timeIntervalSince1970 * 1000`, rounded to the nearest integer.
    /// Useful when working with APIs that represent epoch values in milliseconds.
    public var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    /// Creates a `Date` from a UNIX epoch millisecond value.
    ///
    /// - Parameter milliseconds: Milliseconds since 1970-01-01 00:00:00 UTC.
    /// - Note: This is a convenience over `init(timeIntervalSince1970:)` for millisecond-based APIs.
    public init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
