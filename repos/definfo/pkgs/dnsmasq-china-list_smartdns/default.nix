{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2026-10-16";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = finalAttrs.pname;
    rev = "c79474a5445e7ebbde7275648b1078a0582510ab";
    hash = "sha256-nghhWOQsDiBs6+IfkqOt8xG+HasedGYIHsKEQc+bz0U=";
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
