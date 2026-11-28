{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

let
  xcodeSandbox = import ../../../shared/xcode-sandbox.nix;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "blockblock";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "objective-see";
    repo = "BlockBlock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eviXLkHbOaOw38nv13RdJh20jxew4gsF/2Qc/gzeuFs=";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  sandboxProfile = xcodeSandbox.base;
  dontFixup = true;

  passthru.updateScript = nix-update-script { };

  buildPhase = ''
    runHook preBuild

    ${xcodeSandbox.envWithPath}
    mkdir -p "Application/Uninstaller/BlockBlock Installer.app"

    xcodebuild \
      -workspace BlockBlock.xcworkspace \
      -scheme Installer \
      -configuration Release \
      -derivedDataPath build \
      CODE_SIGN_IDENTITY="" \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGNING_ALLOWED=NO \
      DEVELOPMENT_TEAM="" \
      ENABLE_USER_SCRIPT_SANDBOXING=NO \
      build

    rm -rf "Application/Uninstaller/BlockBlock Installer.app"
    cp -R "build/Build/Products/Release/BlockBlock Installer.app" \
      "Application/Uninstaller/BlockBlock Installer.app"

    xcodebuild \
      -workspace BlockBlock.xcworkspace \
      -scheme Installer \
      -configuration Release \
      -derivedDataPath build \
      CODE_SIGN_IDENTITY="" \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGNING_ALLOWED=NO \
      DEVELOPMENT_TEAM="" \
      ENABLE_USER_SCRIPT_SANDBOXING=NO \
      build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"
    cp -R "build/Build/Products/Release/BlockBlock Installer.app" "$out/Applications/"
    ln -s "$out/Applications/BlockBlock Installer.app/Contents/MacOS/BlockBlock Installer" "$out/bin/blockblock-installer"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    installer="$out/Applications/BlockBlock Installer.app"
    test -x "$installer/Contents/MacOS/BlockBlock Installer"
    test -d "$installer/Contents/Resources/BlockBlock.app"
    test -d "$installer/Contents/Resources/BlockBlock Helper.app"
    test -d "$installer/Contents/Resources/BlockBlock Helper.app/Contents/Resources/BlockBlock Installer.app"
    /usr/bin/plutil -lint "$installer/Contents/Info.plist"
  '';

  meta = {
    description = "Monitor persistence locations and alert when software installs itself";
    homepage = "https://github.com/objective-see/BlockBlock";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
    hydraPlatforms = [ ];
    mainProgram = "blockblock-installer";
  };
})
