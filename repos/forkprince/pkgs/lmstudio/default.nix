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
      mnt=$(TMPDIR=/tmp mktemp -d -t nix-XXXXXXXXXX)
      function finish {
        /usr/bin/hdiutil detach $mnt -force
        rm -rf $mnt
      }
      trap finish EXIT
      /usr/bin/hdiutil attach -nobrowse -mountpoint "$mnt" "$curSrc"
      cp -a "$mnt"/LM\ Studio.app "$PWD/"
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -r *.app $out/Applications
      runHook postInstall
    '';

    postInstall = ''
      # Patch to allow running from non-/Applications location on macOS
      # This modifies the check that prevents LM Studio from running outside /Applications
      # The minified code uses: _0x345c2d&&!_0x44174f['startsWith'](_0x4ce401(0x1185))&&
      substituteInPlace "$out/Applications/LM Studio.app/Contents/Resources/app/.webpack/main/index.js" \
        --replace "_0x345c2d&&!_0x44174f['startsWith'](_0x4ce401(0x1185))&&" "false&&"
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
