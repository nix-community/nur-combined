# Install the server, settings application, Fcitx5 addon, and pinned product data together.
{
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  openssl,
  oniguruma,
  cmake,
  fcitx5,
  nlohmann_json,
  fetchurl,
  fetchgit,
  makeWrapper,
  wayland,
  libxkbcommon,
  libX11,
  libXext,
  libxcb,
  libXcursor,
  libXi,
  libXrandr,
  noto-fonts,
  noto-fonts-cjk-sans,
  noto-fonts-color-emoji,
}:
let
  source = lib.importJSON ./source.json;
  src = fetchgit {
    url = "https://github.com/${source.owner}/${source.repo}.git";
    inherit (source) rev;
    hash = source.narHash;
  };
  version = "0.3.3";
  dataLock = builtins.fromTOML (
    lib.concatMapStringsSep "\n" (
      line:
      let
        parts = lib.splitString " = " line;
      in
      if builtins.length parts == 2 then
        ''"${builtins.elemAt parts 0}" = "${builtins.elemAt parts 1}"''
      else
        line
    ) (lib.splitString "\n" (builtins.readFile ./data.lock))
  );
  productData = fetchurl {
    url = "https://github.com/qingjian-team/qingjian/releases/download/${dataLock.tag}/qingjian-data.tar.gz";
    sha256 = dataLock."qingjian-data.tar.gz";
  };
  server = rustPlatform.buildRustPackage {
    pname = "qingjian-linux-server";
    inherit version src;
    cargoLock = {
      lockFile = ./Cargo.lock;
      outputHashes."cosmic-text-0.19.0" = "sha256-c7DuyTTF5vkClCeGGIWBX4HAMecA+1RujvVA0fcTQRE=";
    };
    nativeBuildInputs = [ pkg-config ];
    buildInputs = [
      openssl
      oniguruma
    ];
    env.RUSTONIG_SYSTEM_LIBONIG = "1";
    # Upstream uses absolute font paths from traditional distributions.
    # Tests and runtime font discovery both need fonts from the Nix store.
    postPatch = ''
      substituteInPlace crates/bamboo-slip/src/fonts/linux.rs \
        --replace-fail /usr/share/fonts/truetype/noto/NotoSans-Regular.ttf ${noto-fonts}/share/fonts/noto/NotoSans.ttf \
        --replace-fail /usr/share/fonts/truetype/noto/NotoSans-Bold.ttf ${noto-fonts}/share/fonts/noto/NotoSans.ttf \
        --replace-fail /usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc ${noto-fonts-cjk-sans}/share/fonts/opentype/noto-cjk/NotoSansCJK-VF.otf.ttc \
        --replace-fail /usr/share/fonts/truetype/noto/NotoColorEmoji.ttf ${noto-fonts-color-emoji}/share/fonts/noto/NotoColorEmoji.ttf
    '';
    cargoBuildFlags = [
      "-p"
      "qingjian-linux-server"
      "-p"
      "qingjian-settings"
    ];
    cargoTestFlags = [
      "-p"
      "qingjian-linux-server"
      "-p"
      "qingjian-settings"
    ];
  };
in
stdenv.mkDerivation {
  pname = "fcitx5-qingjian";
  inherit version src;
  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];
  buildInputs = [
    fcitx5
    nlohmann_json
  ];
  cmakeDir = "../apps/linux/fcitx5";
  cmakeFlags = [
    "-DBUILD_TESTING=ON"
    "-DQINGJIAN_SERVER_EXECUTABLE=${server}/bin/qingjian-linux-server"
  ];
  doCheck = true;
  preCheck = ''
    unset DBUS_SESSION_BUS_ADDRESS
  '';
  postInstall = ''
    mkdir -p "$out/bin" "$out/share/qingjian/resources/assets"
    cp ${server}/bin/qingjian-linux-server "$out/bin/"
    cp ${server}/bin/qingjian-settings "$out/bin/"
    # Native Wayland submits frames but displays a black window under KDE.
    # Use the verified X11 backend when XWayland is available.
    # Keep the native backend in Wayland sessions without DISPLAY.
    wrapProgram "$out/bin/qingjian-settings" \
      --run 'if [ -n "''${DISPLAY:-}" ]; then unset WAYLAND_DISPLAY WAYLAND_SOCKET; fi' \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          wayland
          libxkbcommon
          libX11
          libXext
          libxcb
          libXcursor
          libXi
          libXrandr
        ]
      }
    for kind in sample glossary levels emoji; do
      cp -r "$src/assets/$kind" "$out/share/qingjian/resources/assets/"
    done
    tar -xzf ${productData} -C "$out/share/qingjian/resources"
    test -f "$out/share/qingjian/resources/data/generated/dict.qj"
    test -f "$out/share/qingjian/resources/data/models/hanzhang-tongbian/hanzhang-tongbian-small.qjm"
    mkdir -p "$out/share/icons"
    cp -r "$src/assets/icon/linux/hicolor" "$out/share/icons/"
    install -Dm644 "$src/apps/settings/linux/qingjian-settings.desktop" "$out/share/applications/qingjian-settings.desktop"
    install -Dm644 "$src/LICENSE" "$out/share/licenses/qingjian/LICENSE"
    install -Dm644 "$src/assets/stroke/LICENSE-CNS11643.txt" "$out/share/licenses/qingjian/LICENSE-CNS11643.txt"
  '';
  meta = {
    description = "Qingjian input method with an Fcitx5 addon, local engine, and dictionary";
    homepage = "https://qingjian.app";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "qingjian-linux-server";
  };
}
