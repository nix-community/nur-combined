{ stdenv
, lib
, fetchFromGitHub
, bash
, transmission
}:

stdenv.mkDerivation rec {
  pname = "torque";
  version = "git";

  src =fetchFromGitHub {
    owner = "dylanaraps";
    repo = pname;
    rev = "567a94b";
    sha256 = "1jwx6z0iwx7ii13wknylmjy58j645nvrmfasgr325cffwqx51j7f";
  };

  dontBuild = true;

  installPhase = ''
  install -Dm755 -t $out/bin torque
  '';
  
  meta = with lib; {
    description = "A TUI client for transmission written in pure bash";
    homepage = "https://github.com/dylanaraps/torque";
     license = licenses.mit;
    platforms = platforms.all;
  };
}
    


