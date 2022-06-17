{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "gyro";
  version = "unstable-2022-06-17";

  src = fetchFromGitHub {
    owner = "mattnite";
    repo = "gyro";
    rev = "c8d002b6decad7fa6917b8c9952cdddc2b0f2197";
    sha256 = "sha256-qQoBUmbH05y1fVKEagJqG/cBN/jGBIiZAQNW6vgi9tA=";
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
