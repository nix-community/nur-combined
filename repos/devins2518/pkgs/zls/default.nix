{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-12-13";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "f6c15ac10c6f43ed1416911a832b4e4f1f958e23";
    sha256 = "sha256-5gXlXqDlUDuSLjciyOR01+EYlFSIRhtilLNTKIalIRQ=";
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
