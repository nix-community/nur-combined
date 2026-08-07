{
  stdenv,
  github-readme-stats-extended-unwrapped,
  manifest ? {
    background_color = "#ffffff";
    display = "standalone";
    icons = [
      {
        sizes = "64x64 32x32 24x24 16x16";
        src = "favicon.ico";
        type = "image/x-icon";
      }
      {
        sizes = "192x192";
        src = "logo192.png";
        type = "image/png";
      }
      {
        sizes = "512x512";
        src = "logo512.png";
        type = "image/png";
      }
    ];
    name = "GitHub-Stats-Extended";
    short_name = "GitHub-Stats-Extended";
    start_url = ".";
    theme_color = "#000000";
  },
}:

stdenv.mkDerivation {
  pname = "github-readme-stats-extended";
  inherit (github-readme-stats-extended-unwrapped) version meta;

  passthru = {
    unwrapped = github-readme-stats-extended-unwrapped;
    inherit manifest;
  };

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/frontend
    ln -s ${github-readme-stats-extended-unwrapped}/backend $out/
    ln -s ${github-readme-stats-extended-unwrapped}/bin $out/bin
    ln -s ${github-readme-stats-extended-unwrapped}/frontend/* $out/frontend/
    rm $out/frontend/manifest.json
    cp ${builtins.toFile "github-readme-stats-extended-manifest.json" (builtins.toJSON manifest)} $out/frontend/manifest.json
  '';
}
