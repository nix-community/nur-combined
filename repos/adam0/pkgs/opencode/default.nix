{
  # keep-sorted start
  autoPatchelfHook ? null,
  fetchurl,
  fzf,
  lib,
  makeWrapper,
  ripgrep,
  stdenv,
  unzip,
  versionCheckHomeHook ? null,
  versionCheckHook,
  wrapBuddy ? null,
  writeShellScriptBin,
  # keep-sorted end
}: let
  pname = "opencode-vim";
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version hashes;

  platformMap = {
    # keep-sorted start block=yes newline_separated=yes
    aarch64-darwin = {
      asset = "ocv-darwin-arm64.zip";
      isZip = true;
    };

    aarch64-linux = {
      asset = "ocv-linux-arm64.tar.gz";
      isZip = false;
    };

    x86_64-darwin = {
      asset = "ocv-darwin-x64.zip";
      isZip = true;
    };

    x86_64-linux = {
      asset = "ocv-linux-x64.tar.gz";
      isZip = false;
    };
    # keep-sorted end
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

    # keep-sorted start
    dontBuild = true;
    dontConfigure = true;
    dontStrip = true;
    # keep-sorted end

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
          # keep-sorted start
          fzf
          ripgrep
          # keep-sorted end
        ]
      }

      runHook postInstall
    '';

    passthru.category = "AI Coding Agents";

    meta = {
      # keep-sorted start block=yes newline_separated=yes
      changelog = "https://github.com/leohenon/opencode/releases/tag/v${version}";

      description = "OpenCode Vim terminal AI coding agent";

      homepage = "https://github.com/leohenon/opencode";

      license = lib.licenses.mit;

      longDescription = "OpenCode Vim is a terminal-based coding agent. This package tracks the leohenon/opencode fork with the opencode-vim feature set.";

      mainProgram = "opencode";

      platforms = [
        # keep-sorted start
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
        # keep-sorted end
      ];

      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
      # keep-sorted end
    };
  }
