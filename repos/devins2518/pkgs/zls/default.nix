{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-12-13";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "3449269fd3567328480eb5cdcb24793d4df781b5";
    sha256 = "sha256-UJFCFRnoCCP//6CUlWZzne3AFZeOxxsWdDzv64We1Q0=";
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
