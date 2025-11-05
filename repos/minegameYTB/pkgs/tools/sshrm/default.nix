{ lib, stdenvNoCC, makeWrapper, fetchFromGitHub, callPackage, coreutils }:

let
  ### Import sshUtilsOnly derivation
  sshUtilsOnly = callPackage ./deps/sshUtilsOnly.nix {};
in

stdenvNoCC.mkDerivation rec {
  pname = "sshrm";
  version = "git-${builtins.substring 0 7 src.rev}";

  src = fetchFromGitHub {
    owner = "aaaaadrien";
    repo = pname;
    rev = "0803f982130ebcceb43abe4fe84da3541856ed46";
    sha256 = "sha256-Sm9RAK6UdvL0yHfE12gIjoLfy3pZBqgRtfm20X1FWm0=";
  };

  buildInputs = [ sshUtilsOnly coreutils makeWrapper ];

  installPhase = ''
    ### Make sshrm available
    mkdir -p $out/bin $out/share/doc/${pname}
    cp ${pname} $out/bin/${pname}

    ### Add license file accessible on the doc directory
    cp LICENSE $out/share/doc/${pname}/LICENSE
    cp README.md $out/share/doc/${pname}/README.md
  '';

  postFixup = ''
    ### Add runtime path to sshrm tool
    wrapProgram $out/bin/${pname} \
      --set PATH ${lib.makeBinPath [ sshUtilsOnly coreutils ]} \
      --set TERM xterm-256color
  '';

  meta = {
    description = "A tool to remove quickly all keys belonging to the specified host from a known_hosts file.";
    homepage = "https://github.com/aaaaadrien/sshrm";
    license = lib.licenses.mit;
    mainProgram = "sshrm";
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
