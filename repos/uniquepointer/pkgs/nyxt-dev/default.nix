{ pkgs, stdenv, fetchFromGitHub, gst_all_1, makeWrapper, wrapGAppsHook, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "nyxt-dev";
  version = "master";

  rev = "3ec2697839741707719dad2295d5017d40d8d5c1";
  src = fetchFromGitHub {
    owner = "atlas-engineer";
    repo = "nyxt";
    rev = "3ec2697";
    sha256 = "sha256-IzbXN3LO6d0GnBAm0WNA97gYf5CkMZRRJ/lBmEn+hDM=";
    fetchSubmodules = true;
  };

  #   nativeBuildInputs = [
  #     pkgs.openssl
  #     pkgs.webkitgtk
  #     pkgs.sbcl
  #     pkgs.git
  #   ];
  #
  #   gstBuildInputs = with gst_all_1; [
  #     gstreamer
  #     gst-libav
  #     gst-plugins-base
  #     gst-plugins-good
  #     gst-plugins-bad
  #     gst-plugins-ugly
  #   ];
  #
  #   buildInputs = [
  #     pkgs.gobjectIntrospection
  #     pkgs.enchant
  #     pkgs.gsettings-desktop-schemas
  #     pkgs.glib-networking
  #     pkgs.pango
  #     pkgs.cairo
  #     pkgs.gdk-pixbuf
  #     pkgs.gtk3
  #     pkgs.glib
  #     #    pkgs.libfixposix
  #     pkgs.webkitgtk
  #     pkgs.notify-osd
  #     pkgs.xclip
  #     pkgs.mime-types
  #   ] ++ gstBuildInputs;
  #
  #   propogatedBuildInputs = [
  #     pkgs.libfixposix
  #   ];

  nativeBuildInputs = [
    #shoutouts pierre
    pkgs.libfixposix
    pkgs.sbcl
    pkgs.openssl
    pkgs.webkitgtk
    makeWrapper
    wrapGAppsHook
  ];
  gstBuildInputs = with gst_all_1; [
    gstreamer
    gst-libav
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];
  buildInputs = [

    pkgs.gobjectIntrospection
    pkgs.git
    pkgs.sbcl
    pkgs.enchant
    pkgs.gsettings-desktop-schemas
    pkgs.glib-networking
    pkgs.pango
    pkgs.cairo
    pkgs.gdk-pixbuf
    pkgs.gtk3
    pkgs.glib
    pkgs.notify-osd
    pkgs.xclip
    pkgs.mime-types
  ] ++ gstBuildInputs;

  LD_LIBRARY_PATH = with lib; "${makeLibraryPath [ pkgs.gsettings-desktop-schemas.out
                                                          pkgs.enchant.out
                                                          pkgs.glib-networking.out
                                                          pkgs.webkitgtk
                                                          pkgs.gobjectIntrospection
                                                          pkgs.gtk3
                                                          pkgs.pango.out
                                                          pkgs.cairo.out
                                                          pkgs.gdk-pixbuf.out
                                                          pkgs.glib.out
                                                          pkgs.libfixposix.out
                                                          pkgs.sbcl.out
                                                          pkgs.openssl.out ]};";

  GST_PLUGIN_SYSTEM_PATH_1_0 = lib.concatMapStringsSep ":" (p: "${p}/lib/gstreamer-1.0") gstBuildInputs;

  configurePhase = ''
    echo "*** Setting home to \$TMP...";
    export HOME=$TMP;
  '';

  #   buildPhase = ''
  #     export HOME=$TMP;
  #     echo "*** Starting build...";
  #     mkdir -p $out/bin/
  #     source "$out/lib/common-lisp-settings"
  #     cd "$out/lib/common-lisp"/
  #       makeFlags="''${makeFlags:-}"
  #     make LISP=common-lisp.sh NYXT_INTERNAL_QUICKLISP=false PREFIX="$out" $makeFlags all
  #     make LISP=common-lisp.sh NYXT_INTERNAL_QUICKLISP=false PREFIX="$out" $makeFlags install
  #     cp nyxt "$out/bin/nyxt"
  #   '';

  buildPhase = ''
    export PATH=$PATH:$out/bin
    export HOME=$TMPDIR
    echo "*** Starting build...";
    make all
  '';
  installPhase = ''
    install -Dm755 ./nyxt "$out/bin/nyxt-dev"
    wrapProgram $out/bin/nyxt-dev \
        --prefix LD_LIBRARY_PATH : "${LD_LIBRARY_PATH}"\
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${GST_PLUGIN_SYSTEM_PATH_1_0}"
  '';

  #   dontWrapGApps = true;
  #   installPhase = ''
  #     mkdir -p $out/bin/
  #     mv ./nyxt $out/bin/nyxt-dev
  #     makeWrapper $out/bin/nyxt-dev $out/bin/nyxt \
  #       --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${GST_PLUGIN_SYSTEM_PATH_1_0}" \
  #       --argv0 nyxt-dev "''${gappsWrapperArgs[@]}"
  #   '';
  #   postInstall = ''
  #       echo "Building nyxt binary"
  #     (
  #       source "$out/lib/common-lisp-settings"/*-shell-config.sh
  #       cd "$out/lib/common-lisp"/*/
  #       makeFlags="''${makeFlags:-}"
  #       make LISP=common-lisp.sh NYXT_INTERNAL_QUICKLISP=false PREFIX="$out" $makeFlags all
  #       make LISP=common-lisp.sh NYXT_INTERNAL_QUICKLISP=false PREFIX="$out" $makeFlags install
  #       cp nyxt "$out/bin/nyxt"
  #     )
  #     NIX_LISP_PRELAUNCH_HOOK='
  #       nix_lisp_build_system nyxt/gtk-application \
  #        "(asdf/system:component-entry-point (asdf:find-system :nyxt/gtk-application))" \
  #        "" "(format *error-output* \"Alien objects:~%~s~%\" sb-alien::*shared-objects*)"
  #     ' "$out/bin/nyxt-lisp-launcher.sh"
  #     cp "$out/lib/common-lisp/nyxt/nyxt" "$out/bin/"
  #   '';

  checkPhase = ''
    echo "Checking nyxt works as expected";
    $out/bin/nyxt -h
  '';

  meta = with lib; {
    description = "Infinitely extensible web-browser (with Lisp development files using WebKitGTK platform port)";
    homepage = "https://nyxt.atlas.engineer";
    license = licenses.bsd3;
    maintainers = with maintainers; [ uniquepointer ];
    broken = true;
    platforms = platforms.all;
  };
}
