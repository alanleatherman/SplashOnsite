//
//  SessionEventsModel.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

/*
 GET /session/{sessionID}/events
 
 Response:
 {
   "events": [
     {
       "eventType": "TickStart",
       "timestamp": 0,
       "entity": 1,
       "elevator": 0,
       "floor": 2,
       "points": 5
     }
   ]
 }
 */

struct SessionEvent: Codable {
    var eventType: String
    var timestamp: Int?
    var entity: Int?
    var elevator: Int?
    var floor: Int?
    var points: Int?
}

struct SessionEventsModel: Codable {
    var events: [SessionEvent]
}
