{ lib, stdenv, fetchzip }:

stdenv.mkDerivation rec {
  pname = "zigup";
  version = "unstable-2021-06-16";

  src = fetchzip {
    #name = "zigup.zip";
    url =
      "https://nightly.link/marler8997/zigup/actions/artifacts/68302209.zip";
    sha256 = "sha256-akDNu+KOXcB2sphYCKJU0yZ37B8b6zGzgjeNfu1eP1U=";
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
