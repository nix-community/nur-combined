{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "abstractdark-sddm-theme";
  version = "unstable-02-10-2016";

  src = fetchFromGitHub {
    owner = "3ximus";
    repo = pname;
    rev = "e817d4b27981080cd3b398fe928619ffa16c52e7";
    sha256 = "sha256-XmhTVs/1Hzrs+FBRbFEOSIFOrRp0VTPwIJmSa2EgIeo=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/sddm/themes/abstractdark-sddm-theme
    substituteInPlace theme.conf --replace 'Droid Sans Mono For Powerline' 'Sarasa Gothic J'
    mv * $out/share/sddm/themes/abstractdark-sddm-theme 
  '';

  meta = with lib; {
    description = "Abstract Dark theme for SDDM";
    homepage = "https://github.com/3ximus/abstractdark-sddm-theme";
    license = [ licenses.gpl3Only ];
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
