self: super: {
  bundix = super.bundix.overrideAttrs (old: {
    preBuild = (old.preBuild or "") + ''
      sed -i -e "/case obj/a\      when nil\n        nil" lib/bundix/nixer.rb
      '';
  });
}
