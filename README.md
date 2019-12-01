# NativeKit

Build Native MacOS App in Javascript. This project was developed in Swift and uses JavaScriptCore to execute the

Based on Electron API

## Goals

The project is designed to create apps from Javascript. It was designed for my app [ElectronPlayer](https://github.com/oscartbeaumont/ElectronPlayer) and currently NativeKit is hardcoded for this app but in the near future (before the project is out of alpha) that is going to be fixed so it can be used by any project. It has an intercompatible API with Electron and was designed as an alternative to Electron that is able to play DRM protected content such as online streaming services. It doesn't support Widevine but supports Apples fairplay standard which is also supported by streaming services. It is also very lightweight when compared to Electron and this also makes it very fast.

## Usage

The current usage is quite messy to use. In the future the cli will be published to npm and the NativeKit template app built from Xcode will be published to Github Releases so Xcode is not required to develop using NativeKit.

```bash
git clone https://github.com/oscartbeaumont/NativeKit.git
cd NativeKit/
cd cli/
npm i
npm link
# Build NativeKit.app using Xcode (project in the app/ folder) then copy it to this cli/ directory
cd ../examples/electronplayer/
npm i
npm run build
# ElectronPlayer.app will be in the current dir and can be executed
```
