//
//  ContentView.swift
//  Alarm_Live_Activity_Demo
//
//  Created by Krunal Maisuriya on 26/10/2026.
//

import SwiftUI
import AlarmKit
import AppIntents


struct ContentView: View {
    @State private var isAuthorized: Bool = false
    @State private var scheduleDate: Date = Date.now
    
    var body: some View {
        NavigationStack {
            Group {
                if isAuthorized {
                    AlarmView()
                } else {
                    Text("You need to allow alarms in settings to use this app.")
                        .padding(25)
                        .multilineTextAlignment(.center)
                        .glassEffect()
                }
            }
            .navigationTitle("Alarm")
        }
        .task {
            do {
                //  Check Alarm Permission Authorization
                try await checkAuthorization()
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder private func AlarmView() -> some View {
        List {
            Section("Date & Time") {
                DatePicker("", selection: $scheduleDate, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
            }
            
            Button("Set Alarm") {
                Task {
                    do {
                        try await setAlarm()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            Button("Set Countdown Alarm") {
                Task {
                    do {
                        try await setAlarmWithCountdown()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    //  MARK: - Check Alarm Permission
    private func checkAuthorization() async throws {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            // Requesting for authorization
            let status = try await AlarmManager.shared.requestAuthorization()
            isAuthorized = status == .authorized
        case .denied:
            isAuthorized = false
        case .authorized:
            isAuthorized = true
        @unknown default:
            fatalError()
        }
    }
    
    
    //  MARK: - Set Alarm
    private func setAlarm() async throws {
        /// Alarm ID
        let id = UUID()
        
        /// Secondary Alert Button
        let secondaryButton = AlarmButton(text: "Go to App", textColor: .white, systemImageName: "app.fill")
        
        /// Alarm
        let alert = AlarmPresentation.Alert(
            title: "Time's Up!!!",
            stopButton: .init(text: "Stop", textColor: .red, systemImageName: "stop.fill"),
            secondaryButton: secondaryButton,
            secondaryButtonBehavior: .custom
        )
        
        /// Presentation
        let presentation = AlarmPresentation(alert: alert)
        
        /// Attributes
        let attributes = AlarmAttributes<CountDownAttribute>(presentation: presentation, metadata: .init(), tintColor: .orange)
        
        /// Schedule
        let schedule = Alarm.Schedule.fixed(scheduleDate)
        
        /// Configuration
        let configuration = AlarmManager.AlarmConfiguration(
            schedule: schedule,
            attributes: attributes,
            secondaryIntent: OpenAppIntent(id: id),
        )
        
        /// Adding alarm to the system
        let _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
        print("Alarm Set Successfully....!!")
        
    }

    //  MARK: - Set Alarm with CountDown
    private func setAlarmWithCountdown() async throws {
        /// Alarm ID
        let id = UUID()
        
        /// Countdown
        let alarmCountdown = Alarm.CountdownDuration(preAlert: 20, postAlert: 10)
        
        /// Secondary Alert Button
        let secondaryButton = AlarmButton(text: "Repeat", textColor: .white, systemImageName: "arrow.clockwise")
        
        /// Alarm
        let alert = AlarmPresentation.Alert(
            title: "Time's Up!!!",
            stopButton: .init(text: "Stop", textColor: .red, systemImageName: "stop.fill"),
            secondaryButton: secondaryButton,
            secondaryButtonBehavior: .countdown
        )
        
        /// Presentation
        let countdownPresentation = AlarmPresentation.Countdown(
            // Display your title on LiveActivity. On Dynamic Island
            title: "Alarm Counter",
            pauseButton: .init(text: "Pause", textColor: .white, systemImageName: "pause.fill")
        )
        let pausedPresentation = AlarmPresentation.Paused(
            // Display paused title on LiveActivity. On Dynamic Island
            title: "Paused",
            resumeButton: .init(text: "Resume", textColor: .white, systemImageName: "play.fill")
        )
        
        let presentation = AlarmPresentation(alert: alert, countdown: countdownPresentation, paused: pausedPresentation)
        
        /// Attributes
        let attributes = AlarmAttributes<CountDownAttribute>(presentation: presentation, metadata: .init(), tintColor: .orange)
        
        /// Configuration
        let configuration = AlarmManager.AlarmConfiguration(
            countdownDuration: alarmCountdown,
            attributes: attributes,
        )
        
        /// Adding alarm to the system
        let _ = try await AlarmManager.shared.schedule(id: id, configuration: configuration)
        print("Alarm Set Successfully....!!")
        
    }

}

#Preview {
    ContentView()
}
