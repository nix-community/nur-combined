{ stdenv
, lib
, bash
, pkgs
, makeWrapper
}:
stdenv.mkDerivation rec {
  pname = "bmc";
  version = "314dc793d7ee9acaf658f2c8623f7ad091193aac";
  src = ./.;
  buildInputs = [bash pkgs.gum pkgs.smug pkgs.tmux];
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir -p $out/bin
    cp smg $out/bin/smg
    wrapProgram $out/bin/smg --prefix PATH : ${lib.makeBinPath [ bash ]}
  '';
}

