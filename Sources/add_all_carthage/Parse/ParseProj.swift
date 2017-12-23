//
//  ParseProj.swift
//  add_all_carthage
//
//  Created by 马旭 on 2017/12/23.
//

import Foundation
import PathKit
import xcproj

struct AddCarthageTool {
    let projPath: Path
    let carthage: Path
    
    func parse() -> Bool {
        return true
    }
    
//    func parse() -> throws  Bool {
//        let proj = try XcodePr`oj.init(path: projPath)
//
//        for a in proj.pbxproj.shellScriptBuildPhases {
//            guard let name = a.name, name == "Carthage" else {
//                continue
//            }
//            print(a)
//            break
//        }
//    }
}

