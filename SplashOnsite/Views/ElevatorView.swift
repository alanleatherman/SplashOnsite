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
                    elevatorVisualization
                    simulationLogs
                }
            }
            .transaction { transaction in
                transaction.animation = nil
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
    
    // MARK: - Elevator Visualization
    @ViewBuilder
    private var elevatorVisualization: some View {
        if let buildingState = vm?.buildingState, vm?.isSimulating == true || (vm?.totalPoints ?? 0) > 0 {
            VStack(alignment: .leading, spacing: 8) {
                Text("Building View")
                    .font(.headline)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 30) {
                        ForEach(Array(buildingState.elevators.keys.sorted()), id: \.self) { elevatorID in
                            if let elevator = buildingState.elevators[elevatorID] {
                                VStack(spacing: 0) {
                                    Text("Elevator \(elevatorID)")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .padding(.bottom, 12)
                                    
                                    VStack(spacing: 6) {
                                        ForEach(buildingState.floors.reversed(), id: \.self) { floor in
                                            HStack(spacing: 12) {
                                                // Floor number
                                                Text("Floor \(floor)")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .frame(width: 60, alignment: .trailing)
                                                    .foregroundStyle(elevator.currentFloor == floor ? .blue : .primary)
                                                
                                                // Elevator shaft
                                                ZStack {
                                                    Rectangle()
                                                        .fill(Color.gray.opacity(0.15))
                                                        .frame(width: 120, height: 60)
                                                        .overlay(
                                                            Rectangle()
                                                                .stroke(Color.gray.opacity(0.4), lineWidth: 2)
                                                        )
                                                    
                                                    // Elevator car with animation
                                                    if elevator.currentFloor == floor {
                                                        RoundedRectangle(cornerRadius: 6)
                                                            .fill(
                                                                LinearGradient(
                                                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                                                    startPoint: .top,
                                                                    endPoint: .bottom
                                                                )
                                                            )
                                                            .frame(width: 100, height: 50)
                                                            .overlay(
                                                                VStack(spacing: 2) {
                                                                    Image(systemName: "arrow.up.arrow.down")
                                                                        .foregroundColor(.white)
                                                                        .font(.title3)
                                                                    Text("🚪")
                                                                        .font(.caption)
                                                                }
                                                            )
                                                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                                                            .transition(.scale.combined(with: .opacity))
                                                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: elevator.currentFloor)
                                                    }
                                                }
                                                
                                                // Floor status indicators
                                                HStack(spacing: 8) {
                                                    if elevator.calledFloors.contains(floor) {
                                                        VStack(spacing: 2) {
                                                            Image(systemName: "bell.fill")
                                                                .foregroundColor(.orange)
                                                                .font(.body)
                                                            Text("Called")
                                                                .font(.caption2)
                                                                .foregroundColor(.orange)
                                                        }
                                                        .padding(6)
                                                        .background(Color.orange.opacity(0.1))
                                                        .cornerRadius(6)
                                                        .transition(.scale.combined(with: .opacity))
                                                    }
                                                    if elevator.requestedFloors.contains(floor) {
                                                        VStack(spacing: 2) {
                                                            Image(systemName: "arrow.left.circle.fill")
                                                                .foregroundColor(.green)
                                                                .font(.body)
                                                            Text("Going")
                                                                .font(.caption2)
                                                                .foregroundColor(.green)
                                                        }
                                                        .padding(6)
                                                        .background(Color.green.opacity(0.1))
                                                        .cornerRadius(6)
                                                        .transition(.scale.combined(with: .opacity))
                                                    }
                                                }
                                                .frame(width: 80, alignment: .leading)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: elevator.calledFloors)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: elevator.requestedFloors)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Legend
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .font(.body)
                        Text("Floor Called")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left.circle.fill")
                            .foregroundColor(.green)
                            .font(.body)
                        Text("Destination")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.blue)
                            .frame(width: 30, height: 16)
                        Text("Elevator Position")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    ElevatorView()
}
