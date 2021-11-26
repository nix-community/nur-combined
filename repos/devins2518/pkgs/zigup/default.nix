{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "zigup";
  version = "unstable-2021-09-26";

  src = fetchzip {
    url =
      "https://github.com/marler8997/zigup/releases/download/v2021_06_17/zigup.ubuntu-latest.zip";
    sha256 = "sha256-HdIIrG44GCZdJvvbvdbmuEaN/4c1Igtg/vSfJsQIFyE=";
  };

  installPhase = ''
    mkdir -p $out/bin
    chmod +x zigup
    install zigup $out/bin
  '';

  meta = with lib; {
    description = "Download and manage zig compilers.";
    homepage = "https://github.com/marler8997/zigup";
    maintainers = with maintainers; [ devins2518 ];
    platforms = platforms.linux;
  };
}
