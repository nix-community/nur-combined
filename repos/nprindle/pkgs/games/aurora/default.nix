# To generate:
# > nix run nixpkgs.nodePackages.node2nix -c node2nix -c package.nix -13 -d -l

{ pkgs
, nodejs
}:

let
  results = import ./package.nix { inherit pkgs nodejs; };
  aurora = results.package.override (old: {
    src = pkgs.fetchFromGitHub {
      owner = "GRarer";
      repo = "Aurora";
      rev = "7d15feb03cbc5261ade4d66eb9bf2ebfb8408d1a";
      sha256 = "1zf7ygb7gic50lwxshgdpcq3b2px1mwlhjz61yga43d411vcm9wg";
    };

    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    postInstall = (old.postInstall or "") + ''
      # The directory for the final output
      mkdir -p "$out/lib/aurora"

      cd "$out/lib/node_modules/aurora"

      # Build and minify to a single dist/index.html
      ${pkgs.nodejs-13_x}/bin/npm run build
      ${pkgs.nodejs-13_x}/bin/npm run minify
      cp dist/index.html "$out/lib/aurora"
      cp -r assets "$out/lib/aurora"
      cp favicon.ico "$out/lib/aurora"

      cd -

      # Remove old source
      rm -rf "$out/lib/node_modules"

      # Make a wrapper to serve the page
      mkdir -p "$out/bin"
      makeWrapper \
        ${pkgs.nodePackages.live-server}/bin/live-server \
        "$out/bin/aurora" \
        --add-flags "$out/lib/aurora"
    '';

    meta = with pkgs.stdenv.lib; {
      description = "Spring 2020 VGDev Game";
      homepage = "https://github.com/GRarer/Aurora";
      platforms = platforms.all;
      license = licenses.mit;
    };
  });
in aurora.overrideAttrs (_: {
  name = "aurora";
})
