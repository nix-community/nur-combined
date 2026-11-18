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
  version = "0.3.4";
  readDataLock =
    file:
    map
      (
        line:
        let
          fields = builtins.match "([^ ]+) = ([0-9a-f]{64}) ([^ ]+)" line;
        in
        {
          tag = builtins.elemAt fields 0;
          sha256 = builtins.elemAt fields 1;
          path = builtins.elemAt fields 2;
        }
      )
      (
        builtins.filter (line: line != "" && !lib.hasPrefix "#" line) (
          lib.splitString "\n" (builtins.readFile file)
        )
      );
  dicts = readDataLock ./dicts.lock;
  models = readDataLock ./models.lock;
  releaseAsset =
    repo:
    { tag, sha256, ... }:
    name:
    fetchurl {
      url = "https://github.com/qingjian-team/${repo}/releases/download/${tag}/${name}";
      inherit sha256;
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
    ''
    + lib.optionalString stdenv.hostPlatform.isx86_64 ''
      patch -d "$cargoDepsCopy/candle-core-0.11.1" -p1 < ${./candle-vnni-llvm21.patch}
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
    resources="$out/share/qingjian/resources"
    mkdir -p "$out/bin" "$resources/assets"
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
    for kind in sample levels emoji; do
      cp -r "$src/assets/$kind" "$resources/assets/"
    done
    ${lib.concatMapStringsSep "\n" (
      dict:
      let
        name = lib.head (lib.splitString "-v" dict.tag);
        archive = releaseAsset "qingjian-dicts" dict "${name}.qjz";
        path = "data/generated/${dict.path}";
      in
      ''
        mkdir -p "$resources/${builtins.dirOf path}"
        gzip -dc ${archive} > "$resources/${path}"
        test -s "$resources/${path}"
      ''
    ) dicts}
    ${lib.concatMapStringsSep "\n" (
      model:
      let
        # Both pinned model releases publish their complete archive as a single part.
        archive = releaseAsset "qingjian-models" model "${model.tag}.tar.gz.part1";
      in
      ''
        mkdir -p "$resources/${builtins.dirOf model.path}"
        tar -xOzf ${archive} --wildcards --no-anchored "${builtins.baseNameOf model.path}" > "$resources/${model.path}"
        test -s "$resources/${model.path}"
      ''
    ) models}
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
