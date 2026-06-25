{
  buildPythonPackage,
  fetchFromGitHub,
  lib,
  rustPlatform,
}:
buildPythonPackage (finalAttrs: {
  pname = "libloot-python";
  version = "0.29.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "loot";
    repo = "libloot";
    tag = finalAttrs.version;
    hash = "sha256-faqsT3Y8rxEyilZ5V1c3n/Q5ozyOqVa7IrNHRx3ZJi0=";
  };

  postPatch = ''
    cd python
  '';

  cargoRoot = "..";

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      src
      ;
    hash = "sha256-i1Y+4d2ri9+mMpFNKUqHi+K4R6ScXqxPucywZeP+YKE=";
  };

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  meta = {
    description = "Experimental Python wrapper around libloot";
    homepage = "https://github.com/loot/libloot/tree/master/python";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    platforms = lib.platforms.all;
  };
})
