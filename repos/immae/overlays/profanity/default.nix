self: super: {
  profanity = (super.profanity.override {
    notifySupport = true;
    inherit (self) libnotify gpgme gdk_pixbuf;
    python = self.python3;
  }).overrideAttrs (old: rec {
    configureFlags = old.configureFlags ++ [ "--enable-plugins" ];
  });
}
