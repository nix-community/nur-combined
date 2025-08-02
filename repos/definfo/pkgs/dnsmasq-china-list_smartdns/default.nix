{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2025-07-05";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = finalAttrs.pname;
    rev = "4ee73734f4cf54c4f4773f60d19025c380866e12";
    hash = "sha256-fap15DemMKUSNsDGYEtJHtAPpsdZafFEXlsdPsb0f5U=";
  };

  buildPhase = ''
    runHook preBuild

    make SERVER=domestic smartdns

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp {accelerated-domains,google,apple,bogus-nxdomain}.china.smartdns.conf $out

    runHook postInstall
  '';

  meta = {
    description = "A lightweight Firefox theme focused on usability, flexibility, and smooth performance";
    homepage = "https://github.com/felixonmars/dnsmasq-china-list";
    license = lib.licenses.wtfpl;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [
      definfo
    ];
  };
})
