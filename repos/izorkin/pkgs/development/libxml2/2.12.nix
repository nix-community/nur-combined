{ stdenv
, lib
, fetchurl
, zlib
, pkg-config
, autoreconfHook
, findXMLCatalogs
, libiconv
, enableShared ? !stdenv.hostPlatform.isMinGW && !stdenv.hostPlatform.isStatic
, enableStatic ? !enableShared
, testers
}:

stdenv.mkDerivation (finalAttrs: rec {
  pname = "libxml2";
  version = "2.12.9";

  outputs = [ "bin" "dev" "out" "doc" ]
    ++ lib.optional (enableStatic && enableShared) "static";
  outputMan = "bin";

  src = fetchurl {
    url = "mirror://gnome/sources/libxml2/${lib.versions.majorMinor version}/libxml2-${version}.tar.xz";
    hash = "sha256-WZEttTarVqOZZInqApl2jHvP/lcWnwI15/liqR9INZA=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  propagatedBuildInputs = [
    zlib
    findXMLCatalogs
  ] ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  configureFlags = [
    "--exec-prefix=${placeholder "dev"}"
    "--without-python"
    "--without-icu"
    (lib.enableFeature enableStatic "static")
    (lib.enableFeature enableShared "shared")
  ];

  enableParallelBuilding = true;

  doCheck =
    (stdenv.hostPlatform == stdenv.buildPlatform) &&
    stdenv.hostPlatform.libc != "musl";
  preCheck = lib.optional stdenv.hostPlatform.isDarwin ''
    export DYLD_LIBRARY_PATH="$PWD/.libs:$DYLD_LIBRARY_PATH"
  '';

  preConfigure = lib.optionalString (lib.versionAtLeast stdenv.hostPlatform.darwinMinVersion "11") ''
    MACOSX_DEPLOYMENT_TARGET=10.16
  '';

  postFixup = ''
    moveToOutput bin/xml2-config "$dev"
    moveToOutput lib/xml2Conf.sh "$dev"
  '' + lib.optionalString (enableStatic && enableShared) ''
    moveToOutput lib/libxml2.a "$static"
  '';

  passthru = {
    inherit version;

    tests = {
      pkg-config = testers.hasPkgConfigModules {
        package = finalAttrs.finalPackage;
      };
    };
  };

  meta = {
    homepage = "https://gitlab.gnome.org/GNOME/libxml2";
    description = "XML parsing library for C";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ eelco jtojnar ];
    pkgConfigModules = [ "libxml-2.0" ];
  };
})
