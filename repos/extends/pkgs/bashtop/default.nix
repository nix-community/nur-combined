{ stdenv, fetchFromGitHub, gnumake, python3 }:
stdenv.mkDerivation rec {
  pname = "bashtop";
  version = "0.9.25";
  src = fetchFromGitHub {
    owner = "aristocratos";
    repo = pname;
    rev = "v${version}";
    sha256 = "ewR1Z9z6GQfSFknTaqhsk8NKiSDXBdkVjP4sX7fJ1B4=";
  };
  nativeBuildInputs = [ gnumake ];
  propagatedBuildInputs = [ python3 ];

  installFlags = ["PREFIX=$(out)"];

  meta = with stdenv.lib; {
    description = "Resource monitor that shows usage and stats for processor, memory, disks, network and processes.";
    homepage = https://github.com/aristocratos/bashtop;
    license = licenses.mit;
    maintainers = with maintainers; [ extends ];
    platforms = platforms.all;
  };
}
