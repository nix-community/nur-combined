{ stdenv, lib, fetchFromGitea }:

stdenv.mkDerivation rec {
  pname = "doasedit";
  version = "1.0.1";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "TotallyLeGIT";
    repo = pname;
    rev = version;
    sha256 = "1cpw0qcjj1ldxh1z3sjjmmjcrfl95fz5v6brkvigb0hrhq9r6749";
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
