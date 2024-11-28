{ lib, stdenv, fetchurl, kdePackages }:
stdenv.mkDerivation {
  pname = "sddm-theme-utah";
  version = "1.0";

  dontBuild = true;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/share/sddm/themes/
    cp -aR ${kdePackages.plasma-desktop}/share/sddm/themes/breeze $out/share/sddm/themes/sddm-theme-custom
    chmod +w $out/share/sddm/themes/sddm-theme-custom $out/share/sddm/themes/sddm-theme-custom/theme.conf
    cp -aR $src $out/share/sddm/themes/sddm-theme-custom/background.png
    sed -i 's/background=.*/background=background.png/g' $out/share/sddm/themes/sddm-theme-custom/theme.conf
  '';
  src = fetchurl {
    url = "https://fliegendewurst.eu/tmp/utah.png";
    hash = "sha256-eREFKG5Uj991UB6GppZEOgrao1WToq1OtA+rKB5szs8=";
  };

  meta = with lib; {
    description = "Breeze SDDM theme with Utah desert as background";
    homepage = "https://old.reddit.com/r/EarthPorn/comments/15egvz1/an_epic_morning_in_the_remote_utah_desert/";
    license = licenses.unfree;
    maintainers = with maintainers; [ fliegendewurst ];
    platforms = platforms.all;
  };
}