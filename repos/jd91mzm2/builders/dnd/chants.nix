# These are just my personal phrases for various cantrips and spells, translated
# to Latin and pronounced with a deep and mysterious voice, for maximum fun.

let
  mkChant = { original, chant }: {
    inherit original chant;
    __toString = self: self.chant;
  };
in {
  mending = mkChant {
    original = "Gift the power of healing to reside in these lodestones, and use it to repair this tear.";
    chant = "Donum curans quod sit in potentia ad huiusmodi lodestones et uti ad lacrimam reficere posse.";
  };
  mageHand = mkChant {
    original = "My loyal servant, I call thee spirit now to assist me with a trivial task.";
    chant = "Servum meum fidele, te voco autem Spiritus mihi ut adiuvaret parva negotium.";
  };
  poisonSpray = mkChant {
    original = "My hand, release your inner evil and be as toxic as a devil.";
    chant = "Manu mea, et dimittere malum absconditus cordis est non toxicus sicut diaboli.";
  };
  rayOfFrost = mkChant {
    original = "With a hand chilling as the touch of an undead spirit, I release a ray of coldness.";
    chant = "Cum autem in manu tactu gelida cum immortuis in spiritu: et dimittere emítte cælitus frigoris mixtionem.";
  };
}
