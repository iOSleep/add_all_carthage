import Foundation
import CommandLineKit
import Rainbow
import PathKit
import xcproj


let cli = CommandLineKit.CommandLine()
let projectOption = StringOption(longFlag: "project", helpMessage: "path to dir where *.xcodeproj in")

let platformOption = StringOption(longFlag: "platform", helpMessage: "you can select ios or mac")

let helpOption = BoolOption(longFlag: "help", helpMessage: "Prints a help message.")

cli.addOptions(projectOption, platformOption, helpOption)

cli.formatOutput = { s, type in
    var str: String
    switch(type) {
    case .error:
        str = s.red.bold
    case .optionFlag:
        str = s.green.underline
    case .optionHelp:
        str = s.blue
    default:
        str = s
    }
    return cli.defaultFormat(s: str, type: type)
}

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
}

// 提示帮助信息
if helpOption.value {
    cli.printUsage()
    exit(EX_OK)
}

// 获取绝对路径
let dir = projectOption.value ?? "/Users/maxu/Desktop/TestDemo"
let dirPath = Path(dir)
let carthagePath = dirPath + Path("Carthage")
if !carthagePath.exists {
    print("Carthage File Not Exist".red)
    exit(EX_OK)
}

print("get all proj s".green)
var projs:[Path] = []
var num = 1
var selectProjStr = ""
try dirPath.children().forEach { (path) in
    if let ex = path.extension, ex == "xcodeproj" {
        selectProjStr += String(num) + ". " + path.lastComponentWithoutExtension + "\n "
        num += 1
        projs.append(path)
    }
}
if (projs.count == 0) {
    print("no xcodeproj in path".red)
    exit(EX_NOINPUT)
}

print("please select proj\n \(selectProjStr)")
var selectNum = 0
while true {
    let str = readLine()
    guard let str1 = str,  let num = Int(str1), num > 0 && num <= projs.count else {
        print("Please input a validate number".red)
        continue
    }
    selectNum = num
    break
}
let space = Path.init("/Users/maxu/Desktop/TestDemo/TestDemo.xcworkspace")

let proj = try XcodeProj.init(path: projs[selectNum-1])

var carthagePhase: PBXShellScriptBuildPhase?

for phase in proj.pbxproj.shellScriptBuildPhases {
    guard let name = phase.name, name == "Carthage" else {
        continue
    }
    carthagePhase = phase
    break
}

if carthagePhase != nil {
    print("update Carthage BuildPhases".blue)
} else {
    print("add Carthage BuildPhases".green)
}

// 获取所有的 version file
let buildPath = carthagePath + Path("Build")
var versioins: [Path] = []
var names: [String] = []
for path in try buildPath.children() {
    if let ex = path.extension , ex == "version"{
        let data: Data = try path.read()
        let dic = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! Dictionary<String, Any>
        if let arr: Array = dic["iOS"] as? Array<Dictionary<String, String>> {
            for framework in arr {
                if let name = framework["name"] {
                    names.append(name+".framework")
                }
            }
        }
    }
}

print("framework names in carthage/build\n: \(names)".yellow)

let name = "Carthage"
let shellScript = "/usr/local/bin/carthage copy-frameworks"
let inputs = names.map { "$(SRCROOT)/Carthage/Build/iOS/\($0)" }
let outpus = names.map { "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/\($0)" }


func base64String(from uuid: UUID) -> String {
    var result = Data()
    let uuidTuple = uuid.uuid
    result.append(uuidTuple.0)
    result.append(uuidTuple.1)
    result.append(uuidTuple.2)
    result.append(uuidTuple.3)
    result.append(uuidTuple.4)
    result.append(uuidTuple.5)
    result.append(uuidTuple.6)
    result.append(uuidTuple.7)
    result.append(uuidTuple.8)
    result.append(uuidTuple.9)
    result.append(uuidTuple.10)
    result.append(uuidTuple.11)
    result.append(uuidTuple.12)
    result.append(uuidTuple.13)
    result.append(uuidTuple.14)
    result.append(uuidTuple.15)
    return result.base64EncodedString()
}

proj.pbxproj.nativeTargets.forEach({ (target) in
    print(target.buildPhases)
})


if carthagePhase == nil {
    let phase = PBXShellScriptBuildPhase.init(reference: "YUDJENHDLE8736493836KDIX", files: [], inputPaths: inputs, outputPaths: outpus, shellScript: shellScript)
    phase.name = name
    
//    phase.reference = base64String(from: UUID())
//    let data = Data.init(bytes: UUID().uuid)
    
//    let tar = PBXNativeTarget(reference: <#T##String#>, buildConfigurationList: <#T##String#>, buildPhases: <#T##[String]#>, buildRules: <#T##[String]#>, dependencies: <#T##[String]#>, name: <#T##String#>)
    
    proj.pbxproj.addObject(phase)
}

if carthagePhase != nil {
    carthagePhase?.name = "Carthage"
    carthagePhase?.inputPaths = inputs
    carthagePhase?.outputPaths = outpus
    carthagePhase?.shellScript = shellScript
}


try proj.write(path: projs[selectNum-1])

