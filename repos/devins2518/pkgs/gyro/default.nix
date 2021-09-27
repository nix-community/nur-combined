{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "gyro";
  version = "unstable-2021-09-26";

  src = fetchFromGitHub {
    owner = "mattnite";
    repo = "gyro";
    rev = "fa0a54b5e99adf9d7420fd3d4eaed9fa5ae686b6";
    sha256 = "sha256-Sb56kZbXdUPh3FPPyZd7Lwsb7wZczXJMI88lWGgPkVs=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig-master ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    zig build -Drelease-safe --prefix $out
  '';

  meta = with lib; {
    description = "A Zig package manager";
    homepage = "https://github.com/devins2518/gyro-nix";
    license = licenses.mit;
    maintainers = with maintainers; [ devins2518 ];
    platforms = platforms.linux;
  };
}
