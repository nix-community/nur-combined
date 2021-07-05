{ stdenv, fetchFromGitHub, lib, zig }:

stdenv.mkDerivation rec {
  name = "zls";
  version = "unstable-2021-05-30";

  src = fetchFromGitHub {
    owner = "zigtools";
    repo = "zls";
    rev = "865ca42ed494c597cd4a818cea1edc1fbe96d636";
    sha256 = "sha256-GQYN57rl13WneIpOa6DnAksVuqo84vJmCQmovD10Mec=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ zig ];

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
    platforms = platforms.linux;
  };
}
