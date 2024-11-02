{ pkgs }:
pkgs.stdenv.mkDerivation {
  name = "strongdm";
  version = "45.35.0";
  src = pkgs.fetchurl {
    url = "https://downloads.strongdm.com/builds/sdm-cli/45.35.0/linux-amd64/DCA42F9D6819457A20EB68F2D87245B2163BC7A6/sdmcli_45.35.0_linux_amd64.zip";
    sha256 = "sha256-LBCeydYzQ3nh2MPoxKHj+OV036AxKJdjasuYVqLJkrA=";
  };
  buildInputs = [ pkgs.unzip ];
  unpackPhase = ''
    unzip $src
  '';
  installPhase = ''
    mkdir -p $out/bin
    mv ./sdm $out/bin
  '';
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
}
