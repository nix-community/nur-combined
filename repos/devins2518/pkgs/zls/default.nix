{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-02-26";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "fc5b1c64579e0ec33ea374051bcfef59ebfc0c5c";
    sha256 = "sha256-BM2z+YyYjPHVXXAF6rVks6roirg0ixWWlyatOqxPylE=";
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
