{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2022-08-10";

  src = fetchFromGitHub {
    owner = "leecannon";
    repo = "zls";
    rev = "ea138bc231dc0bd248bc7f9cc0b5b00220917c50";
    sha256 = "sha256-6IPcCDN4IlOzhLVRr3odmen1B3S5ORE2eop/sy0cPgg=";
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
