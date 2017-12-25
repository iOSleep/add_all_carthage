# add_all_carthage

Auto add all carthage to `Build Phases` named `Carthage` as a `Script Phase`

## Install

```bash
git clone 
swift build   // now you can get add_all_carthage at .build/debug/
swift package generate-xcodeproj   // use xcode to debug....
```

## TODO

- [x] add all input & output into script.
- [x] platform support, now add Mac and iOS.
- [ ] add frameworks to `Linkded Frameworks`
- [ ] setting to ignore some frameworks, like `Quick` for test; `IQKeyboardManagerSwift` in oc project.
