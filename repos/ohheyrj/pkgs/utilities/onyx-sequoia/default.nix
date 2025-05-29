{ 
  lib,
  stdenv,
  fetchurl,
  _7zz,
  versionCheckHook,
  xcbuild,
  writeShellScript,
  config,
  generated,
}:

stdenv.mkDerivation {
  inherit (generated) pname version src;


  sourceRoot = ".";

  unpackCmd = ''
    echo "Creating temp directory"
    mnt=$(TMPDIR=/tmp mktemp -d -t nix-XXXXXXXXXX)
    function finish {
      echo "Ejecting temp directory"
      /usr/bin/hdiutil detach $mnt -force
      rm -rf $mnt
    }
    # Detach volume when receiving SIG "0"
    trap finish EXIT
    # Mount DMG file
    echo "Mounting DMG file into \"$mnt\""
    yes | PAGER=cat /usr/bin/hdiutil attach -nobrowse -noverify -noautoopen -mountpoint $mnt $curSrc
    # Copy content to local dir for later use
    echo 'Copying extracted content into "sourceRoot"'
    cp -a $mnt/OnyX.app $PWD/
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    mv OnyX.app $out/Applications/
    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/OnyX.app/Contents/Info.plist"
  ];
  doInstallCheck = true;

  meta = {
    homepage = "https://www.titanium-software.fr/en/onyx.html";
    changelog = "https://www.titanium-software.fr/en/onyx_release.html";
    description = "OnyX is a multifunction utility for MacOS Sequoia.";
    license = lib.licenses.unfree;
    platforms = [ "aarch64-darwin" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    broken = !(config.allowUnfree or false);
  };
}