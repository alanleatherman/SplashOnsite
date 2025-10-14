//
//  SessionModel.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

/*
 POST /session
 Request:
 type PostSessionRequestBody struct {
     Scenario   *string `json:"scenario,omitempty"`
     Controller *string `json:"controller,omitempty"`
 }
 
 Response (assumed):
 {
   "sessionID": "some-uuid-string"
 }
 */

struct SessionRequestBody: Codable {
    var scenario: String?
    var controller: String?
}

struct SessionModel: Codable {
    var sessionID: String
}
