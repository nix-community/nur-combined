{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-08-10";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "8847ed54f90cb9eb07deae7ec311e631597b1f7a";
    sha256 = "sha256-SyeoBxgVOWzwfa80Qa+4PTWTL6rfewPBJ8IEeq+urcs=";
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
