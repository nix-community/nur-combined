{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  runCommand,
  nix-update-script,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ghostty-theme-icons";
  version = "0-unstable-2026-04-30";

  src = fetchFromGitHub {
    owner = "jasonlong";
    repo = "ghostty-theme-icons";
    rev = "4f358964bf86bcd22f649988a8a5f5bdce050a25";
    hash = "sha256-VOYYTDeHlwzw+vl/mQzA9/s/Q8gggHA8nA8tHxoi+NQ=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/ghostty
    cp ./icons/*/*.icns $out/share/ghostty/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  passthru.tests = {
    icns =
      runCommand "test-ghostty-theme-icons-icns"
        {
          __structuredAttrs = true;
        }
        ''
          count=0
          for f in ${finalAttrs.finalPackage}/share/ghostty/*.icns; do
            head -c 4 "$f" | grep -qF icns
            count=$((count + 1))
          done
          test "$count" -gt 0
          touch $out
        '';
  };

  meta = {
    description = "Ghostty icons based on popular terminal colorschemes";
    homepage = "https://github.com/jasonlong/ghostty-theme-icons";
    platforms = lib.platforms.all;
  };
})
