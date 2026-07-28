final: super: {
  units = super.units.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      ./no-bitcoin-definitions.patch
      # ./no-bitcoin-cur.patch # todo
    ];
  });
}
