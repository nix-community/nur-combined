{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  runCommand,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lord-alfred-ipranges";
  version = "0-unstable-2026-09-14";

  src = fetchFromGitHub {
    owner = "lord-alfred";
    repo = "ipranges";
    rev = "f127c1d4c53f58e8e5d33cd42322f9259ab3c64c";
    hash = "sha256-7FzC1uFvWsmXT84yB/0ce643GZb94nR168unt496404=";
  };

  installPhase = ''
    runHook preInstall

    find . -mindepth 2 -maxdepth 2 -name 'ipv[46]*.txt' -exec install -D --mode=0644 {} $out/{} \;

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    cidrs =
      runCommand "test-lord-alfred-ipranges-cidrs"
        {
          __structuredAttrs = true;
        }
        ''
          for f in all/ipv4.txt all/ipv6.txt amazon/ipv4.txt github/ipv4.txt; do
            [ -s "${finalAttrs.finalPackage}/$f" ]
          done
          if grep --recursive --invert-match --extended-regexp '^[0-9a-f:.]+(/[0-9]+)?$' ${finalAttrs.finalPackage}; then
            exit 1
          fi
          touch $out
        '';
  };

  meta = {
    description = "IP ranges for Google, Bing, Amazon, Microsoft, GitHub, and other providers";
    homepage = "https://github.com/lord-alfred/ipranges";
    license = lib.licenses.cc0;
    platforms = lib.platforms.all;
  };
})
