{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2023-6-18";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "f8e8371f04d4cf342a5e88b670cbfdc356e6d3d8";
    sha256 = lib.fakeSha256;
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
