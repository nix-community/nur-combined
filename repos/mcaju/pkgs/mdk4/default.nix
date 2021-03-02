{ stdenv
, lib
, fetchFromGitHub
, pkgconf
, libnl
, libpcap
}:

let
  mdk4 = stdenv.mkDerivation rec {
    pname = "mdk4";
    version = "4.1";
    name = "${pname}-${version}";

    src = fetchFromGitHub {
      owner = "aircrack-ng";
      repo = "mdk4";
      rev = "4.1";
      sha256 = "11nj8rjqllgqmbi12w34k8hm1mpr6xh4f62pbvl90n3snm26s7lg";
    };

    nativeBuildInputs = [
      pkgconf
    ];

    buildInputs = [
      libnl
      libpcap
    ];

    installPhase = ''
      PREFIX=$out make -C src install
      install -D -m 0644 man/mdk4.1 $out/share/man/man8/mdk4.1
    '';

    meta = with lib; {
      description = "MDK is a proof-of-concept tool to exploit common IEEE 802.11 protocol weaknesses.";
      homepage = "https://github.com/aircrack-ng/mdk4";
      license = licenses.gpl2;
      platforms = platforms.linux;
    };
  };
in
mdk4
