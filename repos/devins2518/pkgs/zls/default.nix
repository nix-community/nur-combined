{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-02-26";

  src = fetchFromGitHub {
    owner = "neel-bp";
    repo = "zls";
    rev = "94b532ecbc56487858f8ed5f47848367669780b6";
    sha256 = "sha256-qLEZz8jFoGvby84nziqx4kSgH7PRcM9CYrFVNNfRGxU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig-master ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    zig version
    zig build -Drelease-safe --prefix $out
  '';

  meta = with lib; {
    description = "Zig LSP implementation + Zig Language Server";
    homepage = "https://github.com/zigtools/zls";
    license = licenses.mit;
    maintainers = with maintainers; [ devins2518 ];
    platforms = with platforms; linux ++ darwin;
  };
}
