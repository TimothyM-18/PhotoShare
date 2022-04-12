//
//  AnalyticsManager.swift
//  Photo_Share
//
//  Created by Timothy Mazenge on 2/24/22.
//

import Foundation

import FirebaseAnalytics

final class AnalyticsManager {
    
    static let shared = AnalyticsManager()
    
    private init() {}
   
    func logEvent() {
        Analytics.logEvent("", parameters: [:])
    }
   
}
