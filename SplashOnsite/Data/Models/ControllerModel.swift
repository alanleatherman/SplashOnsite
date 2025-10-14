//
//  ControllerModel.swift
//  SplashOnsite
//
//  Created by Alan Leatherman on 10/14/25.
//

/*
 type GetControllersDescription struct {
     Name string
 }

 type GetControllersReply struct {
     Available []GetControllersDescription `json:"available"`
 }
 
 {"available":[{"Name":"queue"}]}
 
 */

struct ControllerModel: Codable {
    var available: [[String: String]]
}



