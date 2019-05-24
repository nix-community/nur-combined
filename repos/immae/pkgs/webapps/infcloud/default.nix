{ infcloud_config ? ./infcloud_config.js, stdenv, fetchzip, ed }:
stdenv.mkDerivation rec {
  version = "0.13.1";
  name = "InfCloud-${version}";
  src = fetchzip {
    url = "https://www.inf-it.com/InfCloud_${version}.zip";
    sha256 = "1fjhs0cj0b9fhf5ysfz281mknmmg1z551bas143sxfcqlpa5aiiq";
  };
  buildPhase = ''
    patchShebangs .
    ./cache_update.sh
    rm config.js
    '';
  installPhase = ''
    cp -a . $out
    ln -s ${infcloud_config} $out/config.js
    '';
  buildInputs = [ ed ];
}
