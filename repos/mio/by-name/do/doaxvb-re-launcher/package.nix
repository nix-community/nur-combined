{
  lib,
  stdenv,
  cmake,
  fetchFromGitHub,
  fetchurl,
  ninja,
  nix-update-script,
  pkg-config,
  sdl3,
}:

let
  version = "0.7.0";

  # tools/launcher/CMakeLists.txt downloads this header at configure time,
  # with the hash pinned beside the download. The sandbox has no network, so
  # the same file is fetched here and handed to CMake as a local URL.
  stbImage = fetchurl {
    url = "https://raw.githubusercontent.com/nothings/stb/013ac3beddff3dbffafd5177e7972067cd2b5083/stb_image.h";
    hash = "sha256-WUwv411JSItDgtv67I+YNm3vyoGdkWrJW+zz519CALM=";
  };

  stbUrl = "https://raw.githubusercontent.com/nothings/stb/013ac3beddff3dbffafd5177e7972067cd2b5083/stb_image.h";
in
stdenv.mkDerivation {
  pname = "doaxvb-re-launcher";
  inherit version;

  src = fetchFromGitHub {
    owner = "NoRain211";
    repo = "doaxvb-re";
    tag = "v${version}";
    hash = "sha256-kyjVv88iiza1WpW+ewFh4DCamgDja5qOX6LtwrlaX3k=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [ sdl3 ];

  postPatch = ''
    substituteInPlace tools/launcher/CMakeLists.txt \
      --replace-fail '${stbUrl}' 'file://${stbImage}'
  '';

  # The tree's own CMakeLists builds the game, which needs the code generated
  # from a disc and the xboxrecomp submodule; the launcher is the separate
  # project in tools/launcher that upstream's build_launcher.py configures.
  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    cmake -S tools/launcher -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=Release

    cmake --build build --target recomp_launcher -j''${NIX_BUILD_CORES:-1}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 build/recomp_launcher "$out/bin/doaxvb-launcher"
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Launcher for the DOAXVB static recompilation of Dead or Alive Xtreme Beach Volleyball";
    longDescription = ''
      Dead or Alive Xtreme Beach Volleyball recompiled to a native program for
      Linux and macOS. The repository holds no game code: `build_game.sh`
      extracts and translates the XBE from your own Xbox disc into C, then
      compiles it with the project's runtime. This package is the launcher,
      which offers that build and then starts the result:

          doaxvb-launcher /path/to/checkout

      The launcher writes its settings, the built runner and the extracted
      disc under `private/` in the checkout, so point it at a writable copy of
      the source rather than the read-only store path.
    '';
    homepage = "https://github.com/NoRain211/doaxvb-re";
    changelog = "https://github.com/NoRain211/doaxvb-re/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    # The launcher is the macOS and Linux one; Windows builds it with tools/launcher.ps1.
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    mainProgram = "doaxvb-launcher";
  };
}
