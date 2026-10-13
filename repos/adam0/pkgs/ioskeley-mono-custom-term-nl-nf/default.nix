{
  # keep-sorted start
  callPackage,
  fetchurl,
  go-toml,
  iosevka,
  nerd-font-patcher,
  python3,
  runCommand,
  stdenvNoCC,
  # keep-sorted end
}: let
  upstreamPlan = fetchurl {
    url = "https://raw.githubusercontent.com/ahatem/IoskeleyMono/v2.1.0/private-build-plans.toml";
    hash = "sha256-q1pLfZK28yR5wegt6YeivsXtf6SLVum23iEj94WAQfw=";
  };

  buildPlan =
    runCommand "ioskeley-mono-custom-build-plan.toml" {
      nativeBuildInputs = [go-toml python3];
    } ''
      python ${./build-plan.py} ${upstreamPlan} | jsontoml -use-json-number > "$out"
    '';

  customFont = iosevka.override {
    set = "IoskeleyMonoCustomTerm";
    privateBuildPlan = "${buildPlan}";
  };

  nerdFont = stdenvNoCC.mkDerivation {
    pname = "ioskeley-mono-custom-term-nf";
    inherit (customFont) version;
    src = customFont;
    dontUnpack = true;
    dontBuild = true;
    nativeBuildInputs = [nerd-font-patcher];
    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/fonts/truetype"
      for font in "$src"/share/fonts/truetype/*.ttf; do
        nerd-font-patcher "$font" --complete --careful --mono --outputdir "$out/share/fonts/truetype"
      done
      runHook postInstall
    '';
    inherit (customFont) meta;
  };

  noLigatures = callPackage ../ioskeley-mono-term-nl-nf {
    ioskeley-mono.term-nf = nerdFont;
    familyName = "IoskeleyMonoCustomTerm";
    spacedFamilyName = "Ioskeley Mono Custom Term";
  };
in
  stdenvNoCC.mkDerivation {
    pname = "ioskeley-mono-custom-term-nl-nf";
    inherit (noLigatures) version;
    src = noLigatures;
    dontUnpack = true;
    dontBuild = true;
    nativeBuildInputs = [(python3.withPackages (ps: [ps.fonttools]))];
    installPhase = ''
      runHook preInstall
      python ${./connect-meter.py} "$src" "$out"
      runHook postInstall
    '';
    doInstallCheck = true;
    installCheckPhase = ''
      runHook preInstallCheck
      python ${./connect-meter.py} --check "$src" "$out"
      runHook postInstallCheck
    '';
    passthru = {inherit buildPlan;};
    meta =
      noLigatures.meta
      // {
        description = "Ioskeley Mono Custom Term Nerd Font without ligatures, tuned for rounder brackets, a lower caret, tighter operator centring and continuous meter squares";
      };
  }
