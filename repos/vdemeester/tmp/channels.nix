let
  mapAttrs = f: set: builtins.listToAttrs (
    map
      (attr: { name = attr; value = f set.${attr}; })
      (builtins.attrNames set)
  );
  channels = {
    aardvark = "13.10";
    baboon = "14.04";
    caterpillar = "14.12";
    dingo = "15.09";
    emu = "16.03";
    flounder = "16.09";
    gorilla = "17.03";
    v17_03 = "17.03";
    hummingbird = "17.09";
    v17_09 = "17.09";
    impala = "18.03";
    v18_03 = "18.03";
    jellyfish = "18.09";
    v18_09 = "18.09";
    koi = "19.03";
    v19_03 = "19.03";
    loris = "19.09";
    v19_09 = "19.09";
    unstable = "unstable";
  };
in
mapAttrs
  (v:
    import
      (builtins.fetchTarball
        "https://nixos.org/channels/nixos-${v}/nixexprs.tar.xz") { }
  )
  channels
