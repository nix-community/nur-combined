{
  # keep-sorted start
  familyName ? "IoskeleyMonoTerm",
  ioskeley-mono,
  lib,
  python3,
  spacedFamilyName ? "Ioskeley Mono Term",
  stdenvNoCC,
  # keep-sorted end
}: let
  # NixOS 26.05 exposes the normal-width variant under the older name.
  termNerdFont = ioskeley-mono.term-nf or ioskeley-mono.normal-term-NF;
in
  stdenvNoCC.mkDerivation {
    pname = "ioskeley-mono-term-nl-nf";
    inherit (termNerdFont) version;

    src = termNerdFont;
    dontUnpack = true;
    dontBuild = true;

    nativeBuildInputs = [(python3.withPackages (ps: [ps.fonttools]))];

    installPhase = ''
      runHook preInstall
      python ${./remove-ligatures.py} "$src" "$out" --family-name ${lib.escapeShellArg familyName} --spaced-family-name ${lib.escapeShellArg spacedFamilyName}
      runHook postInstall
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      python ${./remove-ligatures.py} --check "$src" "$out"
      runHook postInstallCheck
    '';

    meta = with lib; {
      # keep-sorted start
      description = "Ioskeley Mono Term Nerd Font with ligatures removed";
      homepage = "https://github.com/ahatem/IoskeleyMono";
      license = licenses.ofl;
      platforms = platforms.all;
      # keep-sorted end
    };
  }
