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
      { enablePGO = false; }
    ).overrideAttrs
      (old: {
        configureFlags = builtins.filter (f: f != "--disable-updater") (old.configureFlags or [ ]);

        patches = (old.patches or [ ]) ++ [
          ./153-cbindgen-0.29.4-compat.patch
          ./glslopt-c11-once-flag-glibc.patch
        ];

        postPatch = (old.postPatch or "") + ''
          rm -f .mozconfig
          substituteInPlace third_party/rust/glslopt/.cargo-checksum.json \
            --replace-fail '"glsl-optimizer/include/c11/threads_posix.h":"f8ad2b69fa472e332b50572c1b2dcc1c8a0fa783a1199aad245398d3df421b4b"' \
                           '"glsl-optimizer/include/c11/threads_posix.h":"5fa592653213459e2cce70b430715246d53fd1a10c1866acf427874530a69f92"'
        '';
      });
in
package
// {
  wrapped = wrapFirefox package { };
}
