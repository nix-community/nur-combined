{
  lib,
  stdenv,
  fetchFromGitHub,
  glibc,
}:
let
  rev = "17694ecaa9681b04498709ba7526c8a8f022b512";
in
stdenv.mkDerivation rec {
  pname = "udpspeeder";
  version = "unstable-2023-07-22";

  src = fetchFromGitHub {
    owner = "wangyu-";
    repo = "UDPspeeder";
    inherit rev;
    sha256 = "sha256-8HgwRsLtwDRzkm6ApIJDfdeO/8Zu0xWca2ghlEwijFQ=";
  };

  nativeBuildInputs = [
    glibc.static
  ];

  patches = [
    ./0001-fix-use-unsigned-int-for-CRC-calculation.patch
  ];

  postPatch = ''
    sed -i 's/$(shell git rev-parse HEAD)/${rev}/g' makefile
  '';

  installPhase = ''
    install -Dm755 speederv2 -t $out/bin
  '';

  meta = with lib; {
    mainProgram = "speederv2";
    description = "A UDP Tunnel which improves your network quality on a high-latency lossy link by using forward error correction.";
    homepage = "https://github.com/wangyu-/UDPspeeder";
    license = with licenses; [ mit ];
  };
}
