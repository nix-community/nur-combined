{ lib
, stdenv
, makeWrapper
, nix
, nssmdns
}:
stdenv.mkDerivation {
  inherit (nix) pname version;

  src = lib.sourceFilesBySuffices ./. [ ".c" ];

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace nix_nss_mdns.c --subst-var-by nssmdns "${nssmdns}"
  '';

  buildPhase = ''
    gcc -shared -fpic -o libnix_nss_mdns.so nix_nss_mdns.c -ldl
  '';

  installPhase = ''
    mkdir -p $out
    ln -s ${nix}/* $out

    unlink $out/lib
    mkdir $out/lib
    ln -s ${nix}/lib/* $out/lib
    install -D -t $out/lib libnix_nss_mdns.so

    unlink $out/bin
    mkdir $out/bin
    ln -s ${nix}/bin/* $out/bin
    for program in $out/bin/*; do
      wrapProgram $program --prefix LD_PRELOAD : "$out/lib/libnix_nss_mdns.so"
    done
  '';
}
