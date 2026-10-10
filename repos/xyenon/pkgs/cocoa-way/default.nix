{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  libxkbcommon,
  pixman,
  coreutils,
  findutils,
  waypipe-darwin,
  nix-update-script,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cocoa-way";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "J-x-Z";
    repo = "cocoa-way";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KyokIvF/0qg+2rWsUvD6lwbaMzeR721dRFmzzqS881Y=";
  };

  cargoHash = "sha256-jCtkQ+2C1+OquDiUOjpDM6lOnb+t0DJ3HPHye9HFefI=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libxkbcommon
    pixman
  ];

  postInstall = ''
    install -Dm755 run_waypipe.sh $out/bin/run_waypipe.sh
    patchShebangs $out/bin/run_waypipe.sh
    wrapProgram $out/bin/run_waypipe.sh \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          findutils
          waypipe-darwin
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native macOS Wayland compositor for running Linux apps";
    homepage = "https://github.com/J-x-Z/cocoa-way";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ xyenon ];
    mainProgram = "cocoa-way";
    platforms = lib.platforms.darwin;
  };
})
