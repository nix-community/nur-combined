{
  stdenvNoCC,
  lmstudio,
  fetchurl,
  undmg,
  lib,
  ...
}:
if stdenvNoCC.isDarwin
then let
  ver = lib.helper.read ./version.json;

  src = fetchurl (lib.helper.getSingle ver);
  inherit (ver) version;
in
  stdenvNoCC.mkDerivation {
    pname = "lmstudio";

    inherit version src;

    nativeBuildInputs = [undmg];

    sourceRoot = ".";

    dontBuild = true;
    dontFixup = true;

    # undmg doesn't support APFS and 7zz does break the xattr.
    # Took that approach from https://github.com/NixOS/nixpkgs/blob/a3c6ed7ad2649c1a55ffd94f7747e3176053b833/pkgs/by-name/in/insomnia/package.nix#L52
    # and https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/lm/lmstudio/darwin.nix
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
      /usr/bin/hdiutil attach -nobrowse -mountpoint $mnt $curSrc
      # Copy content to local dir for later use
      echo 'Copying extracted content into "sourceRoot"'
      cp -a $mnt/LM\ Studio.app $PWD/
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
      runHook postInstall
    '';

    postInstall = ''
      sed -i 's|_0x345c2d && !_0x44174f\.startsWith(_0x4ce401(0x1185)) && \(|false && \(|g' "$out/Applications/LM Studio.app/Contents/Resources/app/.webpack/main/index.js"
    '';

    meta = {
      description = "LM Studio is an easy to use desktop app for experimenting with local and open-source Large Language Models (LLMs)";
      homepage = "https://lmstudio.ai/";
      license = lib.licenses.unfree;
      mainProgram = "lm-studio";
      maintainers = ["Prinky" "crertel"];
      platforms = ["aarch64-darwin"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
else lmstudio
