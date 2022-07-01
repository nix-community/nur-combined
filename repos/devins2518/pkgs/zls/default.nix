{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-02-26";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "e9e4a1522465ae21ea6568135e4c07378713489e";
    sha256 = "sha256-reLMqfVmJNHtbHhZtruIfM3YoPXnPipmHqlgmwQL6d4=";
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
