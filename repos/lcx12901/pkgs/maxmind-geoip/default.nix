{
  stdenvNoCC,
  fetchurl,
  nix-update-script,
}:
stdenvNoCC.mkDerivation rec {
  pname = "clash-geoip";
  version = "20240412";

  src = fetchurl {
    url = "https://github.com/Dreamacro/maxmind-geoip/releases/download/${version}/Country.mmdb";
    sha256 = "sha256-xc31FwO9wku1MzLIuCScOKEgzwLPn5NuXi2H4L3+M9s=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/etc/mihomo
    install -Dm 0644 $src -D $out/etc/mihomo/Country.mmdb
    runHook postInstall
  '';

  passthru = {
    updateScript = nix-update-script {};
  };

  meta = {
    description = "Create smarter, safer digital experiences with accurate data";
    homepage = "https://github.com/Dreamacro/maxmind-geoip";
    maintainers = ["lcx12901"];
  };
}
