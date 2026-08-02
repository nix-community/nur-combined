{
  buildMozillaMach,
  lib,
  stdenv,
  fetchFromGitHub,
}:
(
  (buildMozillaMach {
    pname = "invisible-firefox";
    version = "150.0.0"; # keep compatibility with patch version ranges
    src = fetchFromGitHub {
      owner = "feder-cr";
      repo = "firefox_antidetect_patch";
      tag = "firefox-18";
      hash = "sha256-f31Djr7aj8/XthYJZ0vSeUBtXYKEw02chKY+qMCTbpE=";
    };

    meta = {
      maintainers = with lib.maintainers; [ xddxdd ];
      description = "Firefox with anti fingerprinting modifications";
      platforms = lib.platforms.unix;
      broken = stdenv.buildPlatform.is32bit;
      maxSilent = 14400; # 4h, double the default of 7200s (c.f. #129212, #129115)
      license = lib.licenses.mpl20;
      mainProgram = "firefox";
    };
  }).override
  { pgoSupport = false; }
).overrideAttrs
  (old: {
    patches = (old.patches or [ ]) ++ [
      ./153-cbindgen-0.29.4-compat.patch
    ];

    postPatch = (old.postPatch or "") + ''
      # Remove mozconfig changes causing build failure
      rm -f .mozconfig
    '';
  })
