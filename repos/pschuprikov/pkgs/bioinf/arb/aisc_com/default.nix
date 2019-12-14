{ buildArb, fetchsvn, arbcommon }:
buildArb rec {
  version = "6.0.6";
  name = "arbaisc_com-${version}";

  src = fetchsvn {
    url = "http://vc.arb-home.de/readonly/branches/stable/AISC_COM";
    rev = "18244";
    sha256 = "sha256:0988lpid7z2fzk6mr1mh2v6mkmkylrabafi1j7d8zjl704wbz1gp";
  };

  patchPhase = ''
    substituteInPlace AISC/Makefile \
      --replace '$(ARBHOME)/SOURCE_TOOLS' "${arbcommon}/bin"
  '';

  buildPhase = "true";

  installPhase = ''
    mkdir -p $out/share/AISC
    cp -R AISC/*.pa AISC/Makefile AISC/export2sub $out/share/AISC/
    mkdir -p $out/share/C
    cp -R C/*.h C/*.c $out/share/C/
    mkdir -p $out/include
    cp -R C/*.h $out/include
  '';
}
