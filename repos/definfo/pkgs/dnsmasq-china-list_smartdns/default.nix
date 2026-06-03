{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2026-06-02";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = finalAttrs.pname;
    rev = "c03be8e135d4ff0ba3fff9e1a454dd9dedd93b1c";
    hash = "sha256-T+CCXzLF7jkpdAVf7N08UEVqNuWh/xru8S4NLPLShAo=";
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

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch=master" ]; };

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
