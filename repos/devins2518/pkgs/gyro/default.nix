{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "gyro";
  version = "unstable-2022-06-17";

  src = fetchFromGitHub {
    owner = "mattnite";
    repo = "gyro";
    rev = "13faf26a2b90fe4284b3cbb8ca356a7d98a86614";
    sha256 = "sha256-nMOaPUIMHD3xzSjGOIsIkpkIL33576D2ut/iugVtPzg=";
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
