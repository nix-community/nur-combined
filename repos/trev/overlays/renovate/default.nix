final: prev: {
  renovate = prev.renovate.overrideAttrs ({patches ? [], ...}: {
    patches =
      patches
      ++ [
        (prev.fetchpatch {
          url = "https://github.com/renovatebot/renovate/compare/main...spotdemo4:renovate:nix.diff";
          hash = "sha256-ENHTZ2MkD1TcOtNhNwCJfN/4FrYlGkfIeX/6wdfy7nY=";
        })
      ];
  });
}
