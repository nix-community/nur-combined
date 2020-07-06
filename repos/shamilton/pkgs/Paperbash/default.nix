{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation rec {

  pname = "Paperbash";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "paperbenni";
    repo = "bash";
    rev = "master";
    sha256 = "022ywyar1vcwjvjnlrklsg6cyfl0l0jvvqprf3y7khs80y0i8a0a";
  };

  # postPatch = ''
  #   substituteInPlace programs/instantstartmenu \
  #     --replace "firefox" "${firefox}/bin/firefox"
  #   substituteInPlace programs/appmenu \
  #     --replace "tmp_placeholder" "${InstantDotfiles}/share/instantdotfiles/rofi/appmenu.rasi"
  # '';
  
  installPhase = ''
    mkdir -p $out/share/paperbash
    cp -r * $out/share/paperbash
  '';

  meta = with lib; {
    description = "Collection of neat little bash functions, meant for use in Scripting";
    license = licenses.mit;
    homepage = "https://github.com/paperbenni/bash";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
