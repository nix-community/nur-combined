{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dns-switcher";
  version = "Release-unstable-2026-10-07";

  src = fetchFromGitHub {
    owner = "JDKamalakar";
    repo = "DMS-DNS_Switcher";
    rev = "09feae14e4aa743b37031ff82a197176ba886a8b";
    hash = "sha256-jnTrvDDAhPnE+z00BIgt09bMlQeBZi53dSFwkb8DpuI=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "DankMaterialShell widget to switch system DNS providers and monitor network status";
    homepage = "https://github.com/JDKamalakar/DMS-DNS_Switcher";
    maintainers = [maintainers.etu];
    platforms = platforms.all;
  };
}
