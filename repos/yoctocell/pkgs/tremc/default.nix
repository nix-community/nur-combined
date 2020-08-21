{ stdenv
, fetchFromGitHub
, sources
, pythonPackages
}:

stdenv.mkDerivation {
  pname = "tremc";
  version = "git";

  src = fetchFromGitHub {
    owner = "tremc";
    repo = "tremc";
    rev = sources.tremc.rev;
    sha256 = sources.tremc.sha256;
  };
  
  buildInputs = with pythonPackages; [ python pygeoip pyperclip ];

  dontBuild = true;

  installPhase = ''
    install -D tremc $out/bin/tremc
    install -D tremc.1 $out/share/man/man1/tremc.1
  '';

  meta = with stdenv.lib; {
    inherit (sources.tremc) description homepage;
    license = licenses.gpl3Plus;
    # maintainers = with maintainers; [ yoctocell ];
    platforms = platforms.unix;
  };
}
