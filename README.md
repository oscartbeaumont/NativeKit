# NativeKit

> Build native MacOS apps in Javascript (or Typescript).

An app building framework similar to Electron allowing for Javascript developers to create native MacOS applications.

## How it works?

This project is made of 3 parts:

1. Template MacOS app developed in Xcode using the Swift programming language. This app executes the users Javascript which is included in the app bundle inside a modified JavaScriptCore. It also exposes the operating system functions required for UI creation and management
2. Command line interface exposing preconfigured build tooling
3. Library which allows for type checking

## Goals

The project is designed to create apps from Javascript. It was designed for my app [ElectronPlayer](https://github.com/oscartbeaumont/ElectronPlayer) and currently NativeKit is hardcoded for this app but in the near future (before the project is out of alpha) that is going to be fixed so it can be used by any project. It has a somewhat intercompatible API with Electron and was designed as an alternative to Electron that is able to play DRM protected content such as online streaming services. It doesn't support Widevine but supports Apples Fairplay standard which is also supported by common streaming services. It is very lightweight (small file size & low RAM usage) when compared to Electron and this makes it very fast.

## API

The NativeKit API is modelled after Electron but is still missing some of the functionality or changes may have been made to make it easier to work with. The exposed API is declared in Typescript and can be viewied in the [`lib/index.d.ts`](lib/index.d.ts) file.

## Usage

The current usage is quite messy to use. In the future the cli will be published to npm and the NativeKit template app built from Xcode will be published to Github Releases so Xcode is not required to develop using NativeKit.

```bash
git clone https://github.com/oscartbeaumont/NativeKit.git
cd NativeKit/
npm i
npm run build
# Build NativeKit.app using Xcode (project in the app/ folder) then copy it to this dist/cli/ directory
cd ./examples/electronplayer/
npm i
npm run build
# ElectronPlayer.app will be in the current dir and can be executed
codesign --force --deep --sign - ./ElectronPlayer.app # This prevents the app being detected as damaged in Catalina
```
