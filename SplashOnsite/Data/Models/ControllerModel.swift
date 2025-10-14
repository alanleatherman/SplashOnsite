//
//  ControllerModel.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

/* JSON for GET /controllers
 {"available":[{"Name":"queue"}]}
 */

struct ControllerModel: Codable {
    var available: [[String: String]]
}
