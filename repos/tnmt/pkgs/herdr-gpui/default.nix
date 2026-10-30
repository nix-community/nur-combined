{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  alsa-lib,
  fontconfig,
  freetype,
  libxkbcommon,
  libxcb,
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
  pname = "herdr-gpui";
  version = "20261028.1";

  src = fetchFromGitHub {
    owner = "penso";
    repo = "herdr-gpui";
    rev = "v${version}";
    hash = "sha256-yUfr7bGYlRohnnZx+ZR+jTX3/ud71cKYlTE2kzIACoI=";
  };

  cargoHash = "sha256-C5Bu85K1lmX5MVC7zDIp9CbAygDlTJ3nLPZrFskAHdo=";

  # アプリは実行ファイルの隣の herdr-acp / herdr-remote-control / herdr-automate を起動する。
  cargoBuildFlags = [
    "-p"
    "herdr-gpui"
    "-p"
    "herdr-acp"
    "-p"
    "herdr-remote-control"
    "-p"
    "herdr-automate"
  ];

  # 残りの workspace テストはデスクトップか稼働中の daemon を要する。
  cargoTestFlags = [
    "-p"
    "herdr-gpui"
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
  ] ++ runtimeLibraries;

  postInstall = ''
    install -Dm644 scripts/release/so.pen.herdr-gpui.desktop \
      $out/share/applications/so.pen.herdr-gpui.desktop
    install -Dm644 assets/icons/herdr-linux.svg \
      $out/share/icons/hicolor/scalable/apps/herdr-gpui.svg
  '';

  postFixup = ''
    patchelf --add-rpath ${lib.makeLibraryPath runtimeLibraries} $out/bin/herdr-gpui
    wrapProgram $out/bin/herdr-gpui \
      --prefix PATH : ${lib.makeBinPath [ wl-clipboard xclip ]}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native GPUI client for an existing local Herdr daemon";
    homepage = "https://herdrui.dev";
    license = lib.licenses.asl20;
    mainProgram = "herdr-gpui";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
