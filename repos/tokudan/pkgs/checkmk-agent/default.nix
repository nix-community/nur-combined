{ stdenv, lib, fetchFromGitHub, makeWrapper }:

stdenv.mkDerivation rec {
  name = "checkmk-agent";
  src = fetchFromGitHub {
    owner = "Checkmk";
    repo  = "checkmk";
    rev   = "v2.3.0p6";
    hash  = "sha256-1wLcEBa4v4N35uDdMYZdDif3e1lFS7rmkdNe4nSLyUg=";
  };
  phases = [ "installPhase" "fixupPhase" "wrapPhase" ];
  buildInputs = [ ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    ls -laR
    mkdir -p $out/bin
    for s in \
      agents/check_mk_agent.linux:bin/check_mk_agent \
      agents/mk-job:bin/mk-job
    do 
    	install -m 0755 "$src/''${s%:*}" "$out/''${s#*:}"
    done
    '';
  wrapPhase = ''
    wrapProgram $out/bin/check_mk_agent --suffix PATH : /run/current-system/sw/bin
    '';

  meta = with lib; {
    description = "checkmk-agent";
  };
}

