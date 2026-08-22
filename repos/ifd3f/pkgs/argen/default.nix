# copied and adapted from river's build config
{
  lib,
  stdenv,
  callPackage,
  fetchFromCodeberg,

  fcft,
  libevdev,
  libxkbcommon,
  pixman,
  pkg-config,
  scdoc,
  versionCheckHook,
  wayland,
  wayland-protocols,
  wayland-scanner,
  zig_0_16,

  withManpages ? true,
}:
let
  zig = zig_0_16;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "argen";
  version = "0.1.2";

  outputs = [ "out" ] ++ lib.optionals withManpages [ "man" ];

  src = fetchFromCodeberg {
    owner = "pkap";
    repo = "argen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sYzE1en6fpQJ6RZXGsdiBRmp9jCpbKQk1QsuTcML4WM=";
  };

  strictDeps = true;

  deps = callPackage ./build.zig.zon.nix { };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
    zig
  ]
  ++ lib.optional withManpages scdoc;

  buildInputs = [
    fcft
    libevdev
    libxkbcommon
    pixman
    wayland
    wayland-protocols
    wayland-scanner
  ];

  zigBuildFlags = [
    "--system"
    "${finalAttrs.deps}"
  ]
  ++ lib.optional withManpages "-Dman-pages";

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Task-oriented Wayland tiling window manager designed for keyboard + IPC workflows.";
    homepage = "https://codeberg.org/pkap/argen";
    changelog = "https://codeberg.org/pkap/argen/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      # source code
      gpl3Only

      # wayland protocols
      mit
    ];
    mainProgram = "argen";
    platforms = lib.platforms.linux;
  };
})
