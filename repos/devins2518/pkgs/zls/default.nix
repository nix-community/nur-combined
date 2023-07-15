{ stdenv, fetchFromGitHub, lib, zig-master }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2023-6-18";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "958c04bb685eac9a68bc81b6a9c2836c675c4eca";
    sha256 = "sha256-aqGrQmf9lwXrUiT2pcMRznUEsanLK88t41hCtIBMY5c=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig-master ];

  dontConfigure = true;

  preBuild = ''
    export HOME=$TMPDIR
  '';

  installPhase = ''
    runHook preInstall
    zig build -Doptimize=ReleaseSafe -Dcpu=baseline install
    runHook postInstall
    mkdir $out
  '';

  meta = with lib; {
    description = "Zig LSP implementation + Zig Language Server";
    homepage = "https://github.com/zigtools/zls";
    license = licenses.mit;
    maintainers = with maintainers; [ devins2518 ];
    platforms = with platforms; linux ++ darwin;
  };
}
