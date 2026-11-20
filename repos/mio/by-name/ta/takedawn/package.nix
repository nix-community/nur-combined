{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  python3,
  resvg,
  SDL2,
  libepoxy,
  openssl,
  # Takedawn carries no game code: a build translates default.xbe from the
  # user's own Burnout 3 disc into C (src/game/recomp/gen, gitignored).
  # Point this at that extracted file, e.g.
  #   takedawn.override { defaultXbe = /path/to/default.xbe; }
  defaultXbe ? null,
  # Which retail disc the XBE comes from: NTSC-U, PAL or PAL-ENSV.
  region ? "NTSC-U",
}:

let
  version = "0.3.1";

  # The recompiler and Xbox runtime live in a checkout beside the game
  # (XBOXRECOMP_DIR); each release has its own tag there.
  toolkit = import ./toolkit.nix { inherit fetchFromGitHub; };

  # regen.sh drives the toolkit's Python stages (tools.xbe_parser, disasm,
  # func_id, abi_analysis, recomp) with capstone.
  python = python3.withPackages (ps: [ ps.capstone ]);

  discDirs = {
    "NTSC-U" = "Burnout 3 Takedown";
    "PAL" = "Burnout 3 Takedown (PAL)";
    "PAL-ENSV" = "Burnout 3 Takedown (PAL-ENSV)";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "takedawn";
  inherit version;

  src = fetchFromGitHub {
    owner = "xenophobentx";
    repo = "takedawn";
    tag = "v${version}";
    hash = "sha256-XtFzacM9siqkhDIpxvdYpowKybFJpGDdv1ibRu1d2ro=";
  };

  # The toolkit must sit at ../xboxrecomp (regen.sh) and the recompiler writes
  # its analysis and generated code into the game tree, so both are copied
  # into the writable build directory.
  postUnpack = ''
    mkdir xboxrecomp
    cp -r ${toolkit}/. xboxrecomp/
    chmod -R u+w xboxrecomp
    patchShebangs xboxrecomp/tools xboxrecomp/cmake
  '';

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    python
    resvg
  ];

  buildInputs = [
    SDL2
    libepoxy
    openssl
  ];

  dontConfigure = true;

  env.PYTHONDONTWRITEBYTECODE = "1";

  buildPhase = ''
    runHook preBuild

    ${lib.optionalString (defaultXbe == null) ''
      echo "takedawn: the build needs default.xbe from your own Burnout 3 disc." >&2
      echo "Extract it from a supported retail disc image and override the package:" >&2
      echo "  nix build --impure --expr 'with import ./. {}; takedawn.override { defaultXbe = /path/to/default.xbe; }'" >&2
      exit 1
    ''}

    export XBOXRECOMP_DIR="$PWD/xboxrecomp"
    mkdir -p "${discDirs.${region}}"
    cp ${lib.escapeShellArg (toString defaultXbe)} "${discDirs.${region}}/default.xbe"

    echo "==> translating ${region} default.xbe with the xboxrecomp toolkit"
    BO3_REGION=${lib.escapeShellArg region} ./regen.sh --disasm

    # Metal is the Mac backend: the Vulkan backend is a MoltenVK test bed and
    # needs glslang and the Vulkan loader. Elsewhere OpenGL via epoxy is used.
    cmake -S . -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DXBOXRECOMP_DIR="$XBOXRECOMP_DIR" \
      -DXBOXRECOMP_VULKAN=OFF \
      -DBO3_REGION=${lib.escapeShellArg region} \
      -DBO3_BIN_DIR="$PWD/bin" \
      -DBO3_GLYPHS_PYTHON="${python}/bin/python3"

    cmake --build build --target burnout3 -j''${NIX_BUILD_CORES:-1}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/burnout3 "$out/bin/takedawn"
    install -Dm644 config/enhance.toml.default "$out/share/takedawn/enhance.toml"
    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Native port of Burnout 3: Takedown (static recompilation, needs your own disc)";
    longDescription = ''
      Takedawn runs the original Xbox release of Burnout 3: Takedown as a
      native program. It ships no game data: the build translates
      default.xbe from your own retail disc into C, which is then compiled
      with the xboxrecomp runtime. The game itself is installed from your
      disc image on first start (`takedawn --install <image>`).
    '';
    homepage = "https://github.com/xenophobentx/takedawn";
    license = lib.licenses.mit;
    mainProgram = "takedawn";
    # Upstream builds macOS for Apple silicon; the Windows and Android
    # packages come from its own release scripts.
    platforms = [
      "aarch64-darwin"
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
