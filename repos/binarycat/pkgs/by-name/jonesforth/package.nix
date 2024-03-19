{ lib
, stdenv
, writeShellApplication
, fetchFromGitHub
}:
let
  raw = stdenv.mkDerivation {
    name = "jonesforth-unwrapped";

    src = fetchFromGitHub {
      owner = "nornagon";
      repo = "jonesforth";
      rev = "d97a25bb0b06fb58da1975eac291f45618fd2ada";
      hash = "sha256-obgo8TavD1rCPr5K0DLg3V1bayMDnPqElEKlDdSZ0zo=";
    };

    doCheck = true;

    installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp jonesforth $out/bin
    cp jonesforth.f $out
    runHook postInstall
'';
  };
in writeShellApplication {
  name = "jonesforth";
  text = ''
   cat ${raw}/jonesforth.f - | ${raw}/bin/jonesforth
  '';

  derivationArgs.passthru.unwrapped = raw;

  meta = {
    homepage = "https://github.com/nornagon/jonesforth";
    description = "Implementaion of FORTH in x86 assembly";
    platform = lib.platforms.x86;
  };
}
