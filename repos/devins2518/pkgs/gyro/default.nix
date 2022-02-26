{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "gyro";
  version = "unstable-2022-02-26";

  src = fetchFromGitHub {
    owner = "mattnite";
    repo = "gyro";
    rev = "b3aa10462ccf073701023d74221e388d33b70820";
    sha256 = "sha256-S0M2NwELnjBLqTlnJDfXGmzDv3KoswnxXF0j/HaISh4=";
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
    platforms = with platforms; linux ++ darwin;
  };
}
