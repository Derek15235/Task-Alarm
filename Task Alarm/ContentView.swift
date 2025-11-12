//
//  ContentView.swift
//  Task Alarm
//
//  Created by Derek Jain on 11/11/25.
//

import SwiftUI
import AlarmKit

struct ContentView: View {
    @State private var isAuthorized: Bool = false
    @State private var scheduleDate: Date = .now
    var body: some View {
        NavigationStack {
            Group {
                if isAuthorized {
                    AlarmView()
                } else {
                    Text("You need to allow alarms in settings to use this app")
                        .multilineTextAlignment(.center)
                        .padding(10)
                        .glassEffect()
                    
                }
            }
            .navigationTitle("AlarmKit")
        }
        .task {
            do {
                try await checkAndAuthorize()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
    private func AlarmView() -> some View {
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
            
        }
    }
    
    private func setAlarm() async throws{
        // Alert
        let alert = AlarmPresentation.Alert(
            title: "Time's Up!!!",
            stopButton: .init(text: "Stop", textColor: .red, systemImageName: "stop.fill")
        )
        
        // Presentation
        let presentation = AlarmPresentation(alert: alert)
        
        // Attributes
        let attributes = AlarmAttributes<CountDownAttribute>(presentation: presentation, metadata: .init(), tintColor: .orange)
        
        // Schedule
        let schedule = Alarm.Schedule.fixed(scheduleDate)
        
        // Configuration
        let config = AlarmManager.AlarmConfiguration(
            schedule: schedule,
            attributes: attributes
        )
        
        let id = UUID()
        
        let _ = try await AlarmManager.shared.schedule(id: id, configuration: config)
        print("Alarm Set Successfully")
    }
    
    
    private func checkAndAuthorize() async throws {
        switch AlarmManager.shared.authorizationState {
        case .notDetermined:
            /// Requesting for authorization
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
    
    
}


#Preview {
    ContentView()
}
