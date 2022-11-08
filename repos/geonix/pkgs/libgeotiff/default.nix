{ lib, stdenv, fetchFromGitHub, libtiff, libjpeg, proj, zlib, autoreconfHook, pkg-config }:

stdenv.mkDerivation rec {
  version = "1.7.1";
  pname = "libgeotiff";

  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "libgeotiff";
    rev = version;
    sha256 = "sha256-bE6UAUKiorriTgYrqhxbMAN2NEtmV/8IIfF02RUghSI=";
  };

  outputs = [ "out" "dev" ];

  sourceRoot = "source/libgeotiff";

  configureFlags = [
    "--with-jpeg=${libjpeg.dev}"
    "--with-zlib=${zlib.dev}"
  ];

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [ libtiff proj ];

  hardeningDisable = [ "format" ];

  meta = {
    description = "Library implementing attempt to create a tiff based interchange format for georeferenced raster imagery";
    homepage = "https://github.com/OSGeo/libgeotiff";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.marcweber];
    platforms = with lib.platforms; linux ++ darwin;
  };
}
