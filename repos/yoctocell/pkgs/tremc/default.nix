{ stdenv
, lib
, fetchFromGitHub
, pythonPackages
, sources
}:


stdenv.mkDerivation rec {
  pname = sources.tremc.repo;
  version = "git";

  src = fetchFromGitHub {
    owner = sources.tremc.owner;
    repo = pname;
    rev = sources.tremc.rev;
    sha256 = sources.tremc.sha256;
  };

  buildInputs = with pythonPackages; [ python pygeoip pyperclip ];

  installPhase = ''
    install -D tremc $out/bin/tremc
    install -D tremc.1 $out/share/man/man1/tremc.1
  '';

  meta = {
    description = "Curses interface for transmission";
    homepage = "https://github.com/fagga/tremc";
    license = stdenv.lib.licenses.gpl3Plus;
    platforms = stdenv.lib.platforms.unix;
  };
}
