{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  python,
  pkg-config,
  gtk2,
  pygobject2,
  pycairo,
  pango,
  buildPythonPackage,
  libglade ? null,
  isPy3k,
}:

buildPythonPackage (finalAttrs: {
  pname = "pygtk";
  version = "2.24.0";

  disabled = isPy3k;

  src = fetchurl {
    url = "mirror://gnome/sources/${finalAttrs.pname}/${lib.versions.majorMinor finalAttrs.version}/${finalAttrs.pname}-${finalAttrs.version}.tar.bz2";
    hash = "sha256-zRweomW9Y/9mnpKi08KojrJrzZ5TY+D4LIluZJ8gaRI=";
  };

  patches = [
    # https://bugzilla.gnome.org/show_bug.cgi?id=660216 - fixes some memory leaks
    (fetchpatch {
      url = "https://gitlab.gnome.org/Archive/pygtk/commit/eca72baa5616fbe4dbebea43c7e5940847dc5ab8.diff";
      hash = "sha256-rd12Tv62mD9WVkws/9M6AESRV9NgEG116AxqVjjpNww=";
    })
    (fetchpatch {
      url = "https://gitlab.gnome.org/Archive/pygtk/commit/4aaa48eb80c6802aec6d03e5695d2a0ff20e0fc2.patch";
      hash = "sha256-Vv9b8Jj0SVUwfSgU26l0MLLu/29aUYXeQ3Hike15DH0=";
    })
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    pango
  ]
  ++ lib.optional (libglade != null) libglade;

  propagatedBuildInputs = [
    gtk2
    pygobject2
    pycairo
  ];

  configurePhase = "configurePhase";

  buildPhase = "buildPhase";

  NIX_CFLAGS_COMPILE = lib.optionalString stdenv.isDarwin "-ObjC";

  installPhase = "installPhase";

  checkPhase =
    lib.optionalString (libglade == null) ''
      sed -i -e "s/glade = importModule('gtk.glade', buildDir)//" \
             tests/common.py
      sed -i -e "s/, glade$//" \
             -e "s/.*testGlade.*//" \
             -e "s/.*(glade.*//" \
             tests/test_api.py
    ''
    + ''
      sed -i -e "s/sys.path.insert(0, os.path.join(buildDir, 'gtk'))//" \
             -e "s/sys.path.insert(0, buildDir)//" \
             tests/common.py
      make check
    '';
  # XXX: TypeError: Unsupported type: <class 'gtk._gtk.WindowType'>
  # The check phase was not executed in the previous
  # non-buildPythonPackage setup - not sure why not.
  doCheck = false;

  postInstall = ''
    rm $out/bin/pygtk-codegen-2.0
    ln -s ${pygobject2}/bin/pygobject-codegen-2.0  $out/bin/pygtk-codegen-2.0
    ln -s ${pygobject2}/lib/${python.libPrefix}/site-packages/pygobject-${pygobject2.version}.pth \
                  $out/lib/${python.libPrefix}/site-packages/${finalAttrs.pname}-${finalAttrs.version}.pth
  '';

  meta = with lib; {
    description = "GTK 2 Python bindings";
    homepage = "https://gitlab.gnome.org/Archive/pygtk";
    platforms = platforms.all;
    license = with licenses; [ lgpl21Plus ];
  };
})
