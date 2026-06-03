{
  lib,
  stdenv,
  fetchFromGitHub,
  bun,
  makeWrapper,
  electron,
  copyDesktopItems,
  makeDesktopItem,
}:

let
  pname = "meru";
  version = "3.46.1";

  src = fetchFromGitHub {
    owner = "zoidsh";
    repo = "meru";
    rev = "v${version}";
    sha256 = "0nprlzypzi0h31f64lhmzilvbl2656j6f2qxcwv8vn7yqxldmbkl";
  };

  # Fixed-output derivation to fetch all node_modules using bun
  node_modules = stdenv.mkDerivation {
    name = "${pname}-node-modules-${version}";
    inherit src;
    nativeBuildInputs = [ bun ];

    env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

    buildPhase = ''
      # Bun needs a cache dir
      export BUN_INSTALL_CACHE_DIR=$(mktemp -d)
      bun install --no-save --frozen-lockfile --ignore-scripts

      mkdir -p $out
      cp -a node_modules $out/
    '';

    dontCheckForBrokenSymlinks = true;
    dontFixup = true;
    installPhase = "true";
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    outputHash = "sha256-htHeU6xSt3rRrqskY/I2xS3JUCpLiC11piELe4G0v0s=";
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    bun
    makeWrapper
    copyDesktopItems
  ];

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  buildPhase = ''
    runHook preBuild

    # copy node_modules to preserve relative symlinks to workspace packages
    cp -a ${node_modules}/node_modules node_modules

    bun run scripts/build.ts
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/meru
    cp -r build-js static package.json $out/lib/meru/

    # We must copy node_modules for runtime
    cp -r ${node_modules} $out/lib/meru/node_modules

    # Prune devDependencies for runtime? Since it's bun, we can't easily prune the FOD. 
    # But it's fine for now.

    install -Dm644 build/icons/512x512.png $out/share/icons/hicolor/512x512/apps/meru.png

    makeWrapper ${electron}/bin/electron $out/bin/meru \
      --add-flags "$out/lib/meru/build-js/app.js" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}"

    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  desktopItems = [
    (makeDesktopItem {
      name = "meru";
      exec = "meru %U";
      icon = "meru";
      desktopName = "Meru";
      comment = "Meru brings Gmail to your fingertips as a desktop app";
      categories = [
        "Network"
        "Office"
      ];
      startupWMClass = "Meru";
    })
  ];

  meta = {
    description = "Meru brings Gmail to your fingertips as a desktop app";
    homepage = "https://github.com/zoidsh/meru";
    license = lib.licenses.agpl3Only;
    mainProgram = "meru";
  };
}
