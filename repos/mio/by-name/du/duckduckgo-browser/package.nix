{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  makeBinaryWrapper,
  unzip,
}:

let
  llamaCppArchive = fetchurl {
    url = "https://github.com/ggml-org/llama.cpp/releases/download/b12262/llama-b12262-xcframework.zip";
    hash = "sha256-cEqe3oLPoWHfy0lxOU/89h5MTQ88p60XNVqToPnXcYs=";
  };
in
stdenvNoCC.mkDerivation {
  pname = "duckduckgo-browser";
  version = "0-unstable-2026-11-27";

  src = fetchFromGitHub {
    owner = "duckduckgo";
    repo = "apple-browsers";
    rev = "1ba571870d886bcc7400a21039809dc93c46566f";
    hash = "sha256-VHsRY10k7v0mf/um/EFI9uGq1PA8cpDsbWwbRBXKrjk=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
    unzip
  ];
  patches = [ ./offline-llama.patch ];
  sourceRoot = "source/macOS";
  dontConfigure = true;
  dontFixup = true;

  buildPhase = ''
    runHook preBuild
    export HOME="$TMPDIR/home"
    mkdir -p "$HOME" "$TMPDIR/swiftpm-cache"
    export CFFIXED_USER_HOME="$HOME"
    export CLANG_MODULE_CACHE_PATH="$TMPDIR/clang-module-cache"
    export SWIFTPM_SANDBOX=0
    export XBS_DISABLE_SANDBOXED_BUILDS=1
    export LLAMA_CPP_ARCHIVE=${llamaCppArchive}
    /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild \
      -project DuckDuckGo-macOS.xcodeproj \
      -scheme "macOS Browser" \
      -configuration Release \
      -destination 'generic/platform=macOS' \
      -derivedDataPath "$TMPDIR/DerivedData" \
      -clonedSourcePackagesDirPath "$TMPDIR/swiftpm-cache" \
      -disableAutomaticPackageResolution \
      -onlyUsePackageVersionsFromResolvedFile \
      -IDEPackageSupportDisableManifestSandbox=YES \
      -IDEPackageSupportDisablePluginExecutionSandbox=YES \
      'OTHER_SWIFT_FLAGS=$(inherited) -Xfrontend -disable-sandbox' \
      ARCHS="$(/usr/bin/uname -m)" \
      ONLY_ACTIVE_ARCH=YES \
      CODE_SIGNING_ALLOWED=NO \
      build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications" "$out/bin"
    cp -R "$TMPDIR/DerivedData/Build/Products/Release/DuckDuckGo.app" "$out/Applications/"
    makeBinaryWrapper \
      "$out/Applications/DuckDuckGo.app/Contents/MacOS/DuckDuckGo" \
      "$out/bin/duckduckgo-browser"
    runHook postInstall
  '';

  meta = {
    description = "DuckDuckGo privacy browser for macOS, built from source";
    homepage = "https://github.com/duckduckgo/apple-browsers";
    license = lib.licenses.asl20;
    mainProgram = "duckduckgo-browser";
    platforms = lib.platforms.darwin;
  };
  __noChroot = true;
}
