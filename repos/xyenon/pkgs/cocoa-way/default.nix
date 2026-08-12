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
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "J-x-Z";
    repo = "cocoa-way";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fuJ60iQYRFd46/XJHcpBm4CQSRZbuYkg38/4umZqR10=";
  };

  cargoHash = "sha256-JgnhrTrXnZryl/ai0s7tYKY0vI02k8F0VzPE89ZJPIQ=";

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
