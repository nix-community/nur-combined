{
  stdenv,
  lib,
  autoPatchelfHook,
  fd,
  alsa-lib,
  freetype,
  libGL,
  pname,
  displayName,
  version,
  src,
  meta,
  extraBuildInputs ? [ ],
  withApp,
  withAU,
  withVST,
  withVST3,
}:
stdenv.mkDerivation {
  inherit
    pname
    version
    src
    meta
    ;
  nativeBuildInputs = [
    autoPatchelfHook
    fd
  ];
  buildInputs = [
    alsa-lib
    freetype
    stdenv.cc.cc.lib
    libGL
  ] ++ extraBuildInputs;
  installPhase = lib.strings.concatLines [
    "runHook preInstall"
    (if withApp then "install -D -t $out/bin ${displayName}" else "")
    (if withVST then "install -D -t $out/lib/vst ${displayName}VST.so" else "")
    "ls -alh"
    (if withVST3 then "fd -tf . ${displayName}.vst3 -x install -D -t $out/lib/vst3/{} {}" else "")
    "runHook postInstall"
  ];
}
