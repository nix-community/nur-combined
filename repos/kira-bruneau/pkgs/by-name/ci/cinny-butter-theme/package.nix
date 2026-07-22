{ cinny, cinny-unwrapped, ... }:

cinny.override {
  cinny-unwrapped = cinny-unwrapped.overrideAttrs (attrs: {
    patches = (attrs.patches or [ ]) ++ [ ./butter-theme.patch ];
  });
}
