{ stdenv, lib, mkDerivation, cmake, ninja, sources }:
let
  pname = "klogg";
  date = lib.substring 0 10 sources.klogg.date;
  version = "unstable-" + date;
in
mkDerivation {
  inherit pname version;
  src = sources.klogg;

  nativeBuildInputs = [ cmake ninja ];

  enableParallelBuilding = true;

  postPatch = lib.optionalString stdenv.isLinux ''
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$out/lib:${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}" \
      3rdparty/sentry/dump_syms/linux/dump_syms
    patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
      --set-rpath "$out/lib:${lib.makeLibraryPath [ stdenv.cc.cc.lib ]}" \
      3rdparty/sentry/dump_syms/linux/minidump_dump
  '';

  meta = with lib; {
    inherit (sources.klogg) description homepage;
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
