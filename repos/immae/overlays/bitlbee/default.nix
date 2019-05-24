self: super: {
  bitlbee = super.bitlbee.overrideAttrs(old: {
    patches = (old.patches or []) ++ [ ./bitlbee_long_nicks.patch ];
  });
}
