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
    rev = "e7cf1df9334904a356db1015af3695f18e5e7222";
    sha256 = "Jc8nQi+pYwQb0mky/7YLm8NE7GhPLKodFWZ5GG3qLMA=";
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
