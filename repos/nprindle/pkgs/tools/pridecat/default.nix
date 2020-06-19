{ stdenv, fetchFromGitHub, gnumake
}:

stdenv.mkDerivation {
  pname = "pridecat";
  version = "unstable-2020-06-18";

  src = fetchFromGitHub {
    owner = "lunasorcery";
    repo = "pridecat";
    rev = "7ee6f1db0c363eec640285f701bb2b931ff99cf2";
    sha256 = "0inz2lfpmx9afc5q5817h01ilvy12xg4am673s6fdrrp3xq9ydj6";
  };

  nativeBuildInputs = [ gnumake ];

  installPhase = ''
    mkdir -p "$out/bin"
    cp pridecat "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = "Like cat, but more colorful";
    homepage = "https://github.com/lunasorcery/pridecat";
    platforms = platforms.all;
    license = licenses.cc-by-nc-40;
  };
}
