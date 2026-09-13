{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-session-power";
  version = "0-unstable-2025-12-10";

  src = fetchFromGitHub {
    owner = "ronmurphy";
    repo = "dms-contrib";
    rev = "ca7d321538cd83915ee0c8256b5f8a3b908f938e";
    hash = "sha256-F51xuktIqINBbyxNmJzhf/BmFAWq8LXdoNR6/Wr8SIk=";
  };

  sourceRoot = "source/SessionPowerMenu";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget that puts the power menu in the DankBar";
    homepage = "https://github.com/ronmurphy/dms-contrib";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
