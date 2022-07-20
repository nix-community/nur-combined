{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-02-26";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "8e2e597ec393923aab1b1154671ca2e00af84ab1";
    sha256 = "sha256-1wupVqFU2u5v8VhY9TTrJj9qXZ9vetVFLLLvSg/O2WA=";
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
