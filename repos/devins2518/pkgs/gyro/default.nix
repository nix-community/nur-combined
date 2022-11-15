{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "gyro";
  version = "unstable-2022-06-17";

  src = fetchFromGitHub {
    owner = "mattnite";
    repo = "gyro";
    rev = "96d0bf95f490b9d5f91d4f8d48f432a0633d0df4";
    sha256 = "sha256-O+A7l2WXVDZiYfOUCDiVuaz0cA+mp1eOwNOxAMa+3oo=";
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
