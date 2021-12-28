# Stock Chart
### Multiplatform Stock Chart


## How to Install
Reference: https://docs.flutter.dev/development/add-to-app/ios/project-setup

## iOS 

### Method I - Embed with CocoaPods and the Flutter SDK
> This method requires every developer working on your project to have a locally installed version of the Flutter SDK.



- Download or Clone the project

``` 
$ git clone https://github.com/wayne90040/Flutter-StockChart-Module.git
```

- Following example assumes that your existing application and the Flutter module are in sibling directories.

```
some/path/
├── Flutter-StockChart-Module/
│   
└── iOS-Existing-App/
    └── Podfile
```

- Add in `Podfile` 

1. Add the following lines to your Podfile:

``` ruby
flutter_application_path = '../Flutter-StockChart-Module'  # according to your clone file name
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')
```

2. For each Podfile target that needs to embed Flutter, call `install_all_flutter_pods(flutter_application_path)`.
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
3. Run `pod install`
```
$ pod install
```

## How to Use

### iOS
Reference: https://docs.flutter.dev/development/add-to-app/ios/add-flutter-screen?tab=engine-swift-tab

- Create a FlutterEngine

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

- Show a `FlutterViewController` with your FlutterEngine

``` swift
let engine = (UIApplication.shared.delegate as! AppDelegate).flutterEngine
let vc = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
present(vc, animated: true)
```

- Send Data
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


## Thank you ~
