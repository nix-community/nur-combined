{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  libewf,
  smartmontools,
  ddrescue,
  util-linux,
  systemd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dfdisk";
  version = "0.1.4";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "dfdisk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zdn1+1H255Lp4CsO3yeUJScw3fQwVoZpb/KCRhaZfPE=";
  };

  cargoHash = "sha256-s/zgvEjYj+J4BZjDYQ3FYr9fyOvFE/Xzcg8E6jJKSG4=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libewf
    smartmontools
    ddrescue
    util-linux
    systemd
  ];

  postInstall = ''
    wrapProgram $out/bin/dfdisk \
      --prefix PATH : ${
        lib.makeBinPath [
          libewf
          smartmontools
          ddrescue
          util-linux
          systemd
        ]
      }
  '';

  meta = {
    description = "Modern forensic disk imaging, damaged media rescue and conversion CLI/TUI tool";
    homepage = "https://github.com/tylerstyle/dfdisk";
    changelog = "https://github.com/tylerstyle/dfdisk/releases/tag/${finalAttrs.src.tag}";
    license = with lib.licenses; [ mit asl20 ];
    maintainers = with lib.maintainers; [ ] ++ lib.optionals (lib.maintainers ? tylerstyle) [ lib.maintainers.tylerstyle ];
    mainProgram = "dfdisk";
    platforms = lib.platforms.linux;
  };
})
