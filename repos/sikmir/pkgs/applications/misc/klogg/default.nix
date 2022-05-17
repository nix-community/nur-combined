{ stdenv
, lib
, mkDerivation
, fetchFromGitHub
, cmake
, ninja
, python3Packages
, boost
, ragel
, useSentry ? stdenv.isLinux
, useHyperscan ? false
}:

mkDerivation rec {
  pname = "klogg";
  version = "2021-09-27";

  src = fetchFromGitHub {
    owner = "variar";
    repo = pname;
    rev = "9fade8bcf354fc6d329facbce07a6c29437597a1";
    hash = "sha256-bim/cDEOfMolHkrBLBEu94YI+1o1opdeA66xeovAwp0=";
  };

  nativeBuildInputs = [ cmake ninja python3Packages.python ];

  buildInputs = [ boost ragel ];

  postPatch = lib.optionalString useSentry ''
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$out/lib:${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}" \
      3rdparty/sentry/dump_syms/linux/dump_syms
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$out/lib:${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}" \
      3rdparty/sentry/dump_syms/linux/minidump_dump
  '';

  preConfigure = "export KLOGG_VERSION=${version}";

  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=missing-braces";

  cmakeFlags = lib.mapAttrsToList (k: v: "-D${k}=${if v then "ON" else "OFF"}") {
    KLOGG_USE_SENTRY = useSentry;
    KLOGG_USE_HYPERSCAN = useHyperscan;
  };

  meta = with lib; {
    description = "A fast, advanced log explorer based on glogg project";
    homepage = "https://klogg.filimonov.dev/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
    broken = true;
  };
}
