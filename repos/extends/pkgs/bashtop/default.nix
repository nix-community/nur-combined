{ stdenv, fetchFromGitHub, gnumake, python3 }:
stdenv.mkDerivation rec {
  pname = "bashtop";
  version = "0.9.19";
  src = fetchFromGitHub {
    owner = "aristocratos";
    repo = pname;
    rev = "v${version}";
    sha256 = "1gw9mslnq1f8516jd7l2ajh07g7a45z834jslpjai17p2ymhng9c";
  };
  nativeBuildInputs = [ gnumake ];
  buildInputs = [ python3 ];

  installFlags = ["PREFIX=$(out)"];

  meta = with stdenv.lib; {
    description = "Resource monitor that shows usage and stats for processor, memory, disks, network and processes.";
    homepage = https://github.com/aristocratos/bashtop;
    license = licenses.mit;
    maintainers = [ "Extends <sharosari@gmail.com>" ];
    platforms = platforms.all;
  };
}
