{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  cmake,
  perl,
  makeWrapper,
  nix-update-script,
  writeShellApplication,
  openssl,
  sqlcipher,
  dejavu_fonts,
  icnsify,
  rcodesign,
}:

rustPlatform.buildRustPackage rec {
  pname = "zapfast";
  version = "0.21.3";

  src = fetchFromGitHub {
    owner = "crmne";
    repo = "zapfast";
    tag = "v${version}";
    hash = "sha256-eDXn2wSXK7zYx+6ZUBP2r2ovjsGzHxR3G7REq+ermQY=";
  };

  # The tree carries several git dependencies (wacore, a patched egui/winit),
  # which cargoLock cannot vendor in pure evaluation; cargoHash covers them.
  cargoHash = "sha256-dL+TQNzkk3iQt4GvCotqgA3QBO4gXDZGLpxQ6mond0Q=";

  buildInputs = [
    openssl
    sqlcipher
  ];

  nativeBuildInputs = [
    pkg-config
    cmake
    perl
    makeWrapper
    # Sandboxed stand-ins for iconutil and codesign in packaging/macos/bundle.sh.
    icnsify
    rcodesign
  ];

  ZAPFAST_TEST_RTL_FONT = "${dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf";

  # The integration targets drive AppKit menus and the macOS packaging
  # scripts, which need a GUI session; run the library suite instead. Five of
  # its tests bind loopback sockets, which the build sandbox forbids (EPERM).
  cargoTestFlags = [ "--lib" ];

  checkFlags = [
    "--skip"
    "proxy::tests::http_tunnel_keeps_data_after_the_reply"
    "--skip"
    "proxy::tests::http_tunnel_reports_rejected_credentials"
    "--skip"
    "proxy::tests::socks5_tunnel_sends_the_host_name_and_credentials"
    "--skip"
    "single_instance::tests::older_copies_may_only_ask_for_the_window"
    "--skip"
    "transport::tests::dials_the_next_address_when_the_first_refuses"
  ];

  passthru.updateScript = writeShellApplication {
    name = "update-zapfast";
    text = ''
      export UPDATE_NIX_ATTR_PATH="zapfast"
      exec ${
        lib.escapeShellArgs (nix-update-script {
          extraArgs = [
            "--version-regex"
            "v(.*)"
          ];
        })
      } "$@"
    '';
  };

  postFixup = ''
    rcodesign sign \
      --entitlements-xml-file packaging/macos/entitlements.plist \
      $out/Applications/ZapFast.app
  '';

  # Mirrors packaging/macos/bundle.sh: ZapFast.app around the built binary,
  # with the version stripped of any prerelease suffix.
  postInstall = ''
    app=$out/Applications/ZapFast.app
    mkdir -p $app/Contents/MacOS $app/Contents/Resources
    mv $out/bin/zapfast $app/Contents/MacOS/zapfast
    chmod 755 $app/Contents/MacOS/zapfast
    # The command runs the bundled executable, so macOS applies the bundle's
    # Info.plist and entitlements, and start at login records the bundled path.
    makeWrapper $app/Contents/MacOS/zapfast $out/bin/zapfast
    sed "s/__VERSION__/''${version%%-*}/g" packaging/macos/Info.plist \
      > $app/Contents/Info.plist
    icnsify packaging/macos/icon-1024.png \
      --output $app/Contents/Resources/zapfast.icns
  '';

  meta = {
    description = "Fast native WhatsApp client";
    homepage = "https://zapfast.rocks";
    license = with lib.licenses; [
      mit
      gpl2Only
    ];
    mainProgram = "zapfast";
    platforms = [ "aarch64-darwin" ];
  };
}
