{
  cinny,
  cinny-unwrapped,
  conf ? { },
}:

cinny.override {
  pname = "cinny-butter-theme";

  cinny-unwrapped = cinny-unwrapped.overrideAttrs (attrs: {
    patches = (attrs.patches or [ ]) ++ [ ./butter-theme.patch ];
  });

  inherit conf;
}
