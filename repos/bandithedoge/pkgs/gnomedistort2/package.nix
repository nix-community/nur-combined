{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gnomedistort2";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "crowbait";
    repo = "GnomeDistort-2";
    rev = finalAttrs.version;
    hash = "sha256-9G3cxPzw8b/Y4d/nFV0kSeNkjE4XwzvnuafoCkCIOzo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    juceCmakeHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Weird & brutal distortion VST plugin";
    homepage = "https://github.com/crowbait/GnomeDistort-2";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
