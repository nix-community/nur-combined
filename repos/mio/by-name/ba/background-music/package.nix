{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:

let
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "background-music";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "kyleneideck";
    repo = "BackgroundMusic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EvrM6HWn/1sIQUoUr8oCY/vHyVZC+c+41R1JYNPKSOI=";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];

  sandboxProfile = xcodeSandbox.base;

  postPatch = ''
    substituteInPlace build_and_install.sh \
      --replace-fail \
        'local PREV_COMMAND_STRING=$(ps -o command= ''${CHILD_PID})' \
        'local PREV_COMMAND_STRING=$(ps -o command= ''${CHILD_PID} 2>/dev/null || echo "build command")'

    for project in BGMApp/BGMApp.xcodeproj/project.pbxproj BGMDriver/BGMDriver.xcodeproj/project.pbxproj; do
      substituteInPlace "$project" \
        --replace-fail 'MACOSX_DEPLOYMENT_TARGET = 10.13;' \
          'MACOSX_DEPLOYMENT_TARGET = 12.0;'
    done

    # The GitHub source archive has no Git metadata. Treat it as the release tag
    # so upstream's snapshot-version phase leaves the checked-in version alone.
    substituteInPlace SharedSource/Scripts/set-version.sh \
      --replace-fail \
        'TAG=$(/usr/bin/git tag --points-at HEAD --sort='"'"'-taggerdate'"'"' 2>/dev/null | head -n 1)' \
        'TAG="v${finalAttrs.version}"'

    # The schemes enable coverage for their test actions, but xcodebuild applies
    # that to these command-line builds as well. Release bundles must not carry
    # LLVM profiling counters or emit default.profraw at runtime.
    for project in BGMApp/BGMApp.xcodeproj/project.pbxproj BGMDriver/BGMDriver.xcodeproj/project.pbxproj; do
      substituteInPlace "$project" \
        --replace-fail 'buildSettings = {' \
          'buildSettings = {
                CLANG_ENABLE_CODE_COVERAGE = NO;'
    done

  '';

  buildPhase = ''
    runHook preBuild

    ${xcodeSandbox.envWithPath}
    export TERM=xterm-256color

    # stdenv points SDKROOT at nixpkgs' SDK; upstream's script wants Xcode's.
    unset SDKROOT

    /bin/bash ./build_and_install.sh \
      -b \
      -x GCC_TREAT_WARNINGS_AS_ERRORS=NO

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p \
      "$out/Applications" \
      "$out/Library/Audio/Plug-Ins/HAL" \
      "$out/libexec" \
      "$out/bin"

    cp -R "BGMApp/build/Release/Background Music.app" "$out/Applications/"
    cp -R "BGMDriver/build/Release/Background Music Device.driver" \
      "$out/Library/Audio/Plug-Ins/HAL/"
    cp -R BGMApp/build/Release/BGMXPCHelper.xpc "$out/libexec/"

    rm -rf \
      "$out/Applications/Background Music.app/Contents/MacOS/Background Music.dSYM" \
      "$out/Applications/Background Music.app/Contents/Frameworks" \
      "$out/libexec/BGMXPCHelper.xpc/Contents/Frameworks"

    for binary in \
      "$out/Applications/Background Music.app/Contents/MacOS/Background Music" \
      "$out/libexec/BGMXPCHelper.xpc/Contents/MacOS/BGMXPCHelper" \
      "$out/Library/Audio/Plug-Ins/HAL/Background Music Device.driver/Contents/MacOS/Background Music Device"; do
      if otool -L "$binary" | grep -F libclang_rt.ubsan_osx_dynamic.dylib \
        || otool -l "$binary" | grep -E '__llvm_(prf|cov)'; then
        echo "unexpected sanitizer or coverage artifact in $binary" >&2
        exit 1
      fi
    done

    /usr/bin/codesign --force --options runtime \
      --entitlements BGMApp/BGMApp/BGMApp.entitlements --sign - \
      "$out/Applications/Background Music.app"
    /usr/bin/codesign --force --options runtime --sign - \
      "$out/libexec/BGMXPCHelper.xpc"
    /usr/bin/codesign --force --options runtime --sign - \
      "$out/Library/Audio/Plug-Ins/HAL/Background Music Device.driver"

    ln -s \
      "$out/Applications/Background Music.app/Contents/MacOS/Background Music" \
      "$out/bin/background-music"

    runHook postInstall
  '';

  dontFixup = true;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -x "$out/Applications/Background Music.app/Contents/MacOS/Background Music"
    test -x "$out/Library/Audio/Plug-Ins/HAL/Background Music Device.driver/Contents/MacOS/Background Music Device"
    test -x "$out/libexec/BGMXPCHelper.xpc/Contents/MacOS/BGMXPCHelper"
    test -x "$out/bin/background-music"
    /usr/bin/plutil -lint "$out/Applications/Background Music.app/Contents/Info.plist"
    test "$(/usr/bin/plutil -extract CFBundleShortVersionString raw "$out/Applications/Background Music.app/Contents/Info.plist")" = "${finalAttrs.version}"
    test ! -e "$out/Applications/Background Music.app/Contents/Frameworks"
    test ! -e "$out/libexec/BGMXPCHelper.xpc/Contents/Frameworks"
    /usr/bin/codesign --verify --strict "$out/Applications/Background Music.app"
    /usr/bin/codesign --verify --strict "$out/libexec/BGMXPCHelper.xpc"
    /usr/bin/codesign --verify --strict "$out/Library/Audio/Plug-Ins/HAL/Background Music Device.driver"
    /usr/bin/codesign -d --entitlements :- "$out/Applications/Background Music.app" 2>/dev/null \
      | grep -F com.apple.security.automation.apple-events
    /usr/bin/codesign -d --entitlements :- "$out/Applications/Background Music.app" 2>/dev/null \
      | grep -F com.apple.security.device.audio-input

    runHook postInstallCheck
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Per-application volume mixer and audio utility for macOS";
    homepage = "https://github.com/kyleneideck/BackgroundMusic";
    downloadPage = "https://github.com/kyleneideck/BackgroundMusic/releases";
    changelog = "https://github.com/kyleneideck/BackgroundMusic/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    mainProgram = "background-music";
    platforms = lib.platforms.darwin;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    # Building needs the host Xcode, which no Nix builder provides.
    hydraPlatforms = [ ];
  };
})
