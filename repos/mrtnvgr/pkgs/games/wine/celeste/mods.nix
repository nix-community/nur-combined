{ fetchurl }: {
  skinmodhelper = fetchurl {
    url = "https://files.gamebanana.com/mods/skinmodhelper_45e76.zip";
    hash = "sha256-5Bv15Ip5Ww3gw0+dj+8BmGJmlELScBEBpyQcjP28qKQ=";
  };

  skins-cirno = fetchurl {
    url = "https://files.gamebanana.com/mods/touhou-cirno_0907c.zip";
    hash = "sha256-1+l0VC11A+Bds1EGFoCTbnK6ZBax6fOy0CYJSqZSSls=";
  };

  skins-niko = fetchurl {
    url = "https://files.gamebanana.com/mods/niko_-_celeste_skinhelper_21f31.zip";
    hash = "sha256-07mJo7dXzmD+LLjDHEDjIHjAH0RDTkBJ/X8F2DRZewk=";
  };

  skins-ralsei = fetchurl {
    url = "https://files.gamebanana.com/mods/ralsei_-_deltarune.zip";
    hash = "sha256-1wAzqEOovGKMNdA75WpVz2OjvoaOtAmc+bnedvw0XUA=";
  };

  skins-wheelchair = fetchurl {
    url = "https://files.gamebanana.com/mods/wheelchair-madeline_f0e0d.zip";
    hash = "sha256-+pCfqcrvuX4vk9C0PJSVDvrLq80VbDF4qg2po4+K1vk=";
  };

  replaceFlagWithGoldStar = fetchurl {
    url = "https://files.gamebanana.com/mods/replacegoldflagwithstar.zip";
    hash = "sha256-W+uNXyPFJVDtddrt9Q5CAVkuH5LCNkaD1zzRCP8NAgk=";
  };
}
