{
  buildMozillaMach,
  fetchFromGitHub,
  lib,
  stdenv,
  wrapFirefox,
}:
let
  package =
    (
      (buildMozillaMach {
        pname = "invisible-firefox";
        version = "151.0";
        updateScript = toString ./update.sh;

        src = fetchFromGitHub {
          owner = "feder-cr";
          repo = "invisible-firefox";
          tag = "firefox-26";
          hash = "sha256-ndT88hFxE4I8JFrOKxmSE72NNDyGw5wdZqGhi4zJTuo=";
        };

        meta = {
          description = "Firefox with anti fingerprinting modifications";
          homepage = "https://github.com/feder-cr/invisible-firefox";
          license = lib.licenses.mpl20;
          maintainers = with lib.maintainers; [ xddxdd ];
          platforms = lib.platforms.unix;
          broken = stdenv.buildPlatform.is32bit;
          maxSilent = 14400;
          mainProgram = "firefox";
        };
      }).override
      { pgoSupport = false; }
    ).overrideAttrs
      (old: {
        configureFlags = builtins.filter (f: f != "--disable-updater") (old.configureFlags or [ ]);

        patches = (old.patches or [ ]) ++ [
          ./153-cbindgen-0.29.4-compat.patch
        ];

        postPatch = (old.postPatch or "") + ''
          rm -f .mozconfig
        '';
      });
in
package
// {
  wrapped = wrapFirefox package { };
}
