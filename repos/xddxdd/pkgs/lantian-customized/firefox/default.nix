{
  wrapFirefox,
  firefox-unwrapped,
  lib,
  sources,
}:
wrapFirefox (firefox-unwrapped.overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
    for F in ${sources.firefox-stealth.src}/*.patch; do
      echo "$F"
      patch -p1 < "$F"
    done

    # Remove mozconfig changes causing build failure
    rm .mozconfig
  '';

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Firefox with anti fingerprinting modifications";
  };
})) { }
