//
//  PBXShellScriptBuildPhase+des.swift
//  add_all_carthage
//
//  Created by 马旭 on 2017/12/23.
//

import Rainbow
import xcproj

extension PBXShellScriptBuildPhase: CustomStringConvertible {
    public var description: String {
        var res = ""
        res += "name: \(name ?? "")\n".red
        res += "shellPath: \(shellPath)\n".red
        res += "shellScript: \(shellScript ?? "")\n".red
        res += "runOnlyForDeploymentPostprocessing: \(runOnlyForDeploymentPostprocessing)\n".green
        res += "inputPaths:\n\n \(inputPaths)\n\n".red
        res += "outputPaths:\n\n \(outputPaths)\n\n".red
        return res
    }
}
