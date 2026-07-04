{
  lib,
  stdenvNoCC,
  makeWrapper,
  callPackage,
  coreutils,
}:

let
  ### Import sshUtilsOnly derivation
  sshUtilsOnly = callPackage ./deps/sshUtilsOnly.nix { };
in
stdenvNoCC.mkDerivation rec {
  pname = "sshrm";
  version = "0.0.0";

  src = ./sshrm;

  ### Option
  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;
  dontPatchElf = true;

  buildInputs = [
    sshUtilsOnly
    coreutils
    makeWrapper
  ];

  installPhase = ''
    ### Make sshrm available
    mkdir -p $out/bin
    cp ${src} $out/bin/${pname}
    chmod +x $out/bin/${pname}
  '';

  postFixup = ''
    ### Add runtime path to sshrm tool
    wrapProgram $out/bin/${pname} \
      --set PATH ${
        lib.makeBinPath [
          sshUtilsOnly
          coreutils
        ]
      } \
      --set TERM xterm-256color
  '';

  meta = {
    description = "A tool to remove quickly all keys belonging to the specified host from a known_hosts file.";
    homepage = "https://github.com/aaaaadrien/sshrm";
    license = lib.licenses.mit;
    mainProgram = "sshrm";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
