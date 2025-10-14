***Implementation of the Elevator Simulator in Swift***

![ElevatorSimulatorUI](https://github.com/user-attachments/assets/954a0ecc-9933-41e6-b48e-48371567d502)

## Features

### Interactive Simulation (Visual and Logging)
- **Scenario Selection**: Choose from multiple elevator scenarios (single-up, single-down, multiple-up-and-back)
- **Controller Selection**: Select controller for use 
- **Real-time Execution**: Watch the simulation run with live updates (0.5 secs by default)
- **Manual Control**: Start and stop simulations at any time
- **Detailed Logging**

### Visual Building View
- **Animated Elevator Movement**: Spring animations as elevators move between floors
- **Floor Status Indicators**:
  - 🔔 **Orange "Called" Badge**: Someone waiting on this floor
  - ← **Green "Destination" Badge**: Elevator heading to this floor
  - 🔵 **Blue Elevator Car**: Current elevator position with door emoji
- **Multi-Elevator Support**: Horizontal scrolling for multiple elevators
- **Real-time Updates**: Visual state updates with every simulation tick

### Architecture
- **MVVM Pattern**: Clean separation of UI and business logic
- **Observable State**: SwiftUI @Observable for reactive updates
- **Network Service**: RESTful API integration with elevatinator backend
- **Type-Safe Models**: Codable models for all API responses (utilize JSON create for fetching inital state for now)
  
## Backend Integration

Connects to elevatinator backend running locally at `http://localhost:8999`

### API Endpoints Used:
- `GET /scenarios` - Available simulation scenarios
- `GET /controllers` - Available AI controllers
- `POST /session` - Create new simulation session
- `POST /session/{id}/tick` - Advance simulation by one tick
- `GET /session/{id}/events` - Fetch simulation events
- 
## Project Structure

```
SplashOnsite/
├── VIEWS/
│   └── ElevatorView.swift          # Main UI with visual elevator
├── ViewModels/
│   └── ElevatorViewModel.swift     # Simulation logic & state
├── Data/Models/
│   ├── ElevatorState.swift         # Building & elevator state
│   ├── ScenarioModel.swift         # Available scenarios
│   ├── ControllerModel.swift       # Available controllers
│   ├── SessionModel.swift          # Session creation
│   ├── SessionTickModel.swift      # Tick response
│   └── SessionEventsModel.swift    # Event stream
├── Services/
│   └── NetworkService.swift        # HTTP client
└── Environment/
    ├── AppContainer.swift          # Dependency injection
    ├── AppEnvironment.swift        # Environment setup
    └── AppState.swift              # Global state
```

## Technical Highlights

- **Animations**: Spring physics for realistic elevator movement
- **State Management**: Centralized in ViewModel with @Observable
- **Event Processing**: Incremental event tracking to avoid duplicates
- **Error Handling**: Graceful degradation with user-friendly messages
- **Performance**: Efficient updates with minimal re-renders
- **Accessibility**: Semantic labels and clear visual hierarchy
