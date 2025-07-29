# BBPSSDK

## **Integration Guide**

To install the BBPSSDK into your application via Swift Package Manager follow two steps:

1. Installing Assets Plugin
2. Installing BBPSSDK

Following sections describe how to complete above steps

## **1.1. Installing Assets Plugin**

BBPSSDK depends on certain assets to function. These are available over the air and are supposed to be present while building the SDK. The Assets Plugin is a build time dependency that downloads all required assets and ensures the availability of the latest assets at build time.

To install Assets Plugin follow the below steps:

### **Step 1.1a - Add Build Pre-actions Script**

In Xcode, go to the menu and select **Product** → **Scheme** → **Edit Scheme…**.

![Xcode Menu Navigation](./images/scheme-menu.png)

Alternatively, you can select your target from the scheme drop-down in Xcode's toolbar and choose **Edit Scheme...**.

<img src="./images/scheme-dropdown.png" alt="Scheme Dropdown" width="300">

In the Scheme Editor, expand **Build** and select **Pre-actions.**

<img src="./images/build-preactions.png" alt="Build Pre-actions" width="250">

Add a New Run Script Action.

<img src="./images/new-run-script.png" alt="New Run Script Action" width="200">

Select the app target for **Provide build settings from**

<img src="./images/build-settings-target.png" alt="Build Settings Target Selection" width="450">

Paste the below shell script:

```ruby
if [[ "${ACTION}" == "clean" ]]; then
  cd "${PROJECT_DIR}"
  echo "Running Fuse.rb script..."
  ruby "${BUILD_DIR%Build/*}SourcePackages/checkouts/bbps-ios/Sources/BBPSSDK/Fuse.rb"
fi
```

This Script will be executed whenever you do **Clean Build Folder**.

### **Step 1.1b - Add BBPSConfig.json**

The BBPSConfig.json contains the clientIds which helps the Assets plugin to download assets specific to your application. Create a .json file named BBPSConfig.json inside the app directory of your project. Add clientConfigs to this file. Please note to add this to the folder where the project file is present.

_Sample:_

```json
{
 "clientConfigs": {
	"your-client-id": {}
 }
}
```

## **1.2. Installing BBPSSDK**

### Swift Package Manager

Add BBPSSDK to your project using Xcode:

1. Open your project in Xcode
2. Go to File → Add Package Dependencies

3. Enter the package URL: `https://github.com/juspay/bbps-ios.git`


4. Select the version you want to use


5. Add the package to your target


Or add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/juspay/bbps-ios.git", from: "1.0.0")
]
```
## License

This project is licensed under the MIT License - see the LICENSE file for details.