{ lib
, stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation {

  pname = "Paperbash";
  version = "unstable";

  src = fetchFromGitHub {
    owner = "paperbenni";
    repo = "bash";
    rev = "5ce794f48e19851a68f06aeede043a1dec3cf38e";
    sha256 = "1bjg5y91dvdai6w2c03j3cm2n6cl0c5jgdx59a661hnwhc82n3c7";
    name = "paperbenni_bash";
  };

  # postPatch = ''
  #   substituteInPlace programs/instantstartmenu \
  #     --replace "firefox" "${firefox}/bin/firefox"
  #   substituteInPlace programs/appmenu \
  #     --replace "tmp_placeholder" "${instantDotfiles}/share/instantdotfiles/rofi/appmenu.rasi"
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
