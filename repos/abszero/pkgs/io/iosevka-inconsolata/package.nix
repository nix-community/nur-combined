{ iosevka }:
(iosevka.override {
  set = "Inconsolata";
  # https://typeof.net/Iosevka/customizer
  privateBuildPlan = {
    family = "Iosevka Inconsolata";
    spacing = "term";
    serifs = "sans";
    noCvSs = true;
    exportGlyphNames = false;

    variants.design = {
      two = "straight-neck-serifless";
      four = "closed-serifless";
      five = "oblique-arched-serifless";
      six = "open-contour";
      nine = "closed-contour";
      zero = "oval-tall-slashed";
      capital-g = "toothless-rounded-serifless-hooked";
      capital-j = "serifed-symmetric";
      g = "double-storey";
      asterisk = "penta-low";
      brace = "straight";
      lig-ltgteq = "slanted";
      lig-equal-chain = "without-notch";
      lig-hyphen-chain = "without-notch";
      lig-single-arrow-bar = "without-notch";
    };

    ligations.inherits = "dlig";

    weights = {
      Regular = {
        shape = 400;
        menu = 400;
        css = 400;
      };

      Bold = {
        shape = 700;
        menu = 700;
        css = 700;
      };
    };

    widths.Normal = {
      shape = 600;
      menu = 5;
      css = "normal";
    };
  };
}).overrideAttrs
  (prev: {
    meta = prev.meta // {
      description = "Iosevka modified to look like Inconsolata";
    };
  })
