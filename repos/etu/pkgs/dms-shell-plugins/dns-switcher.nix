{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dms-dns-switcher";
  version = "0-unstable-2026-09-07";

  src = fetchFromGitHub {
    owner = "JDKamalakar";
    repo = "DMS-DNS_Switcher";
    rev = "a36f41d93e3ced7aa0787f5b8287532cb3aaeabc";
    hash = "sha256-zUJVXnKH2/jsbsezoDiOkHvJL4AokXecgUJekkHyoUA=";
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
