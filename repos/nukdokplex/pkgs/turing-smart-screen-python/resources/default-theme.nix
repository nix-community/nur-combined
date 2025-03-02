{ lib
, stdenvNoCC
, fetchFromGitHub
, pkgParams
, ...
}: with pkgParams; stdenvNoCC.mkDerivation {
  inherit pname;
  version = pkgParams.version.rev;

  src = fetchFromGitHub {
    owner = "mathoudebine";
    repo = "turing-smart-screen-python";
    inherit (version) rev hash;
  };

  installPhase = ''
    cp -a res/themes/${dir} "$out"
  '';

  meta = {
    homepage = "https://github.com/mathoudebine/turing-smart-screen-python/tree/${version.rev}/res/themes/${dir}";
    description = "This is \"${dir}\" theme package for turing-smart-screen-python package." + (if dir != pname then " Notice that now it's renamed to \"${pname}}\" so you need to use this name in your configuration." else "");
    license = with lib.licenses; [ gpl3Only ];
  };
}
