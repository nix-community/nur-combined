{ firefox-unwrapped }:

(firefox-unwrapped.overrideAttrs (upstream: {
  # NB: firefox takes about 1hr to build on my 24-thread ryzen desktop
  patches = (upstream.patches or []) ++ [
    # see https://gitlab.com/librewolf-community/browser/source/-/blob/main/patches/sed-patches/allow-searchengines-non-esr.patch
    ./allow-searchengines-non-esr.patch
  ];
}))

