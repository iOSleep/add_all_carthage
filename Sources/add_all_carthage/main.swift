import Foundation
import CommandLineKit
import Rainbow
import PathKit

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
// 获取所有的 version file
let buildPath = carthagePath + Path("Build")
var versioins: [Path] = []
for path in try buildPath.children() {
    if let ex = path.extension , ex == "version"{
        versioins.append(path)
    }
}



//let files = try FileManager.default.contentsOfDirectory(atPath: dirPath.absolute().string)
//
//print(files)

