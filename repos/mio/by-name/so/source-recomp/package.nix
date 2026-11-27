{
  lib,
  stdenv,
  clangStdenv,
  buildEnv,
  fetchFromGitHub,
  makeWrapper,
  SDL2,
  freetype,
  fontconfig,
  dejavu_fonts,
  llvmPackages,
  python3,
  bash,
  curl,
  git,
  gnutar,
  gzip,
  xz,
  zstd,
  unzip,
  which,
  gnused,
  coreutils,
  findutils,
  cmake,
  ninja,
  pkg-config,
  xcodegen,
  nix-update-script,
  writeText,
}:

let
  # Upstream's Makefile and Python build driver use a single prefix for the
  # host bridge libraries. Keep that layout while sourcing every component
  # from Nix instead of Homebrew.
  hostLibraries = buildEnv {
    name = "source-recomp-host-libraries";
    paths = [
      SDL2
      (lib.getDev SDL2)
      freetype
      (lib.getDev freetype)
      fontconfig
      (lib.getDev fontconfig)
    ];
  };

  runtimeTools = [
    bash
    python3
    clangStdenv.cc
    llvmPackages.bintools
    curl
    git
    gnutar
    gzip
    xz
    zstd
    unzip
    which
    gnused
    coreutils
    findutils
    cmake
    ninja
    pkg-config
    xcodegen
  ];

  fontsConf = writeText "source-recomp-fonts.conf" ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
    <fontconfig>
      <include>${fontconfig.out}/etc/fonts/fonts.conf</include>
      <dir>${dejavu_fonts}/share/fonts/truetype</dir>
    </fontconfig>
  '';
in
clangStdenv.mkDerivation (
  finalAttrs:
  {
    pname = "source-recomp";
    version = "0.4.0";

    src = fetchFromGitHub {
      owner = "kanapitsas";
      repo = "source-recomp";
      tag = "v${finalAttrs.version}";
      hash = "sha256-p7Y9UWECMQ2nZC2z1C01p1ycPCD+vWtHO/vGoj4AmOA=";
    };

    patches = [ ./pe-fixture-clang.patch ];

    nativeBuildInputs = [
      makeWrapper
      python3
      llvmPackages.bintools
    ];

    buildInputs = [
      SDL2
      freetype
      fontconfig
      dejavu_fonts
    ];

    dontConfigure = true;

    preBuild = ''
      export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
      export XDG_CACHE_HOME="$TMPDIR/fontconfig-cache"
      mkdir -p "$XDG_CACHE_HOME"
    '';

    env = {
      FONTCONFIG_FILE = fontsConf;
      P2_HOST_PREFIX = hostLibraries;
      PE_FIXTURE_CLANG = "${llvmPackages.clang-unwrapped}/bin/clang";
      PYTHON = "${python3}/bin/python3";
    };

    buildPhase = ''
      runHook preBuild
      make -j''${NIX_BUILD_CORES:-1} build/abi-smoke \
        CC=${clangStdenv.cc}/bin/clang
      runHook postBuild
    '';

    doCheck = true;
    checkPhase = ''
      runHook preCheck
      make check CC=${clangStdenv.cc}/bin/clang
      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/source-recomp" "$out/libexec"
      cp -R ${finalAttrs.src}/. "$out/share/source-recomp/"

      cat > "$out/libexec/source-recomp-setup" <<'EOF'
      #!/usr/bin/env bash
      set -euo pipefail

      state="''${SOURCE_RECOMP_STATE:-''${XDG_DATA_HOME:-$HOME/.local/share}/source-recomp/src}"
      mkdir -p "$state"
      cp -Rf "@source@/." "$state"/
      chmod -R u+w "$state"
      cd "$state"
      exec ./setup.sh "$@"
      EOF
      substituteInPlace "$out/libexec/source-recomp-setup" \
        --replace-fail '@source@' "$out/share/source-recomp"
      chmod +x "$out/libexec/source-recomp-setup"

      makeWrapper ${bash}/bin/bash "$out/bin/source-recomp" \
        --add-flags "$out/libexec/source-recomp-setup" \
        --set-default P2_HOST_DEPS bundle \
        --prefix PATH : ${lib.makeBinPath runtimeTools}

      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      SOURCE_RECOMP_STATE="$TMPDIR/source-recomp-state" \
        "$out/bin/source-recomp" --help | grep -F 'usage: ./setup.sh'
      runHook postInstallCheck
    '';

    passthru.updateScript = nix-update-script { };

    meta = {
      description = "Portal 2, Half-Life 2 and Portal static recompiler for Apple silicon";
      longDescription = ''
        Source-recomp translates the x86 Linux binaries from the user's own
        Steam copies of Portal 2, Half-Life 2 and Portal into C, then compiles
        them into native Apple silicon applications. The game code is generated
        locally and is not included in this package.

        Run `source-recomp --detect` to locate complete Steam installations and
        Linux depots, or pass the game and depot directories explicitly. Builds
        and local configuration are stored in
        `$XDG_DATA_HOME/source-recomp/src` by default; override that location with
        `SOURCE_RECOMP_STATE`.
      '';
      homepage = "https://github.com/kanapitsas/source-recomp";
      changelog = "https://github.com/kanapitsas/source-recomp/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.gpl3Only;
      mainProgram = "source-recomp";
      platforms = [ "aarch64-darwin" ];
      sourceProvenance = [ lib.sourceTypes.fromSource ];
      hydraPlatforms = [ ];
    };
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Upstream's macOS tests invoke system tools (`/bin/cp`, `xcode-select`, and
    # the SDK) which are not visible inside Nix's Darwin sandbox.
    __noChroot = true;
  }
)
