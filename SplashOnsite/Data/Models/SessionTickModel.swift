//
//  SessionTickModel.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

/*
 POST /session/{sessionID}/tick
 
 Response:
 {
   "completed": true
 }
 */

struct SessionTickModel: Codable {
    var completed: Bool
}
