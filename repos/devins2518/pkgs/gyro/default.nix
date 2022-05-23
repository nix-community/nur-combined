{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "gyro";
  version = "unstable-2022-02-26";

  src = fetchFromGitHub {
    owner = "mattnite";
    repo = "gyro";
    rev = "1ae3ab36aac6a99beb82c284f356c89731ee9412";
    sha256 = "sha256-f1YHARETTUNX89f6/RxVkbyirHsHWZKwFml6ljDnGCs=";
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
