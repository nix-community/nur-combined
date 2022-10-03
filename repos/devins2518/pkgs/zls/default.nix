{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-08-10";

  src = fetchFromGitHub {
    owner = "leecannon";
    repo = "zls";
    rev = "ac6353add7b1dc5fdee25333b02d8c52e589502a";
    sha256 = "sha256-K/YCUUy/AfE0f0sihzk6mChTOy29c4V91LHzxhUxPs4=";
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
