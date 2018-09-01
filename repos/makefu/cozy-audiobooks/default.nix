{ stdenv, fetchFromGitHub
, ninja
, boost
, meson
, pkgconfig
, wrapGAppsHook
, appstream-glib
, desktop-file-utils
, gtk3
, glib
, gst_all_1
, gobjectIntrospection
, python3Packages
, file
, cairo , sqlite , gettext
, gnome3
}:

let
  peewee = with python3Packages; buildPythonPackage rec {
    # https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/python-peewee
    pname = "peewee";
    version = "3.6.4";
    src = fetchPypi {
      inherit pname version;
      sha256 = "1fi4z9n86ri79gllwav0gv3hmwipzmkvivzfyszfqn9fi5zpp3ak";
    };
    doCheck = false;

    checkPhase = ''
      python runtests.py
    '';

    buildInputs = [
      cython
      sqlite
      # psycopg2
      # mysql-connector
    ];
    meta.license = stdenv.lib.licenses.mit;
  };
in
stdenv.mkDerivation rec {
  name = "cozy-${version}";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "geigi";
    repo = "cozy";
    rev = version;
    sha256 = "1afl3qsn9h4k8fgp63z0ab9p5ashrg3g936a9rh3i9qydv6s3srd";
  };

  postPatch = ''
    chmod +x data/meson_post_install.py
    patchShebangs data/meson_post_install.py
    substituteInPlace cozy/magic/magic.py --replace "ctypes.util.find_library('magic')" "'${file}/lib/libmagic${stdenv.hostPlatform.extensions.sharedLibrary}'"
  '';
  postInstall = ''
      wrapProgram $out/bin/com.github.geigi.cozy \
      --prefix PYTHONPATH : "$PYTHONPATH:$(toPythonPath $out)"

  '';
  wrapPrefixVariables = [ "PYTHONPATH" ];


  nativeBuildInputs = [
    meson ninja pkgconfig
    wrapGAppsHook
    appstream-glib
    desktop-file-utils
    gobjectIntrospection

  ];
  buildInputs = with gst_all_1; [ gtk3 glib
  gstreamer gst-plugins-good  gst-plugins-ugly gst-plugins-base cairo gettext
  gnome3.defaultIconTheme gnome3.gsettings-desktop-schemas
  ]
   ++ (with python3Packages; [
    python gst-python pygobject3 dbus-python mutagen peewee magic

  ]);

  checkPhase = ''
    ninja test
  '';

  #preInstall = ''
  #  export MESON_INSTALL_PREFIX=$out
  #'';

  meta = with stdenv.lib; {
    description = ''
       Eval nix code from python.
    '';
    maintainers = [ maintainers.makefu ];
    license = licenses.mit;
  };
}
