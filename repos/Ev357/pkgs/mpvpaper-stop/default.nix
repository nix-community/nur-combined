{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  cjson,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mpvpaper-stop";
  version = "0-unstable-2025-09-01";

  src = fetchFromGitHub {
    owner = "pvtoari";
    repo = "mpvpaper-stop";
    rev = "fce30be5319a5039026e1b908c48b1509466ff5a";
    hash = "sha256-IN0K5lw7pEU4G+Hk/eBvF9qdlF7OMNPJcXDT/nbz/zg=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cjson
  ];

  meta = {
    description = "Automatic stop feature for mpvpaper animated wallpapers implemented via a background process";
    homepage = "https://github.com/pvtoari/mpvpaper-stop";
    license = lib.licenses.mit;
    mainProgram = "mpvpaper-stop";
    platforms = lib.platforms.linux;
  };
})
