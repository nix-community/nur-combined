{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  juceCmakeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "reev-r";
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "tiagolr";
    repo = "reevr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uOaImmc8MXhH6P3IN53LGntsWAbsVnqkz8TUk67aYcU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ juceCmakeHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Convolution reverb with pre and post modulation";
    homepage = "https://github.com/tiagolr/reevr";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "REEV-R";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
