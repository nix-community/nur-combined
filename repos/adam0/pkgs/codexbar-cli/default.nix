{
  # keep-sorted start
  autoPatchelfHook,
  curl,
  fetchurl,
  lib,
  libxml2_13,
  sqlite,
  stdenv,
  stdenvNoCC,
  # keep-sorted end
}: let
  inherit (lib) getLib;
  inherit
    (builtins)
    # keep-sorted start
    fromJSON
    readFile
    # keep-sorted end
    ;

  pname = "codexbar-cli";
  release = fromJSON (readFile ./release.json);
  inherit (release) version;

  assets = {
    # keep-sorted start
    aarch64-linux = "CodexBarCLI-v${version}-linux-aarch64.tar.gz";
    x86_64-linux = "CodexBarCLI-v${version}-linux-x86_64.tar.gz";
    # keep-sorted end
  };

  system = stdenvNoCC.hostPlatform.system;
  asset = assets.${system} or (throw "${pname} is only packaged for x86_64-linux and aarch64-linux");
in
  stdenvNoCC.mkDerivation {
    inherit
      # keep-sorted start
      pname
      version
      # keep-sorted end
      ;

    src = fetchurl {
      url = "https://github.com/steipete/CodexBar/releases/download/v${version}/${asset}";
      hash = release.hashes.${system};
    };

    sourceRoot = ".";

    nativeBuildInputs = [autoPatchelfHook];
    buildInputs =
      map getLib [
        # keep-sorted start
        curl
        libxml2_13
        sqlite
        # keep-sorted end
      ]
      ++ [stdenv.cc.cc.lib];

    installPhase = ''
      runHook preInstall

      install -Dm755 CodexBarCLI $out/bin/CodexBarCLI
      install -Dm755 codexbar $out/bin/codexbar
      cp -r CodexBar_CodexBarCore.bundle $out/bin/

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      $out/bin/codexbar --help > /dev/null
    '';

    meta = with lib; {
      # keep-sorted start
      description = "CLI tool to track AI provider usage limits";
      homepage = "https://github.com/steipete/CodexBar";
      license = licenses.mit;
      mainProgram = "codexbar";
      platforms = platforms.linux;
      sourceProvenance = [sourceTypes.binaryNativeCode];
      # keep-sorted end
    };
  }
