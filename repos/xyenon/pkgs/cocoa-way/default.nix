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
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "J-x-Z";
    repo = "cocoa-way";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WJ8B79ED9+v3HN+XKQaknQiKLWWwq0YELfarXUmOatw=";
  };

  cargoHash = "sha256-FVdbKeIUqSSqDNiwzIB+ME+6nSg5LLOeOxRFY4ejGbE=";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    libxkbcommon
    pixman
  ];

  preCheck = ''
    # AppKit button frames include decoration outside their Auto Layout alignment rects.
    substituteInPlace tests/native_panel_layout.rs \
      --replace-fail 'convertRect: button.bounds()' \
        'convertRect: button.alignmentRectForFrame(button.bounds())'

    # Fixed /tmp fixtures collide between Darwin build users.
    # Keep /tmp/cw- short for the Unix socket path-length regression tests.
    substituteInPlace src/container_sessions.rs \
      --replace-fail '/tmp/' "$TMPDIR/" \
      --replace-fail "$TMPDIR/cw-" '/tmp/cw-'
  '';

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
