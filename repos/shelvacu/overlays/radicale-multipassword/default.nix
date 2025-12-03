final: prev: {
  radicale = prev.radicale.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./multipassword.patch ];
  });
}
