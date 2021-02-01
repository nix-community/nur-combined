{ pkgs ? (import <nixpkgs> {})
}:
pkgs.stdenv.mkDerivation rec {
  name = "strongdm";
  version = "30.86.0";
  src = pkgs.stdenv.mkDerivation {
    # src = ./sdmcli_1.5.13_linux_amd64.zip;
    src = pkgs.fetchurl {
      url ="https://sdm-releases-production.s3.amazonaws.com/builds/sdm-cli/${version}/linux/4E2E5E5B3AC091B11259854EF489A7654C9A248C/sdmcli_30.86.0_linux_amd64.zip";
      sha256 = "1ijb2r1bmz5kh9pvc70sxmzd4fnpbl2myyh0a47qrvl35v7z5271";
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

