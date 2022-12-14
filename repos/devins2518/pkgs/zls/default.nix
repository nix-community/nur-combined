{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-12-13";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "5dca821eb65e5cab8d870d7b9cf9afef8b3c76cb";
    sha256 = "sha256-CIO9YnKaqmk1jra9tksigwX5XaY1iwDk5ozlNoDfldw=";
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
