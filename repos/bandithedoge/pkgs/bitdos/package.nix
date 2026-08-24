{
  fetchFromGitHub,
  lib,
  nix-update-script,
  stdenv,

  projucer,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "bitdos";
  version = "1.2";
  src = fetchFromGitHub {
    owner = "astriiddev";
    repo = "BitDOS-VST";
    rev = finalAttrs.version;
    hash = "sha256-9cyNb00LSe1uYfoEFoDR9mTgs8ULTIoHBo7QZ5YZTOI=";
  };

  nativeBuildInputs = [
    projucer
  ];

  jucerFile = "BitDos.jucer";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A bit-inverting industrial distortion plugin with VST3/LV2";
    homepage = "https://github.com/astriiddev/BitDOS-VST";
    license = lib.licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
