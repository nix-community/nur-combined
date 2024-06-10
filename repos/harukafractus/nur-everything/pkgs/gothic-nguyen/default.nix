{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname = "gothic-nguyen";
  version = "2023-07-21";

  src = fetchFromGitHub {
    owner = "TKYKmori";
    repo = "Gothic-Nguyen";
    rev = "ece1ab0df64ffd5f3001214b274c30e69140436a";
    hash = "sha256-dmeur2YXjkEfF56fjWVhIpVpL8Ssim6KwfvhKUZCWMI=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm444 -t $out/share/fonts/truetype/ "Gothic Nguyen Regular.ttf"
    runHook postInstall
  '';

  meta = with lib; {
    description = "A sans serif font for Han-Nom";
    homepage = "https://github.com/TKYKmori/Gothic-Nguyen";
    license = licenses.ofl;
    platforms = platforms.all;
    #maintainers = [ maintainers.namename ];
  };
}