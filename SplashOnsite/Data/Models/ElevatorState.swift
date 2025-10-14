//
//  ElevatorState.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

import Foundation

struct ElevatorState {
    var currentFloor: Int = 0
    var requestedFloors: Set<Int> = []
    var calledFloors: Set<Int> = []
}

struct BuildingState {
    var floors: [Int] = [0, 1, 2, 3, 4]
    var elevators: [Int: ElevatorState] = [0: ElevatorState()]
}
