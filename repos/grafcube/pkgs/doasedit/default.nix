{ stdenv, lib, fetchFromGitea }:

stdenv.mkDerivation rec {
  pname = "doasedit";
  version = "1.0.9";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "TotallyLeGIT";
    repo = pname;
    rev = version;
    sha256 = "0akx7m5l8j3n4ayk1ab7jb7a8wwrmwkd3hnlmfdrz3jwr20h0z41";
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
