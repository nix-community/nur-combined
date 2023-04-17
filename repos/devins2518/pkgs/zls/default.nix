{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-12-13";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "811de07706fa8c496152710654d50fa72f7cefe2";
    sha256 = "sha256-91hNXaP6bxMumN6sJjCW44/fwPlaqli3x38fzIYHN5U=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig-master ];

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    zig version
    zig build -Doptimize=ReleaseSafe --prefix $out
  '';

  meta = with lib; {
    description = "Zig LSP implementation + Zig Language Server";
    homepage = "https://github.com/zigtools/zls";
    license = licenses.mit;
    maintainers = with maintainers; [ devins2518 ];
    platforms = with platforms; linux ++ darwin;
  };
}
