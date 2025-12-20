{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcron";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "PerMalmberg";
    repo = "libcron";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j3wHdOx25RgAarXe598rJhg7aHSrk71F8u6hYazXHYo=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "C++ scheduling library using cron formatting";
    homepage = "https://github.com/PerMalmberg/libcron";
    changelog = "https://github.com/PerMalmberg/libcron/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
})
