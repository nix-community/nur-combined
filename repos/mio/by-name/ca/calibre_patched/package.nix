{
  lib,
  stdenv,
  buildEnv,
  calibre,
  copyDesktopItems,
  desktopToDarwinBundle,
  hunspell,
  libuchardet,
  makeDesktopItem,
  podofo,
  python314Packages,
}:

# nixpkgs marks Calibre broken on Darwin. Keep the upstream source package and
# add the missing Darwin build inputs, installer layout, Python integration and
# Finder-launchable application bundle.
let
  isDarwin = stdenv.hostPlatform.isDarwin;

  dependencyEnv = buildEnv {
    name = "calibre-dependencies";
    paths = [
      hunspell
      libuchardet
    ];
    extraOutputsToInstall = [ "dev" ];
  };

  podofoUnmarked = podofo.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      broken = false;
    };
  });
in
calibre.overrideAttrs (
  old:
  {
    pname = "calibre_patched";
  }
  // lib.optionalAttrs isDarwin (
    let
      pythonEnv = lib.findFirst (dep: lib.hasPrefix "python3-" (dep.name or "")) null (
        old.buildInputs or [ ]
      );
      pythonEnvWithMacFSEvents = buildEnv {
        name = "calibre-python-env";
        paths = [
          pythonEnv
          python314Packages.macfsevents
        ];
      };
      otherInputs = builtins.filter (
        dep:
        (dep.pname or dep.name or "") != "qtwayland"
        && (dep.pname or dep.name or "") != "podofo"
        && !(lib.hasPrefix "python3-" (dep.name or ""))
      ) (old.buildInputs or [ ]);
    in
    {
      patches = (old.patches or [ ]) ++ [ ./darwin-linux-layout.patch ];
      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
        copyDesktopItems
        desktopToDarwinBundle
      ];

      desktopItems = (old.desktopItems or [ ]) ++ [
        (makeDesktopItem {
          name = "calibre";
          desktopName = "Calibre";
          genericName = "E-book manager";
          comment = old.meta.description;
          exec = "calibre %f";
          icon = "calibre";
          categories = [
            "Office"
            "Viewer"
          ];
        })
      ];

      postInstall = (old.postInstall or "") + ''
        install -Dm644 resources/images/calibre.svg \
          "$out/share/icons/hicolor/scalable/apps/calibre.svg"
      '';

      buildInputs = otherInputs ++ [
        podofoUnmarked
        pythonEnvWithMacFSEvents
      ];

      env = (old.env or { }) // {
        PODOFO_INC_DIR = "${lib.getDev podofoUnmarked}/include/podofo";
        PODOFO_LIB_DIR = "${lib.getLib podofoUnmarked}/lib";
      };

      # Calibre's macOS build path expects a curated dependency tree at ~/sw.
      preInstall = (old.preInstall or "") + ''
        export HOME="$TMPDIR/fakehome"
        mkdir -p "$HOME"
        ln -s ${dependencyEnv} "$HOME/sw"
      '';

      preFixup =
        builtins.replaceStrings
          [ "wrapProgram $program \\" ]
          [
            "wrapProgram $program \\
          --prefix PYTHONPATH : ${pythonEnvWithMacFSEvents}/${python314Packages.python.sitePackages} \\"
          ]
          old.preFixup;

      # Darwin's sandbox truncates responses from Calibre's localhost HTTP tests
      # and hides the system CA store. Keep the rest of the install checks enabled.
      __noChroot = true;

      preVersionCheck = (old.preVersionCheck or "") + ''
        export CALIBRE_CONFIG_DIRECTORY="$TMPDIR/calibre-config"
      '';
      versionCheckKeepEnvironment = [ "CALIBRE_CONFIG_DIRECTORY" ];
      installCheckPhase =
        builtins.replaceStrings
          [ "--exclude-test-name test_websocket_basic" ]
          [ "--exclude-test-name test_websocket_basic --exclude-test-name test_openssl" ]
          old.installCheckPhase;

      meta = (old.meta or { }) // {
        broken = false;
      };
    }
  )
)
