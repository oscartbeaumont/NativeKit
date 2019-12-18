const path = require('path');
const fs = require('fs-extra');
const Bundler = require('parcel-bundler');
const plist = require('plist');

module.exports = async (projectDir: String) => {
  // TODO: Remove hardcoded values
  const nativeKitSource = path.join(__dirname, './NativeKit.app/Contents');
  const config = {
    identifier: 'me.oscartbeaumont.ElectronPlayer',
    name: 'ElectronPlayer',
    version: '3.0.0',
    category: 'public.app-category.developer-tools',
    copyright: 'Copyright © 2020 Oscar Beaumont. All rights reserved.',
    source: path.resolve('./src'),
    sourceInterface: path.resolve('./src-interface'), // TODO: Remove need for this src splitting
    icon: path.resolve('./build/icon.icns'),
    output: path.resolve('./ElectronPlayer.app')
  };
  await fs.mkdir(path.join(config.output, 'Contents', 'MacOS'), {
    recursive: true
  });
  await fs.writeFile(
    path.join(config.output, 'Contents', 'PkgInfo'),
    'APPL????'
  );
  await fs.copy(
    path.join(nativeKitSource, 'Frameworks'),
    path.join(config.output, 'Contents', 'Frameworks')
  );
  await fs.copy(
    path.join(nativeKitSource, 'MacOS', 'NativeKit'),
    path.join(config.output, 'Contents', 'MacOS', config.name)
  );
  await fs.copy(
    config.icon,
    path.join(config.output, 'Contents', 'Resources', 'icon.icns')
  );
  // TODO: So much bad, bad hardcoding
  await new Bundler(path.join(config.sourceInterface, '*', '**'), {
    outDir: path.join(config.output, 'Contents', 'Resources', 'interface'),
    target: 'web',
    publicUrl: '.',
    watch: false,
    minify: true, // TODO: Only production
    scopeHoist: true, // TODO: Only production
    bundleNodeModules: true,
    sourceMaps: false
  }).bundle();
  // TODO: Get entrypoint from package.json
  await new Bundler(path.join(config.source, 'main.(js|ts)'), {
    outDir: path.join(config.output, 'Contents', 'Resources'),
    outFile: 'main.js',
    target: 'node',
    publicUrl: '.',
    watch: false,
    minify: true, // TODO: Only production
    scopeHoist: true, // TODO: Only production
    bundleNodeModules: true,
    sourceMaps: false
  }).bundle();
  let infoPlist = plist.build({
    CFBundleVersion: config.version.toString(),
    CFBundleDevelopmentRegion: 'en',
    CFBundleExecutable: config.name,
    CFBundleIconFile: 'icon',
    CFBundleIdentifier: config.identifier,
    CFBundleInfoDictionaryVersion: '6.0',
    CFBundleName: config.name,
    CFBundlePackageType: 'APPL',
    CFBundleShortVersionString: config.version.toString(),
    LSApplicationCategoryType: config.category,
    NSHumanReadableCopyright: config.copyright,
    NSPrincipalClass: 'NSApplication',
    NSSupportsAutomaticTermination: true,
    NSSupportsSuddenTermination: true,
    NSAppTransportSecurity: {
      NSAllowsArbitraryLoads: true
    },
    'com.apple.security.app-sandbox': true
    // ''

    //   CFBundleSupportedPlatforms: ['MacOSX'],
    //   BuildMachineOSBuild: '18G1012',
    //   DTCompiler: 'com.apple.compilers.llvm.clang.1_0',
    //   DTPlatformBuild: '11B52',
    //   DTPlatformVersion: 'GM',
    //   DTSDKBuild: '19B81',
    //   DTSDKName: 'macosx10.15',
    //   DTXcode: '1120',
    //   DTXcodeBuild: '11B52',
    //   LSMinimumSystemVersion: '10.14',
  });
  await fs.writeFile(
    path.join(config.output, 'Contents', 'Info.plist'),
    infoPlist
  );

  // TODO:
  // codesign --sign "{CERTNAME}" ./ElectronPlayer.app --force

  // TODO: Code Sign, Entitlements??? (Does the app remain in sandbox?)
};
