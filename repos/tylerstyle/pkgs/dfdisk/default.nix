{
  lib,
  rustPlatform,
  fetchFromGitHub,
  runCommand,
  makeWrapper,
  pkg-config,
  libewf,
  smartmontools,
  ddrescue,
  util-linux,
  systemd,
}:

let
  version = "0.1.10";

  dfdiskSrc = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "dfdisk";
    tag = "v${version}";
    hash = "sha256-jurQjYXuzR4ILpfPQTu6uwK/LOzcit4pRRJM1kYH8GM=";
  };

  # dfdisk depends on dfcore via `path = "../dfcore"`; pin the revision
  # recorded in dfdisk's flake.lock for this tag
  dfcoreSrc = fetchFromGitHub {
    owner = "tylerstyle";
    repo = "dfcore";
    rev = "ffce902b0119830f70211ec3efc3512c8bf7f365";
    hash = "sha256-mzwV620LnaWlUM9PawWg3pg04U6FrvAfk9VGyjFC0Ek=";
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dfdisk";
  inherit version;

  __structuredAttrs = true;

  # Lay out the sources as siblings so the relative path dependency resolves
  src = runCommand "dfdisk-src-${version}" { } ''
    mkdir -p $out
    cp -r ${dfdiskSrc} $out/dfdisk
    cp -r ${dfcoreSrc} $out/dfcore
    chmod -R u+w $out
  '';
  sourceRoot = "${finalAttrs.src.name}/dfdisk";

  cargoHash = "sha256-sVHI2WehQXMK/0/AaK4902eBcuf199SbarY5cHQl4E8=";

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
    changelog = "https://github.com/tylerstyle/dfdisk/releases/tag/v${version}";
    license = with lib.licenses; [ mit asl20 ];
    maintainers = with lib.maintainers; [ ] ++ lib.optionals (lib.maintainers ? tylerstyle) [ lib.maintainers.tylerstyle ];
    mainProgram = "dfdisk";
    platforms = lib.platforms.linux;
  };
})
