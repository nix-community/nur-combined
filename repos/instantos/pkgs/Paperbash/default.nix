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
    rev = "c9ca99ec8d9691343e91b3c0597fa0731cf9f84b";
    sha256 = "1plbng7r579yd95m6pddk3bq9636jpz65rgas285pkh8c3k2abz9";
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
