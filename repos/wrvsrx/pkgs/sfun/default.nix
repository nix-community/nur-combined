{
  stdenv,
  cmake,
  source,
  utfcpp,
  lib,
  seal_lake,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  patches = [ ./seal.patch ];
  prePatch = ''
    mkdir -p include/sfun/detail
    cp --no-preserve=mode,ownership -r ${utfcpp}/include/utf8cpp include/sfun/detail/external
    find include/sfun/detail/external -name '*.h' | xargs -d '\n' sed -i 's/namespace utf8/namespace sfun::utf8/g'
  '';
  buildInputs = [ seal_lake ];
  nativeBuildInputs = [ cmake ];
}
