{
  stdenv,
  cmake,
  source,
  sfun,
  lib,
  seal_lake,
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;
  patches = [ ./seal.patch ];
  prePatch = ''
    mkdir -p include/cmdlime/detail/external
    cp --no-preserve=mode,ownership -r ${sfun}/include/sfun include/cmdlime/detail/external/sfun
    find include/cmdlime/detail/external -name '*.h' | xargs -d '\n' sed -i 's/namespace sfun/namespace cmdlime::sfun/g'
  '';
  buildInputs = [ seal_lake ];
  nativeBuildInputs = [ cmake ];
}
