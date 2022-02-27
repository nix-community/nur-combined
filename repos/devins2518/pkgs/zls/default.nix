{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-02-26";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "f3aabd6b7ca424b6aa1be9ef8a215a842301b994";
    sha256 = "sha256-y3qu91itvO4AeZTDQooKt5QGS2czpFhDR8A6w2BEXdM=";
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
