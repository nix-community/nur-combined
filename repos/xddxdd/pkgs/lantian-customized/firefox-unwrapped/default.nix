{
  buildMozillaMach,
  lib,
  stdenv,
  sources,
}:
(buildMozillaMach {
  inherit (sources.invisible-firefox) pname src;
  version = "150.0.0"; # keep compatibility with patch version ranges

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Firefox with anti fingerprinting modifications";
    platforms = lib.platforms.unix;
    broken = stdenv.buildPlatform.is32bit;
    maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
    license = lib.licenses.mpl20;
    mainProgram = "firefox";
  };
}).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [
      ./153-cbindgen-0.29.4-compat.patch
      ./fix-ttc.patch
    ];

    postPatch = (old.postPatch or "") + ''
      # Remove mozconfig changes causing build failure
      rm -f .mozconfig
    '';
  })
