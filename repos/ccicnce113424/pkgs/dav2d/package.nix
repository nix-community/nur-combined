{
  lib,
  stdenv,
  fetchFromGitLab,
  meson,
  ninja,
  nasm,
  xxhash,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dav2d";
  version = "0.0.1";

  src = fetchFromGitLab {
    domain = "code.videolan.org";
    owner = "videolan";
    repo = "dav2d";
    tag = finalAttrs.version;
    hash = "sha256-PiIWQBXH3pglWGKu05K4KL0FMkvvvOBQP6QLOXGSQP0=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
  ];

  nativeBuildInputs = [
    meson
    ninja
  ]
  ++ lib.optional stdenv.hostPlatform.isx86 nasm;

  buildInputs = [
    xxhash
  ];

  strictDeps = true;
  __structuredAttrs = true;

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://code.videolan.org/videolan/dav2d";
    description = "dav2d is a av2 decoder similar to dav1d but for av2";
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    license = lib.licenses.bsd2;
    platforms = lib.platforms.unix;
    mainProgram = "dav2d";
  };
})
