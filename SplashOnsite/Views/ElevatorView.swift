//
//  ElevatorView.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

import SwiftUI

struct ElevatorView: View {
    @Environment(\.services) private var services
    
    @State var vm: ElevatorViewModel?
    @State private var selectedScenario: String?
    @State private var selectedController: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    scenarioSelection
                    controllerSelection
                    startButton
                    simulationStatus
                    simulationLogs
                }
            }
            .navigationTitle("Elevator Simulator")
        }
        .onAppear() {
            Task {
                vm = ElevatorViewModel(networkService: services.networkService)
                await vm?.initElevator()
            }
        }
    }
    
    // MARK: - Scenario Selection
    @ViewBuilder
    private var scenarioSelection: some View {
        if let scenarios = vm?.scenario?.available {
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Scenario")
                    .font(.headline)
                
                ForEach(scenarios, id: \.self) { scenario in
                    if let name = scenario["Name"], let description = scenario["Description"] {
                        Button {
                            selectedScenario = name
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedScenario == name {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                }
                            }
                            .padding()
                            .background(selectedScenario == name ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Controller Selection
    @ViewBuilder
    private var controllerSelection: some View {
        if let controllers = vm?.controller?.available {
            VStack(alignment: .leading, spacing: 8) {
                Text("Select Controller")
                    .font(.headline)
                
                ForEach(controllers, id: \.self) { controller in
                    if let name = controller["Name"] {
                        Button {
                            selectedController = name
                        } label: {
                            HStack {
                                Text(name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Spacer()
                                if selectedController == name {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding()
                            .background(selectedController == name ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Start Button
    @ViewBuilder
    private var startButton: some View {
        if selectedScenario != nil && selectedController != nil && vm?.isSimulating == false {
            Button {
                Task {
                    await vm?.startSimulation(scenario: selectedScenario, controller: selectedController)
                }
            } label: {
                Text("Start Simulation")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
    
    // MARK: - Simulation Status
    @ViewBuilder
    private var simulationStatus: some View {
        if vm?.isSimulating == true || (vm?.totalPoints ?? 0) > 0 {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Tick: \(vm?.currentTick ?? 0)")
                                .font(.title2)
                                .fontWeight(.bold)
                            if vm?.isCompleted == true {
                                Text("(Completed)")
                                    .font(.subheadline)
                                    .foregroundStyle(.green)
                                    .fontWeight(.semibold)
                            }
                        }
                        Text("Score: \(vm?.totalPoints ?? 0)")
                            .font(.headline)
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    if vm?.isSimulating == true {
                        Button {
                            vm?.stopSimulation()
                        } label: {
                            Text("Stop")
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(vm?.isSimulating == true ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                .cornerRadius(10)
                
                if let sessionID = vm?.session?.sessionID {
                    Text("Session: \(sessionID)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Simulation Logs
    @ViewBuilder
    private var simulationLogs: some View {
        if let logs = vm?.logs, !logs.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Simulation Log")
                    .font(.headline)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(Array(logs.enumerated()), id: \.offset) { _, log in
                            Text(log)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.black.opacity(0.05))
                    .cornerRadius(8)
                }
                .frame(maxHeight: 300)
            }
            .padding()
        }
    }
}

#Preview {
    ElevatorView()
}
