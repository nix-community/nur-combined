{minivmac, suffix ? null, pname ? "${minivmac.pname}-${suffix}", stdenvNoCC, lib}: stdenvNoCC.mkDerivation {
    inherit minivmac pname;
    inherit (minivmac) version;
    unpackPhase = "true";
    buildPhase = "true";
    installPhase = ''
    mkdir -p $out/bin
    ln -s $minivmac/bin/minivmac $out/bin/$name
    '' + lib.optionalString stdenvNoCC.isDarwin ''
    mkdir -p $out/Applications
    ln -s $minivmac/Applications/minivmac.app $out/Applications/$name.app
    '';
}
