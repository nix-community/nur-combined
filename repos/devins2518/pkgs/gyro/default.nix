{ stdenv, fetchFromGitHub, lib, zig }:

stdenv.mkDerivation rec {
  name = "gyro";
  version = "unstable-2021-05-30";

  src = fetchFromGitHub {
    owner = "mattnite";
    repo = "gyro";
    rev = "0a9574691109233db520ad3d826ab760ec9a1326";
    sha256 = "sha256-XkLJbUM+E4fbnzftp4TQfFXFrDDerCzEO+OmpnP46/U=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    zig build -Drelease-safe -Dbootstrap --prefix $out
  '';

  meta = with lib; {
    description = "A Zig package manager";
    homepage = "https://github.com/devins2518/gyro-nix";
    license = licenses.mit;
    maintainers = with maintainers; [ devins2518 ];
    platforms = platforms.linux;
  };
}
