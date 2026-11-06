{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "shurectl";
  version = "2.17.0";

  src = fetchFromGitHub {
    owner = "Humblemonk";
    repo = "shurectl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YlUljIJgpF1OLmMlleZm8r7d67GXkLPELxGm+xpfL1M=";
  };

  cargoHash = "sha256-VwdM9YyE6TehckZdVk2RrPJhKId+54Uaa6fbtIs+aNg=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    udev
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm644 62-shure.rules -t $out/lib/udev/rules.d
  '';

  meta = {
    description = "Terminal UI configurator for Shure USB microphones and audio interfaces";
    homepage = "https://github.com/Humblemonk/shurectl";
    changelog = "https://github.com/Humblemonk/shurectl/blob/v${finalAttrs.version}/doc/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ mrene ];
    mainProgram = "shurectl";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
