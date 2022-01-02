# Stock Chart
Multiplatform Stock Chart

<p>
  <img src="https://github.com/wayne90040/Flutter-StockChart-Module/blob/master/sample.png" width='20%' height='20%'/>
</p>

## Contents

- [Installation](#installation)
- [Usage](#usage)
- [Issue](#issue)

## Installation
Reference: https://docs.flutter.dev/development/add-to-app/ios/project-setup

- [iOS](#ios)

## iOS 
### Method I - Embed with CocoaPods and the Flutter SDK

#### ⚠️ **This method requires every developer working on your project to have a locally installed version of the Flutter SDK** ⚠️
<br />
  
Download or Clone the project
``` bash
$ git clone https://github.com/wayne90040/Flutter-StockChart-Module.git
```

Following example assumes that your existing application and the Flutter module are in sibling directories.
```
some/path/
├── Flutter-StockChart-Module/
│   
└── iOS-Existing-App/
    └── Podfile
```

### Podfile
If existing iOS App doesn’t already have a `Podfile`, follow the [CocoaPods getting started guide](https://guides.cocoapods.org/using/using-cocoapods.html) to add a Podfile to your project. 
<br />

Add the following lines to your Podfile:
``` ruby
flutter_application_path = '../Flutter-StockChart-Module'  # according to your clone file name
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
```

For each Podfile target that needs to embed Flutter, call `install_all_flutter_pods(flutter_application_path)`.
``` ruby
install_all_flutter_pods(flutter_application_path)
```

``` ruby 
flutter_application_path = '../flutter_stock_chart'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

platform :ios, '9.0'

target 'ios-flutter-chart-example' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ios-flutter-chart-example
  install_all_flutter_pods(flutter_application_path)
end
```

Run
> Run `flutter pub get` first under flutter project
```
$ flutter pub get
```

> Run  `pod install` under iOS project
```
$ pod install
```

---

## Usage
Reference: https://docs.flutter.dev/development/add-to-app/ios/add-flutter-screen?tab=engine-swift-tab

- [iOS](#ios-1)

## iOS

Create a FlutterEngine
``` swift
import UIKit
import Flutter
import FlutterPluginRegistrant

@UIApplicationMain
class AppDelegate: FlutterAppDelegate {

    lazy var flutterEngine = FlutterEngine(name: "flutter chart engine")

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        flutterEngine.run()
        
        GeneratedPluginRegistrant.register(with: flutterEngine)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    ...
}
```

Show a `FlutterViewController` with your FlutterEngine
``` swift
let engine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
let vc = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
present(vc, animated: true)
```

Send Data
``` swift
let channel = FlutterMethodChannel(name: "com.wielun.chart/quote", binaryMessenger: vc.binaryMessenger)
var jsonObject: [String: Any] = [:]
jsonObject["open"] = [double ...]
jsonObject["close"] = [double ...]
jsonObject["high"] = [double ...
jsonObject["low"] = [double ...]
jsonObject["vol"] = [double ...]

var convertToString: String?

do {
    let tmp = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
    convertToString = String(data: tmp, encoding: .utf8)
} catch _ {

}
channel.invokeMethod("fromHostToChart", arguments: convertToString)

```

## Issue

Check flutter version 

try 
``` bash
flutter clean
```
then 
``` bash
flutter run
```

#### Failed to find assets path for "Frameworks/App.framework/flutter_assets" 
or
#### Library not loaded: @rpath/App.framework/App
Need to add to `project/targets/Build Phases/[CP-User] Run Flutter Build flutter_stock_chart Script`
```
"$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" embed_and_thin
```
<p>
  <img src="https://github.com/wayne90040/Flutter-StockChart-Module/blob/dev/Failed%20to%20find%20assets.png" width='50%' height='50%'/>
</p>

#### Flutter in iOS14 build on real device crash when stop Xcode connect
> Change build mode to `release`
or
> Set `FLUTTER_BUILD_MODE` to `release` in `Build Settings/User-Defined`

<p>
  <img src="https://github.com/wayne90040/Flutter-StockChart-Module/blob/master/flutter-crash-iOS14.png" width='50%' height='50%'/>
</p>





## Thank you ~
