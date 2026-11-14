{
  lib,
  rustPlatform,
  rustc,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  alsa-lib,
  fontconfig,
  freetype,
  libxkbcommon,
  libxcb,
  sqlite,
  vulkan-loader,
  wayland,
  wl-clipboard,
  xclip,
  nix-update-script,
}:

let
  # GPUI が dlopen で読むのでリンカには記録されない。
  runtimeLibraries = [
    vulkan-loader
    wayland
  ];
in
rustPlatform.buildRustPackage rec {
  pname = "sheprd";
  version = "20261109.1";

  src = fetchFromGitHub {
    owner = "sheprd-labs";
    repo = "sheprd";
    rev = "v${version}";
    hash = "sha256-sBlwXT7AwdxjNFjOyIJP9aKMD0eERyCadOh3yoCTmBM=";
  };

  cargoHash = "sha256-6hQElg0xJUtxKO4oq3USHBa84g4HK4GxFfb5pzdYpl0=";

  # アプリは実行ファイルの隣の sheprd-acp / sheprd-remote-control /
  # sheprd-automate / sheprd-nearby を起動する。上流のリリースが同梱する
  # herdr-core は herdr.dev 配布のビルド済みバイナリなので入れていない。
  cargoBuildFlags = [
    "-p"
    "sheprd-gpui"
    "-p"
    "sheprd-acp"
    "-p"
    "sheprd-remote-control"
    "-p"
    "sheprd-automate"
    "-p"
    "sheprd-nearby"
  ];

  # 残りの workspace テストはデスクトップか稼働中の daemon を要する。
  cargoTestFlags = [
    "-p"
    "sheprd-gpui"
    "--test"
    "cli"
  ];

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    fontconfig
    freetype
    libxkbcommon
    libxcb
    sqlite
  ] ++ runtimeLibraries;

  postInstall = ''
    install -Dm644 scripts/release/org.sheprd.Sheprd.desktop \
      $out/share/applications/org.sheprd.Sheprd.desktop
    install -Dm644 assets/icons/sheprd-linux.svg \
      $out/share/icons/hicolor/scalable/apps/sheprd.svg
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath runtimeLibraries} $out/bin/sheprd
    wrapProgram $out/bin/sheprd \
      --prefix PATH : ${lib.makeBinPath [ wl-clipboard xclip ]}
    # 既存の設定やユーザーサービスが旧コマンド名で起動するため、上流の flake と同じ互換名を置く。
    ln -s sheprd $out/bin/herdr-gpui
    for helper in acp automate nearby remote-control; do
      ln -s "sheprd-$helper" "$out/bin/herdr-$helper"
    done
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native workspace for coding agents and terminals";
    homepage = "https://sheprd.org";
    license = lib.licenses.asl20;
    mainProgram = "sheprd";
    # workspace の rust-version が 1.99 を要求する。
    broken = lib.versionOlder rustc.version "1.99";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
