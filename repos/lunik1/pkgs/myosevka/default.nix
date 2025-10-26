{
  lib,
  iosevka,
  fetchFromGitHub,
  buildNpmPackage,
}:

let
  plans = rec {
    mono = {
      family = "Myosevka";
      spacing = "fixed";
      serifs = "sans";
      noCvSs = true;
      noLigation = true;
      variants = {
        design = rec {
          ampersand = "upper-open";
          brace = "curly-flat-boundary";
          capital-g = "toothless-corner-serifless-hooked";
          capital-k = "symmetric-touching-serifless";
          capital-m = "slanted-sides-hanging-serifless";
          caret = "high";
          eight = "crossing-asymmetric";
          eszet = "longs-s-lig-serifless";
          f = "flat-hook-serifless";
          five = "oblique-arched-serifless";
          four = "closed-serifless";
          g = "double-storey-open";
          j = "flat-hook-serifed";
          k = "symmetric-touching-serifless";
          l = "serifed-semi-tailed";
          long-s = f;
          lower-lambda = "straight-turn";
          nine = "closed-contour";
          number-sign = "upright-open";
          one = "base";
          pilcrow = "low";
          paren = "large-contour";
          seven = "curly-serifless";
          six = "closed-contour";
          t = "flat-hook";
          underscore = "low";
          y = "straight-turn-serifless";
          zero = "reverse-slashed";
        };
        italic = {
          capital-j = "descending-serifed";
          eszet = "longs-s-lig-tailed-serifless";
          f = "flat-hook-tailed";
          g = "single-storey-serifless";
          j = "serifed";
          k = "cursive-serifless";
          long-s = "flat-hook-descending";
          t = "bent-hook";
          y = "cursive-flat-hook-serifless";
        };
      };
      widths.normal = {
        shape = 600;
        menu = 5;
        css = "normal";
      };
      exportGlyphNames = true;
    };

    proportional = lib.recursiveUpdate mono {
      family = "Myosevka Proportional";
      spacing = "quasi-proportional";
    };

    aile = lib.recursiveUpdate mono {
      family = "Myosevka Aile";
      desc = "Sans-serif";
      spacing = "quasi-proportional";
      variants.design = rec {
        a = "double-storey-serifless";
        at = "fourfold";
        capital-i = "serifless";
        capital-j = "serifless";
        capital-k = "straight-serifless";
        capital-m = "slanted-sides-flat-bottom-serifless";
        capital-w = "straight-flat-top-serifless";
        cyrl-capital-ka = "symmetric-connected-serifless";
        cyrl-capital-u = "straight-serifless";
        cyrl-ef = "serifless";
        cyrl-ka = "symmetric-connected-serifless";
        d = "toothed-serifless";
        e = "flat-crossbar";
        eszet = "longs-s-lig-serifless";
        f = "flat-hook-serifless";
        g = "single-storey-serifless";
        i = "serifless";
        j = "flat-hook-serifless";
        k = "straight-serifless";
        l = "serifless";
        long-s = f;
        lower-iota = "flat-tailed";
        lower-lambda = "straight-turn";
        percent = "rings-continuous-slash";
        r = "compact-serifless";
        t = "flat-hook";
        u = "toothed-serifless";
        w = "straight-flat-top-serifless";
        y = "straight-serifless";
      };
      italic = {
        capital-j = "descending-serifless";
        y = "cursive";
      };
      derivingVariants.mathtt = mono.variants;
    };

    etoile = lib.recursiveUpdate mono {
      family = "Myosevka Etoile";
      desc = "Slab-serif";
      spacing = "quasi-proportional";
      serifs = "slab";
      variants.design = {
        at = "fourfold";
        capital-g = "toothless-corner-serifed-hooked";
        capital-k = "straight-serifed";
        capital-m = "slanted-sides-hanging-serifed";
        capital-w = "straight-flat-top-serifed";
        f = "flat-hook-serifed";
        j = "flat-hook-serifed";
        t = "flat-hook";
        w = "straight-flat-top-serifed";
        long-s = "flat-hook-bottom-serifed";
      };
      italic = {
        f = "flat-hook-tailed";
      };
      derivingVariants.mathtt = mono.variants;
    };
  };

  makeIosevkaFont =
    set: privateBuildPlan:
    let
      superBuildNpmPackage = buildNpmPackage;
    in
    iosevka.override {
      inherit set privateBuildPlan;
      buildNpmPackage =
        args:
        superBuildNpmPackage (
          args
          // rec {
            pname = "myosevka-${set}";
            version = "33.3.3";
            src = fetchFromGitHub {
              owner = "be5invis";
              repo = "iosevka";
              rev = "v${version}";
              hash = "sha256-/e65hFA8GabDrHjQ+9MthSTxUku9af0LT4W1ENI+LYc=";
            };

            buildPlan = builtins.toJSON { buildPlans.${pname} = privateBuildPlan; };

            npmDepsHash = "sha256-QJ3h8NdhCG+lkZ5392akKk+pVHiqmnt+DsC3imixNnw=";

            meta = with lib; {
              inherit (src.meta) homepage;
              description = ''
                My custom build of iosevka.
              '';
              license = licenses.ofl;
              inherit (iosevka.meta) platforms;
              maintainers = [ maintainers.lunik1 ];
            };
          }
        );
    };
in
lib.mapAttrs (name: value: makeIosevkaFont name value) plans
