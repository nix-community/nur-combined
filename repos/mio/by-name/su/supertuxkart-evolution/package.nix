{
  lib,
  pkgs,
  clangStdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  makeBinaryWrapper,
  SDL2,
  glew,
  openal,
  libvorbis,
  libogg,
  curl,
  freetype,
  libjpeg,
  libpng,
  libX11,
  harfbuzz,
  mcpp,
  wiiuse,
  angelscript,
  libopenglrecorder,
  sqlite,
  libsamplerate,
  shaderc,
  nix-update-script,
  coreutils,
  gnused,
  git,
  jq,
  nix,
  writeShellApplication,
}:
let
  # clang + x86-64-v3 flags on x86_64 (what `v3override` applied before the by-name move).
  stdenv = (import ../../../private.nix { inherit pkgs; }).v3Optimizations clangStdenv;

  assets = fetchFromGitHub {
    owner = "Pttn";
    repo = "stk-assets";
    rev = "56b611c0fab2a9dabb57ed4a7db05a1fa6330730";
    hash = "sha256-jk4FwuOm75BxqK6z1CcQ2loxL8Vc2MNcIyRLp+c5K1E=";
  };

  # List of bundled libraries in stk-code/lib to keep
  bundledLibraries = [
    "bullet"
    "enet"
    "graphics_engine"
    "graphics_utils"
    "simd_wrapper"
    "irrlicht"
    "libsquish"
    "sheenbidi"
    "tinygettext"
    "mojoal"
  ];
in
stdenv.mkDerivation {

  pname = "supertuxkart-evolution";
  version = "1.5-unstable-2026-09-23";

  src = fetchFromGitHub {
    owner = "supertuxkart";
    repo = "stk-code";
    # BalanceSTK2 branch commit
    rev = "bb0439d62e0cec65c133090171a06fa2d32d9aa9";
    hash = "sha256-tKbp7ezNKCEwA3Yr3tKT+n1bOVuPLbvvHU8PB21/z68=";
  };

  postPatch = ''
    # Deletes all bundled libs in stk-code/lib except those
    # That couldn't be replaced with system packages
    find lib -maxdepth 1 -type d | grep -Ev "^lib$|${(lib.concatStringsSep "|" bundledLibraries)}" | xargs -n1 -L1 -r -I{} rm -rf {}

    # Allow building with system-installed wiiuse on Darwin
    substituteInPlace CMakeLists.txt \
      --replace-fail 'NOT (APPLE OR HAIKU)) AND USE_SYSTEM_WIIUSE' 'NOT (HAIKU)) AND USE_SYSTEM_WIIUSE'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeBinaryWrapper
  ];

  buildInputs = [
    shaderc
    SDL2
    glew
    libvorbis
    libogg
    freetype
    curl
    libjpeg
    libpng
    libX11
    harfbuzz
    mcpp
    wiiuse
    angelscript
    sqlite
  ]
  ++ lib.optional (stdenv.hostPlatform.isWindows || stdenv.hostPlatform.isLinux) libopenglrecorder
  ++ lib.optional stdenv.hostPlatform.isLinux openal
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libsamplerate
  ];

  cmakeFlags = [
    "-DBUILD_RECORDER=${
      if (stdenv.hostPlatform.isWindows || stdenv.hostPlatform.isLinux) then "ON" else "OFF"
    }"
    "-DUSE_SYSTEM_ANGELSCRIPT=ON"
    "-DCHECK_ASSETS=OFF"
    "-DUSE_SYSTEM_WIIUSE=ON"
    "-DOpenGL_GL_PREFERENCE=GLVND"
  ];

  # NIX_CFLAGS_COMPILE = [ "-I${SDL2.dev}/include/SDL2" ]; # Maybe needed?

  CXXFLAGS = [
    "-include cstdio"
    "-include stdexcept"
  ];

  postInstall = ''
    # Rename binary
    if [ -f $out/bin/supertuxkart ]; then
      mv $out/bin/supertuxkart $out/bin/supertuxkart-evolution
    fi

    # Handle desktop file
    if [ -d $out/share/applications ]; then
      mv $out/share/applications/supertuxkart.desktop $out/share/applications/supertuxkart-evolution.desktop
      substituteInPlace $out/share/applications/supertuxkart-evolution.desktop \
        --replace-fail "Exec=supertuxkart" "Exec=supertuxkart-evolution" \
        --replace-fail "Name=SuperTuxKart" "Name=SuperTuxKart Evolution"
    fi

    # Handle macOS .app
    if [ -d $out/supertuxkart.app ]; then
      mv $out/supertuxkart.app $out/SuperTuxKart-Evolution.app
    fi
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin
    if [ -d $out/SuperTuxKart-Evolution.app ]; then
      mv $out/SuperTuxKart-Evolution.app/Contents/MacOS/supertuxkart $out/bin/supertuxkart-evolution
      rm -rf $out/SuperTuxKart-Evolution.app
    fi
  '';

  preFixup = ''
    wrapProgram $out/bin/supertuxkart-evolution \
      --set-default SUPERTUXKART_ASSETS_DIR "${assets}" \
      --set-default SUPERTUXKART_DATADIR "$out/share/supertuxkart"
  '';

  # The attribute is null in the default (on-nur-search) evaluation of default.nix,
  # and nix-update's --flake mode cannot open lazy-tree flake sources, so
  # point it at a throwaway file that imports the repo with on-nur-search = false.
  passthru.updateScript = writeShellApplication {
    name = "update-supertuxkart-evolution";
    runtimeInputs = [
      coreutils
      git
      gnused
      jq
      nix
    ];
    text = ''
      cd "$(git rev-parse --show-toplevel)"
      export UPDATE_NIX_ATTR_PATH="supertuxkart-evolution"
      file=by-name/su/supertuxkart-evolution/package.nix
      wrapper=$(mktemp --suffix=.nix)
      trap 'rm -f "$wrapper"' EXIT
      echo "args: import $PWD/default.nix (args // { on-nur-search = false; })" > "$wrapper"
      ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [ "--version=branch=BalanceSTK2" ];
        })
      } --file "$wrapper" "$@"
      # nix-update takes the base from upstream's newest release tag (`preview`);
      # keep the game's own base version instead.
      sed -i -E 's/^(  version = ")[^"]*-unstable-/\11.5-unstable-/' "$file"

      # Evolution assets: track Pttn/stk-assets main alongside the code.
      assetsRev=$(git ls-remote https://github.com/Pttn/stk-assets refs/heads/main | cut -f1)
      assetsHash=$(nix flake prefetch --json "github:Pttn/stk-assets/$assetsRev" | jq -r .hash)
      sed -i -E "/repo = \"stk-assets\";/,/hash = / {
        s|rev = \"[^\"]*\"|rev = \"$assetsRev\"|
        s|hash = \"[^\"]*\"|hash = \"$assetsHash\"|
      }" "$file"
    '';
  };

  meta = {
    description = "3D open-source arcade racer (Evolution branch)";
    mainProgram = "supertuxkart-evolution";
    homepage = "https://supertuxkart.net/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
