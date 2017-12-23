import Rainbow
import CommandLineKit
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

let proj = try XcodeProj.init(path: "/Users/maxu/Desktop/TestDemo/TestDemo.xcodeproj")

for a in proj.pbxproj.shellScriptBuildPhases {
    guard let name = a.name, name == "Carthage" else {
        continue
    }
    print(a)
    break
}

