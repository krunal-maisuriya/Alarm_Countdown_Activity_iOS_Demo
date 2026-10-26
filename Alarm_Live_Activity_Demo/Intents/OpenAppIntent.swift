//
//  OpenAppIntent.swift
//  Alarm_Live_Activity_Demo
//
//  Created by Krunal Maisuriya on 26/10/2026.
//

import SwiftUI
import AppIntents


struct OpenAppIntent: LiveActivityIntent {
    
    static var title: LocalizedStringResource = "Opens App"
    static var openAppWhenRun: Bool = true
    static var isDiscoverable: Bool = false
    
    @Parameter var id: String
    
    init(id: UUID) {
        self.id = id.uuidString
    }
    
    init() {
    }
    
    func perform() async throws -> some IntentResult {
        if let alarmID = UUID(uuidString: id) {
            print("UUID, ", alarmID)
        }
        
        return .result()
    }
}
