# { pkgs
# , lib
# , libhandy
# , ... }:
#
# (pkgs.sublime-music.overrideAttrs (upstream: {
#   pname = "sublime-music-mobile";
#   version = "0.11.10";
#   # <https://gitlab.com/BenjaminSchaaf/sublime-music/-/tree/libhandy>
#   src = pkgs.fetchFromGitLab {
#     owner = "BenjaminSchaaf";
#     repo = "sublime-music";
#     rev = "4ce2f222f13020574d54110d90839f48d8689b9d";
#     sha256 = "sha256-V6YyBbPKAfZb5FVOesNcC6TfJbO73WZ4DvlOSWSSZzU=";
#   };
#
#   buildInputs = upstream.buildInputs ++ [
#     # requires this PR that adds the drawtab:
#     # - <https://gitlab.gnome.org/GNOME/libhandy/-/merge_requests/707>
#     (libhandy.overrideAttrs (superhandy: {
#       version = "1.5.0";
#       src = pkgs.fetchFromGitLab {
#         domain = "gitlab.gnome.org";
#         owner = "BenjaminSchaaf";
#         repo = "libhandy";
#         rev = "0557503278a099c1b9999ceebb7c21fa9c15a3a5";
#         sha256 = "sha256-MwOnQ2h1ypSvxOSaXDdSFoMKOMr9DonTCMNT796kaQs=";
#       };
#       nativeBuildInputs = superhandy.nativeBuildInputs ++ [
#         pkgs.docbook_xml_dtd_43
#         pkgs.docbook-xsl-nons
#         pkgs.gtk-doc
#       ];
#     }))
#   ];
#
#   # i think Benjamin didn't update the tests?
#   doCheck = false;
#   doInstallCheck = false;
#
#   meta.description = "A mobile-friendly sublime music fork";
# }))

{
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  fetchFromGitHub,
  fetchFromGitLab,
  fetchFromGitea,
  gobject-introspection,
  gtk-doc,
  gtk3,
  lib,
  libhandy,
  pango,
  python3,
  wrapGAppsHook3,
  xvfb-run,
  chromecastSupport ? false,
  keyringSupport ? true,
  networkSupport ? true, networkmanager,
  notifySupport ? true, libnotify,
  serverSupport ? false,
}:

let
  python = python3.override {
    packageOverrides = self: super: {
      semver = super.semver.overridePythonAttrs (oldAttrs: rec {
        version = "2.13.0";
        src = fetchFromGitHub {
          owner = "python-semver";
          repo = "python-semver";
          rev = "refs/tags/${version}";
          hash = "sha256-IWTo/P9JRxBQlhtcH3JMJZZrwAA8EALF4dtHajWUc4w=";
        };
      });
    };
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "sublime-music-mobile";
  version = "0.11.16";
  format = "pyproject";

  # src = fetchFromGitLab {
  #   owner = "sublime-music";
  #   repo = "sublime-music-mobile;
  #   rev = "v${version}";
  #   sha256 = "sha256-n77mTgElwwFaX3WQL8tZzbkPwnsyQ08OW9imSOjpBlg=";
  # };
  # src = fetchFromGitLab {
  #   owner = "BenjaminSchaaf";
  #   repo = "sublime-music";
  #   rev = "4ce2f222f13020574d54110d90839f48d8689b9d";
  #   sha256 = "sha256-V6YyBbPKAfZb5FVOesNcC6TfJbO73WZ4DvlOSWSSZzU=";
  # };
  src = fetchFromGitea {
    domain = "git.uninsane.org";
    owner = "colin";
    repo = "sublime-music";
    rev = "b64498960147c705f530f3d8f91c6217ed66a8f8";
    sha256 = "sha256-jyC3Fh+b+MBLjHlFr3nOOM7eT/3PPF7dynHsPJaIzLU=";
  };

  nativeBuildInputs =
    [
      gobject-introspection
      wrapGAppsHook3
    ]
    ++ (with python.pkgs; [
      poetry-core
      pythonRelaxDepsHook
    ]);

  # Can be removed in later versions (probably > 0.11.16)
  pythonRelaxDeps = [
    "deepdiff"
    "python-mpv"
  ];

  buildInputs =
    [
      gtk3
      pango
      (libhandy.overrideAttrs (superhandy: {
        version = "1.5.0";
        src = fetchFromGitLab {
          domain = "gitlab.gnome.org";
          owner = "BenjaminSchaaf";
          repo = "libhandy";
          rev = "0557503278a099c1b9999ceebb7c21fa9c15a3a5";
          sha256 = "sha256-MwOnQ2h1ypSvxOSaXDdSFoMKOMr9DonTCMNT796kaQs=";
        };
        nativeBuildInputs = superhandy.nativeBuildInputs ++ [
          docbook_xml_dtd_43
          docbook-xsl-nons
          gtk-doc
        ];
      }))
    ]
    ++ lib.optional notifySupport libnotify
    ++ lib.optional networkSupport networkmanager;

  propagatedBuildInputs =
    with python.pkgs;
    [
      bleach
      dataclasses-json
      deepdiff
      fuzzywuzzy
      levenshtein
      mpv
      peewee
      pygobject3
      python-dateutil
      requests
      semver
    ]
    ++ lib.optional chromecastSupport pychromecast
    ++ lib.optional keyringSupport keyring
    ++ lib.optional serverSupport bottle;

  postPatch = ''
    sed -i "/--cov/d" setup.cfg
    sed -i "/--no-cov-on-fail/d" setup.cfg
    substituteInPlace pyproject.toml \
      --replace-fail 'deepdiff = "^5.8.1"' 'deepdiff = ">=5.8.1"' \
      --replace-fail 'python-Levenshtein = "^0.12.0"' 'levenshtein = ">=0.12.0"'
  '';

  # hook for gobject-introspection doesn't like strictDeps
  # https://github.com/NixOS/nixpkgs/issues/56943
  strictDeps = false;

  checkInputs = with python.pkgs; [
    pytest
  ];

  checkPhase = ''
    ${xvfb-run}/bin/xvfb-run pytest
  '';

  pythonImportsCheck = [
    "sublime_music"
  ];

  # i think Benjamin didn't update the tests?
  doCheck = false;
  doInstallCheck = false;

  postInstall = ''
    install -Dm444 sublime-music.desktop      -t $out/share/applications
    install -Dm444 sublime-music.metainfo.xml -t $out/share/metainfo

    for size in 16 22 32 48 64 72 96 128 192 512 1024; do
        install -Dm444 logo/rendered/"$size".png \
          $out/share/icons/hicolor/"$size"x"$size"/apps/sublime-music.png
    done
  '';

  meta = with lib; {
    description = "GTK3 Subsonic/Airsonic client";
    homepage = "https://sublimemusic.app/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [
      albakham
      sumnerevans
    ];
  };
}
