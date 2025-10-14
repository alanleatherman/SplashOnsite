//
//  ScenarioModel.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

/* JSON GET /scenarios
 {
    "available":[
       {
          "Name":"single-up",
          "Description":"a single person to go up"
       },
       {
          "Name":"single-down",
          "Description":"a single person to go down"
       },
       {
          "Name":"multiple-up-and-back",
          "Description":"various persons going up and back"
       }
    ]
 }
 */

struct ScenarioModel: Codable {
    var available: [[String: String]]
}
