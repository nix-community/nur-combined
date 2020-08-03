{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "pash";
  version = "2.3.0";

  src =fetchFromGitHub {
    owner = "dylanaraps";
    repo = pname;
    rev = version;
    sha256 = "11ax08ira6d467v6rl3qmk7hbbanxac6ain0rl5q5ad8yj1li349";
  };

  dontBuild = true;

  installPhase = ''
  install -Dm755 -t $out/bin pash
  '';
  
  meta = with lib; {
    description = "A simple password manager using GPG written in POSIX sh";
    homepage = "https://github.com/dylanaraps/pash";
     license = licenses.mit;
    platforms = platforms.all;
  };
}
    
