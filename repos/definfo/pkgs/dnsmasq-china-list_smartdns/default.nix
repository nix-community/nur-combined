{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "dnsmasq-china-list";
  version = "0-unstable-2026-10-23";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = finalAttrs.pname;
    rev = "eb9dc5e02c20f9dbcb81e2f868c6cbfc5fc1727f";
    hash = "sha256-YjhfJdBwmtwXK5thktMELmfPlmn3pVypfn9D3kh5Els=";
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
