{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  zig_0_17,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "zigscient";
  version = "0.17.0";
  src = fetchFromGitHub {
    owner = "llogick";
    repo = "zigscient";
    rev = finalAttrs.version;
    hash = "sha256-tWgUZm9kW8B/tCIx5g2N4mVRiqKxLy+YuxBv0iSvLds=";
  };

  passthru.updateScript = nix-update-script { };

  nativeBuildInputs = [
    zig_0_17
  ];

  zigDeps = zig_0_17.fetchDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-uSn6uEkaHhdc/exKkZr2oFwNvgclehvSTBKv6n+ODzI=";
  };

  dontSetZigDefaultFlags = true;
  zigBuildFlags = [
    "-Doptimize=ReleaseFast"
    "-Dcpu=baseline"
  ];

  postConfigure = ''
    ln -s ${finalAttrs.zigDeps} "$ZIG_GLOBAL_CACHE_DIR/p"
  '';

  env.ZIG_LIB_DIR = "./lib";

  meta = {
    description = "Zig Language Server";
    homepage = "https://github.com/llogick/zigscient";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    mainProgram = "zigscient";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
