{
  lib,
  stdenv,
  autoPatchelfHook ? null,
  fetchurl,
  makeWrapper,
  unzip,
  wrapBuddy ? null,
  fzf,
  ripgrep,
  versionCheckHook,
  versionCheckHomeHook ? null,
  writeShellScriptBin,
}: let
  pname = "opencode-vim";
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hashes;

  platformMap = {
    x86_64-linux = {
      asset = "ocv-linux-x64.tar.gz";
      isZip = false;
    };
    aarch64-linux = {
      asset = "ocv-linux-arm64.tar.gz";
      isZip = false;
    };
    x86_64-darwin = {
      asset = "ocv-darwin-x64.zip";
      isZip = true;
    };
    aarch64-darwin = {
      asset = "ocv-darwin-arm64.zip";
      isZip = true;
    };
  };

  platform = stdenv.hostPlatform.system;
  platformInfo = platformMap.${platform} or (throw "Unsupported system: ${platform}");

  src = fetchurl {
    url = "https://github.com/leohenon/opencode/releases/download/v${version}/${platformInfo.asset}";
    hash = hashes.${platform};
  };
in
  stdenv.mkDerivation {
    inherit pname version src;

    nativeBuildInputs =
      [makeWrapper]
      ++ lib.optionals platformInfo.isZip [unzip]
      ++ lib.optionals (stdenv.hostPlatform.isLinux && autoPatchelfHook != null) [autoPatchelfHook]
      ++ lib.optionals (stdenv.hostPlatform.isLinux && wrapBuddy != null) [wrapBuddy];

    doInstallCheck = true;
    nativeInstallCheckInputs =
      [versionCheckHook]
      ++ lib.optionals (versionCheckHomeHook != null) [versionCheckHomeHook]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [(writeShellScriptBin "sysctl" "echo 0")];
    versionCheckKeepEnvironment = "PATH";

    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [stdenv.cc.cc.lib];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    unpackPhase =
      ''
        runHook preUnpack
      ''
      + lib.optionalString platformInfo.isZip ''
        unzip $src
      ''
      + lib.optionalString (!platformInfo.isZip) ''
        tar -xzf $src
      ''
      + ''
        runHook postUnpack
      '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      install -m755 opencode $out/bin/opencode

      wrapProgram $out/bin/opencode \
        --prefix PATH : ${
        lib.makeBinPath [
          fzf
          ripgrep
        ]
      }

      runHook postInstall
    '';

    passthru.category = "AI Coding Agents";

    meta = {
      description = "OpenCode Vim terminal AI coding agent";
      longDescription = ''
        OpenCode Vim is a terminal-based coding agent.
        This package tracks the leohenon/opencode fork with the opencode-vim feature set.
      '';
      homepage = "https://github.com/leohenon/opencode";
      changelog = "https://github.com/leohenon/opencode/releases/tag/v${version}";
      license = lib.licenses.mit;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      platforms = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      mainProgram = "opencode";
    };
  }
