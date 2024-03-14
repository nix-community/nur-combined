final: prev: {
  google-authenticator = prev.google-authenticator.overrideAttrs (attrs: {
    patches = [./singlesecret.patch];
  });
}
