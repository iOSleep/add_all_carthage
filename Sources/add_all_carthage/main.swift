import Foundation
import CommandLineKit
import Rainbow
import PathKit
import xcproj


enum PlatForm: String {
    case ios = "iOS"
    case mac = "Mac"
}

let cli = CommandLineKit.CommandLine()
// 项目路径
let projectOption = StringOption(longFlag: "project", helpMessage: "path to dir where *.xcodeproj in")
// 平台配置
let platformOption = EnumOption<PlatForm>(longFlag: "platform", helpMessage: "iOS or Mac")
// 帮助提示。。
let helpOption = BoolOption(longFlag: "help", helpMessage: "default --project . --platform iOS")

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

// 获取版本
var platform: String = PlatForm.ios.rawValue

if let pl = platformOption.value {
    platform = pl.rawValue
}

// 获取路径，没有填写默认当前路径
let dir = projectOption.value ?? "."
let dirPath = Path(dir)
let carthagePath = dirPath + Path("Carthage")
print(carthagePath)
if !carthagePath.exists {
    print("Carthage File Not Exist".red)
    exit(EX_OK)
}

// readline 选取 *.xcodeproj
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

// 开始解析xcproj
print("begin parse xcodeproj")
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
        if let arr: Array = dic[platform] as? Array<Dictionary<String, String>> {
            for framework in arr {
                if let name = framework["name"] {
                    names.append(name+".framework")
                }
            }
        }
    }
}

print("framework names in carthage/build\n: \(names)".yellow)

// 设置默认的基本信息
let name = "Carthage"
let shellScript = "/usr/local/bin/carthage copy-frameworks"
let inputs = names.map { "$(SRCROOT)/Carthage/Build/\(platform)/\($0)" }
let outpus = names.map { "$(BUILT_PRODUCTS_DIR)/$(FRAMEWORKS_FOLDER_PATH)/\($0)" }
// 瞎写的。。。毕竟就这一个地方用到了
let ref = "YUDJENHDLE8736493836KDIX"

//proj.pbxproj.nativeTargets.forEach({ (target) in
//    print(target.buildPhases)
//})

if carthagePhase == nil {
    // 需要手动添加 target 的 buildPhases
    var selectTarget = ""
    num = 1
    proj.pbxproj.nativeTargets.forEach{ (target) in
        selectTarget += String(num) + ". " + target.name + "\n"
        num += 1
    }

    print("please select target\n \(selectTarget)")
    var targetNum = 0
    while true {
        let str = readLine()
        guard let str1 = str,  let num = Int(str1), num > 0 && num <= proj.pbxproj.nativeTargets.count else {
            print("Please input a validate number".red)
            continue
        }
        targetNum = num
        break
    }
    let target = proj.pbxproj.nativeTargets[targetNum-1]
    target.buildPhases.append(ref)
    
    let phase = PBXShellScriptBuildPhase.init(reference: ref, files: [], inputPaths: inputs, outputPaths: outpus, shellScript: shellScript)
    phase.name = name
    proj.pbxproj.addObject(phase)
}
else {
    carthagePhase?.name = "Carthage"
    carthagePhase?.inputPaths = inputs
    carthagePhase?.outputPaths = outpus
    carthagePhase?.shellScript = shellScript
}

// 写入文件
try proj.write(path: projs[selectNum-1])

