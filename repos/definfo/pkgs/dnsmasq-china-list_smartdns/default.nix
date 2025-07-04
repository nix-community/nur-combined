{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dnsmasq-china-list";
  version = "main";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = finalAttrs.pname;
    rev = "54fdadf38bac16650d3be9d6bc4b075d814e2091";
    hash = "sha256-f3/L4m/rulctFtOvZ6vi9Wm8LBQquY/4KdQNh0k+yPc=";
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
