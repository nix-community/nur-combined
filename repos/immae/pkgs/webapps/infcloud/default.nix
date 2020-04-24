{ infcloud_config ? ./infcloud_config.js, stdenv, fetchzip, ed }:
stdenv.mkDerivation rec {
  version = "0.13.2rc1";
  name = "InfCloud-${version}";
  src = fetchzip {
    url = "https://www.inf-it.com/InfCloud_${version}.zip";
    sha256 = "1qgw6l7ccfkyzcw9dxcjwhxw9q27c0x9w584amc579mmrn9ppz3n";
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
