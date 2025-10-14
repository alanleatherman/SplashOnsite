//
//  ElevatorViewModel.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

import SwiftUI

@Observable
class ElevatorViewModel {
    var controller: ControllerModel?
    var scenario: ScenarioModel?
    var session: SessionModel?
    var sessionEvents: SessionEventsModel?
    
    var isSimulating = false
    var isCompleted = false
    var currentTick = 0
    var totalPoints = 0
    var logs: [String] = []
    var buildingState = BuildingState()
    
    private var processedEventCount = 0
    private var networkService: NetworkService
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func initElevator() async {
        await fetchController()
        await fetchScenarios()
    }
    
    func fetchController() async {
        guard let url = URL(string: "\(EndpointConstants.baseURL)\(EndpointConstants.controllers)") else {
            return
        }
                     
        do {
            if let data = try? await networkService.fetchData(from: url) {
                let fetchedController = try JSONDecoder().decode(ControllerModel.self, from: data)
                print(fetchedController.available)
                controller = fetchedController
            }
        } catch {
            print(error)
        }
    }
    
    func fetchScenarios() async {
        guard let url = URL(string: "\(EndpointConstants.baseURL)\(EndpointConstants.scenarios)") else {
            return
        }
        
        do {
            if let data = try? await networkService.fetchData(from: url) {
                let fetchedScenario = try JSONDecoder().decode(ScenarioModel.self, from: data)
                print(fetchedScenario.available)
                scenario = fetchedScenario
            }
        } catch {
            print(error)
        }
    }
    
    func startSimulation(scenario: String?, controller: String?) async {
        isSimulating = true
        isCompleted = false
        buildingState = BuildingState()
        currentTick = 0
        processedEventCount = 0
        totalPoints = 0
        logs = []
        
        logs.append("*** Init Start")
        
        // Create session
        await createSession(scenario: scenario, controller: controller)
        
        guard let sessionID = session?.sessionID else {
            logs.append("Error: Failed to create session")
            isSimulating = false
            isCompleted = true
            return
        }
        
        logs.append("Session created: \(sessionID)")
        logs.append("Scenario: \(scenario ?? "none")")
        logs.append("Controller: \(controller ?? "none")")
        logs.append("*** Init done.")
        
        // Run simulation ticks
        while isSimulating {
            logs.append("Tick Start \(currentTick)")
            
            let tickCompleted = await postSessionTick(sessionID: sessionID)
            await fetchSessionEvents(sessionID: sessionID)
            
            // Process new events
            if let events = sessionEvents?.events {
                let newEvents = events.dropFirst(processedEventCount)
                for event in newEvents {
                    updateBuildingState(event: event)
                    if event.eventType == "ActorFinished", let points = event.points {
                        totalPoints += points
                    }
                    let eventLog = formatEvent(event)
                    if !eventLog.isEmpty {
                        logs.append(eventLog)
                    }
                }
                processedEventCount = events.count
            }
            
            logs.append("done (\(currentTick))")
            
            // Check if simulation is completed
            if tickCompleted {
                logs.append("*** Simulation completed! Total points: \(totalPoints)")
                isSimulating = false
                isCompleted = true
                clearPendingRequests()
                break
            }
            currentTick += 1
            
            // Add delay between ticks
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Stop after reasonable number of ticks
            if currentTick > 100 {
                logs.append("Simulation completed (max ticks reached)")
                isSimulating = false
                clearPendingRequests()
                isCompleted = true
            }
        }
    }
    
    func stopSimulation() {
        isSimulating = false
        logs.append("*** Simulation stopped by user")
    }
    
    private func createSession(scenario: String?, controller: String?) async {
        guard let url = URL(string: "\(EndpointConstants.baseURL)\(EndpointConstants.session)") else {
            return
        }
        
        let requestBody = SessionRequestBody(scenario: scenario, controller: controller)
        
        do {
            let createdSession: SessionModel = try await networkService.request(.post, url: url, body: requestBody)
            print("Session created: \(createdSession.sessionID)")
            session = createdSession
        } catch {
            print(error)
        }
    }
    
    private func postSessionTick(sessionID: String) async -> Bool {
        let endpoint = EndpointConstants.sessionTick.replacingOccurrences(of: "{sessionID}", with: sessionID)
        guard let url = URL(string: "\(EndpointConstants.baseURL)\(endpoint)") else {
            return false
        }
        
        do {
            let tickResponse: SessionTickModel = try await networkService.request(.post, url: url, body: nil as String?)
            print("Tick completed: \(tickResponse.completed)")
            return tickResponse.completed
        } catch {
            print(error)
            return false
        }
    }
    
    private func fetchSessionEvents(sessionID: String) async {
        let endpoint = EndpointConstants.sessionEvents.replacingOccurrences(of: "{sessionID}", with: sessionID)
        guard let url = URL(string: "\(EndpointConstants.baseURL)\(endpoint)") else {
            return
        }
        
        do {
            if let data = try? await networkService.fetchData(from: url) {
                let fetchedEvents = try JSONDecoder().decode(SessionEventsModel.self, from: data)
                print("Events count: \(fetchedEvents.events.count)")
                sessionEvents = fetchedEvents
            }
        } catch {
            print(error)
        }
    }
    
    private func formatEvent(_ event: SessionEvent) -> String {
        switch event.eventType {
        case "ElevatorCalled":
            if let floor = event.floor {
                return "Elevator called on floor \(floor)"
            }
        case "ElevatorFloorRequest":
            if let elevator = event.elevator, let floor = event.floor {
                return "Actor in elevator \(elevator) requesting floor \(floor)"
            }
        case "ElevatorArrived":
            if let elevator = event.elevator, let floor = event.floor {
                return "Elevator \(elevator) arrived at floor \(floor)"
            }
        case "ActorFinished":
            if let points = event.points {
                return "Actor finished. Earned \(points) point(s)."
            }
        case "TickStart", "TickDone", "InitStart", "InitDone", "InformElevator", "InformFloor":
            return ""
        default:
            break
        }
        return "\(event.eventType)"
    }
    
    private func updateBuildingState(event: SessionEvent) {
        switch event.eventType {
        case "InformElevator":
            if let elevatorID = event.elevator {
                if buildingState.elevators[elevatorID] == nil {
                    buildingState.elevators[elevatorID] = ElevatorState()
                }
            }
        case "InformFloor":
            if let floor = event.floor, !buildingState.floors.contains(floor) {
                buildingState.floors.append(floor)
                buildingState.floors.sort()
            }
        case "ElevatorCalled":
            if let floor = event.floor {
                for i in buildingState.elevators.keys {
                    buildingState.elevators[i]?.calledFloors.insert(floor)
                }
            }
        case "ElevatorFloorRequest":
            if let elevatorID = event.elevator, let floor = event.floor {
                buildingState.elevators[elevatorID]?.requestedFloors.insert(floor)
                let currentFloor = buildingState.elevators[elevatorID]?.currentFloor ?? 0
                buildingState.elevators[elevatorID]?.calledFloors.remove(currentFloor)
            }
        case "ElevatorArrived":
            if let elevatorID = event.elevator, let floor = event.floor {
                buildingState.elevators[elevatorID]?.currentFloor = floor
                buildingState.elevators[elevatorID]?.requestedFloors.remove(floor)
            }
        default:
            break
        }
    }
    
    private func clearPendingRequests() {
        for elevatorID in buildingState.elevators.keys {
            buildingState.elevators[elevatorID]?.calledFloors.removeAll()
            buildingState.elevators[elevatorID]?.requestedFloors.removeAll()
        }
    }
}
