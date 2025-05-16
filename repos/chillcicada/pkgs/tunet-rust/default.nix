{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  openssl,
  freetype,
  hicolor-icon-theme,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tunet-rust";
  version = "0.9.5";

  src = fetchFromGitHub {
    owner = "Berrysoft";
    repo = "tunet-rust";
    rev = "v${finalAttrs.version}";
    hash = "sha256-q4jJXSq7KCTSOD7unQT0IraXzf2zIx3/ZjO8Dq5dEK0=";
  };

  sourceRoot = finalAttrs.src.name;

  cargoHash = "sha256-yL4+o1M64wHFrp6T3KWfdhb06V2WJqovA4gXB49vSEE=";

  cargoBuildFlags = [
    "--workspace"
    "--exclude native"
  ];

  cargoCheckFlags = [
    "--workspace"
    "--exclude native"
  ];

  cargoTestFlags = [
    "--workspace"
    "--exclude native"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
    freetype
    hicolor-icon-theme
  ];

  postInsatll = ''
    install -Dm0644 tunet/tunet.desktop $out/share/applications/tunet.desktop
    install -Dm0644 logo.png $out/share/icons/hicolor/256x256/apps/tunet.png
    install -Dm0644 tunet-service/tunet@.service $out/etc/systemd/user/tunet@.service
  '';

  meta = {
    description = "清华大学校园网 Rust 库与客户端";
    homepage = "https://github.com/Berrysoft/tunet-rust";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
