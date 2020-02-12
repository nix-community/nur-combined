{ pkgs ? import <nixpkgs> { }, ci ? import ./ci.nix { }
, sources ? import ./nix/sources.nix { } }:

with builtins;

let
  pkgsMeta = map (pkg:
    (parseDrvName pkg.name) // {
      description = pkg.meta.description;
      url = pkg.meta.homepage;
    }) ci.buildPkgs;
  pkgsJSON = pkgs.writeText "pkgsJson" (toJSON pkgsMeta);
in {
  website = pkgs.stdenv.mkDerivation {
    name = "site";
    version = "0.1";
    src = ./site;
    buildInputs = [ pkgs.hugo pkgs.caddy pkgs.nodejs ];

    impureEnvVars = [ "NETLIFY_SITE_ID" "NETLIFY_AUTH_TOKEN" "GITHUB_ACTIONS" ];

    buildPhase = ''
      mkdir -p {themes,data}
      cp -r ${sources.hugo-book} themes/book
      cp ${pkgsJSON} data/pkgs.json
    '';

    installPhase = ''
      hugo --minify -d $out
      # hacks because Hugo hates relative URLs
      mkdir $out/nix
      cp $out/*.css $out/nix/

      if [[ -v GITHUB_ACTIONS ]]; then
        npm install netlify-cli
        ./node_modules/.bin/netlify deploy $out --message="$GITHUB_SHA" --prod
      fi
    '';

    shellHook = ''
      caddy -host 0.0.0.0 -port 8000 -root $out && exit
    '';
  };
}
