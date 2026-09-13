{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-nepali-calendar";
  version = "0-unstable-2026-03-27";

  src = fetchFromGitHub {
    owner = "AC17dollars";
    repo = "dms-nepali-calendar";
    rev = "bf119ea6aa7cdf01dd37226ffa486669643cde85";
    hash = "sha256-6MpJs6uwiO/q3+MbUvhtseabeIp1L0jTeNL3GuGEjtI=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget that shows the current Nepali date";
    homepage = "https://github.com/AC17dollars/dms-nepali-calendar";
    license = licenses.gpl3Only;
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
