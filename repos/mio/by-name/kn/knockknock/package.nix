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
  pname = "knockknock";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "objective-see";
    repo = "KnockKnock";
    tag = "v${finalAttrs.version}";
    hash = "sha256-d2FixqlkmXpOMZ2WVI000Qn4cydEW6ZTaJZgO6D5Jt8=";
  };

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  sandboxProfile = xcodeSandbox.base;
  dontFixup = true;

  passthru.updateScript = nix-update-script { };

  buildPhase = ''
    runHook preBuild

    ${xcodeSandbox.envWithPath}
    xcodebuild \
      -project KnockKnock.xcodeproj \
      -scheme KnockKnock \
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
    cp -R build/Build/Products/Release/KnockKnock.app "$out/Applications/"
    ln -s "$out/Applications/KnockKnock.app/Contents/MacOS/KnockKnock" "$out/bin/knockknock"

    runHook postInstall
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    test -x "$out/Applications/KnockKnock.app/Contents/MacOS/KnockKnock"
    /usr/bin/plutil -lint "$out/Applications/KnockKnock.app/Contents/Info.plist"
  '';

  meta = {
    description = "Enumerate persistently installed software on macOS";
    homepage = "https://github.com/objective-see/KnockKnock";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
    hydraPlatforms = [ ];
    mainProgram = "knockknock";
  };
})
