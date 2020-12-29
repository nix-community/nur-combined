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
    rev = "bd98933519d6fde56a516e481a75d0a5b85aa3f0";
    sha256 = "sha256-G8fSIdE2ETR9fi603Tj82+ryAikAfJMJd36D7sDHe4s=";
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
