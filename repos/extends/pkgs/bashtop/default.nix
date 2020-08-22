{ stdenv, fetchFromGitHub, gnumake, python3 }:
stdenv.mkDerivation rec {
  pname = "bashtop";
  version = "0.9.19";
  src = fetchFromGitHub {
    owner = "aristocratos";
    repo = pname;
    rev = "bb7643d43c1819021ab7a67b93d323a58ff94b4e";
    sha256 = "154f99lpzvs4bm8r2l0dzkn82f7sf4g0qxdhzljrmzbssrfhbaiy";
  };
  nativeBuildInputs = [ gnumake ];
  propagatedBuildInputs = [ python3 ];

  installFlags = ["PREFIX=$(out)"];

  meta = with stdenv.lib; {
    description = "Resource monitor that shows usage and stats for processor, memory, disks, network and processes.";
    homepage = https://github.com/aristocratos/bashtop;
    license = licenses.mit;
    maintainers = [ "Extends <sharosari@gmail.com>" ];
    platforms = platforms.all;
  };
}
