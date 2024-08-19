{
  source,
  stdenv,
  lib,
  lua5_4,
}:

stdenv.mkDerivation rec {
  inherit (source) pname src date;
  version = "ustable-${date}";

  buildInputs = [ lua5_4 ];

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out
  '';

  meta = with lib; {
    description = "Extending RIME with Lua scripts";
    homepage = "https://github.com/hchunhui/librime-lua";
    license = licenses.bsd3;
  };
}
