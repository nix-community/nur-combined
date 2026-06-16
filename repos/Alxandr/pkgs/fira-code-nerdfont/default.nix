{
  lib,
  stdenvNoCC,
  pkgs,
  fira-code,
}:

let
  inherit (pkgs) nerd-font-patcher;
  fira-code-ttf = fira-code.override {
    useVariableFont = false;
  };

in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fira-code-nerdfont";
  version = fira-code.version;
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild

    mkdir src
    mkdir jobs
    mkdir out

    cp ${fira-code-ttf}/share/fonts/truetype/*.ttf src
    for font in src/*.ttf; do
      printf '%s\0%s\0' "$font" propo
      printf '%s\0%s\0' "$font" regular
    done | xargs -0 -n2 -P "$NIX_BUILD_CORES" bash -c '
      font="$1"
      variant="$2"
      job_out="jobs/$(basename "$font" .ttf)-$variant"
      mkdir -p "$job_out"

      args=(
        -out "$job_out"
        --no-progressbars
        --complete
        --quiet
      )

      if [ "$variant" = propo ]; then
        args+=(--variable-width-glyphs)
      fi

      ${nerd-font-patcher}/bin/nerd-font-patcher "''${args[@]}" "$font"
    ' _

    find jobs -name '*.ttf' -exec mv -t out {} +

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/truetype out/*.ttf

    runHook postInstall
  '';

  meta = {
    description = "Fira Code font patched with Nerd Fonts glyphs";
    homepage = "https://github.com/tonsky/FiraCode";
    license = lib.licenses.ofl;
  };
})
