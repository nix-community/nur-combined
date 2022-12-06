{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  name = "strongdm";
  version = "35.72.0";
  src = pkgs.stdenv.mkDerivation {
    # src = ./sdmcli_1.5.13_linux_amd64.zip;
    src = pkgs.fetchurl {
      url = "https://downloads.strongdm.com/builds/sdm-cli/35.72.0/linux/amd64/0F824D8978809F9D5E25A52B62D681C0E3A99480/sdmcli_35.72.0_linux_amd64.zip";
      sha256 = "sha256-kpKMlxPkQDo2DD1QEtnEPr8Cgz+tPIvJB6E6+8KSYNU=";
    };
    name = "strongdmpre";
    buildInputs = [ pkgs.unzip ];
    unpackPhase = ''
      unzip $src
    '';
    installPhase = ''
      install -D sdm $out/bin/sdm
    '';
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  };
  installPhase = ''
    bin/sdm install || true
    install -D bin/sdm $out/bin/sdm
    install -D state.db $out/state.db
  '';
}

