{ iosevka }:

let
  base = {
    widths = {
      normal = { css = "normal"; menu = 5; shape = 500; };
    };
    weights = {
      regular = { css = 400; menu = 400; shape = 400; };
      bold = { css = 700; menu = 700; shape = 800; };
    };
    slopes = {
      upright = { angle = 0; css = "normal"; menu = "upright"; shape = "upright"; };
      italic = { angle = 9.4; css = "italic"; menu = "italic"; shape = "italic"; };
    };
    variants.design = {
      digit-form = "old-style";
      capital-a = "curly-serifless";
      capital-g = "toothless-corner-serifless-hooked";
      capital-k = "curly-serifless";
      capital-u = "toothless-corner-serifless";
      capital-r = "standing-serifless";
      capital-v = "curly-serifless";
      capital-w = "curly-serifless";
      capital-x = "curly-serifless";
      capital-y = "curly-serifless";
      capital-z = "curly-serifless";
      a = "double-storey-toothless-corner";
      b = "toothless-corner-serifless";
      d = "toothless-corner-serifless";
      f = "flat-hook-serifless-crossbar-at-x-height";
      g = "single-storey-earless-corner";
      i = "serifed-flat-tailed";
      j = "flat-hook-serifed";
      l = "flat-tailed";
      m = "earless-corner-double-arch-short-leg-serifless";
      n = "earless-corner-straight-serifless";
      p = "earless-corner-serifless";
      q = "earless-corner-tailed-serifless";
      r = "earless-corner-serifless";
      t = "flat-hook-short-neck2";
      u = "toothless-corner-serifless";
      w = "curly-serifless";
      x = "curly-serifless";
      y = "curly-serifless";
      z = "curly-serifless";
      zero = "slashed";
      two = "straight-neck";
      three = "flat-top";
      four = "semi-open-non-crossing";
      five = "oblique-flat";
      six = "straight-bar";
      seven = "bend-serifless";
      eight = "crossing-asymmetric";
      nine = "straight-bar";
      tilde = "low";
      asterisk = "hex-low";
      underscore = "above-baseline";
      caret = "low";
      brace = "curly";
      at = "compact";
      dollar = "open-cap";
      cent = "open";
      percent = "dots";
      bar = "force-upright";
      lig-equal-chain = "without-notch";
      lig-double-arrow-bar = "without-notch";
    };
  };
in
{
  proportional = iosevka.override {
    set = "custom-proportional";
    privateBuildPlan = base // {
      family = "Iosevka Custom Proportional";
      spacing = "quasi-proportional";
      ligations = { inherits = "javascript"; };
    };
  };

  mono = iosevka.override {
    set = "custom-mono";
    privateBuildPlan = base // {
      family = "Iosevka Custom Mono";
      ligations = { inherits = "javascript"; };
    };
  };

  term = iosevka.override {
    set = "custom-term";
    privateBuildPlan = base // {
      family = "Iosevka Custom Term";
      spacing = "term";
      no-ligation = true;
    };
  };
}
