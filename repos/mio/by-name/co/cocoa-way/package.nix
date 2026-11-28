{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  libxkbcommon,
  xkeyboard-config,
}:

rustPlatform.buildRustPackage {
  pname = "cocoa-way";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "J-x-Z";
    repo = "cocoa-way";
    rev = "2ec48fad281c4e8185b0c268b3e751cce09e21f0";
    hash = "sha256-Xa1cxtFWHv9WetD6QjOMKedNYgLxqgEnbmzUUDzYqZ8=";
  };

  cargoHash = "sha256-zhRbswxhchLEe5bfacobnjS1QMW9PuZkjYsi1/OxI5U=";

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];
  buildInputs = [ libxkbcommon ];

  # The native AppKit integration tests need an interactive macOS session.
  doCheck = false;

  postInstall = ''
    wrapProgram "$out/bin/cocoa-way" \
      --set XKB_CONFIG_ROOT "${xkeyboard-config}/share/X11/xkb"
  '';

  meta = {
    description = "Native macOS Wayland compositor and Linux application control plane";
    homepage = "https://github.com/J-x-Z/cocoa-way";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
    mainProgram = "cocoa-way";
  };
}
