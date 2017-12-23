import Rainbow
import Commandant
import xcproj

extension PBXShellScriptBuildPhase: CustomStringConvertible {
    public var description: String {
        var res = ""
        res += "name: \(name ?? "")\n"
        res += "shellPath \(shellPath)\n"
        res += "shellScript \(shellScript ?? "")\n"
        res += "runOnlyForDeploymentPostprocessing \(runOnlyForDeploymentPostprocessing)\n"
        res += "shellScript:\n \(inputPaths)\n"
        res += "shellScript:\n \(outputPaths)\n"
        return res
    }
}

let proj = try XcodeProj.init(path: "/Users/maxu/Desktop/TestDemo/TestDemo.xcodeproj")

for a in proj.pbxproj.shellScriptBuildPhases{
    print(a)
}
