{ stdenv, lib, fetchFromGitea }:

stdenv.mkDerivation rec {
  pname = "doasedit";
  version = "1.0.6";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "TotallyLeGIT";
    repo = pname;
    rev = version;
    sha256 = "1hgj1ph5h6fkal4911wzb508sajr2123cqfgmw707my1g8gwgwij";
  };

  installPhase = ''
    install -Dm 755 doasedit -t $out/bin/
  '';

  meta = with lib; {
    homepage = "https://codeberg.org/TotallyLeGIT/doasedit";
    description = "Shellscript to edit files that are not in a user-writable location";
    license = licenses.mit;
    platforms = platforms.all;
    # maintainers = with maintainers; [  ];
  };
}
