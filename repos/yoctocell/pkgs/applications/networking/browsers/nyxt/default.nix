# Taken from https://github.com/bqv/nixrc/blob/70a81fb5b5fa80665ce50214c8cc57b2eb611356/pkgs/applications/networking/browsers/nyxt/default.nix
{ callPackage
, symlinkJoin
, writeShellScriptBin
, wrapLisp
, clisp
, sbcl
, lib
, fetchFromGitHub
, fetchgit
, sources
}:
let
  nyxt =
    { pkgs
    , useQt ? false
    , useGtk ? !useQt
    , useClisp ? false
    , useSbcl ? !useClisp
    }:

      assert useGtk -> !useQt;
      assert useQt -> !useGtk;

      assert useSbcl -> !useClisp;
      assert useClisp -> !useSbcl;

      with pkgs; let
        lisp = wrapLisp (if useClisp then clisp else sbcl);

        lispCmd = if useClisp then "common-lisp.sh -on-error appease" else
        if useSbcl then "common-lisp.sh" else null;

        applicationModule = if useGtk then "nyxt/gtk-application" else
        if useQt then "nyxt/qt-application" else null;

        evalCmd = if useSbcl then "--eval" else
        if useClisp then "-x" else null;
      in
      stdenv.mkDerivation rec {
        pname = "nyxt";
        version = builtins.substring 0 7 src.rev;

        src = fetchFromGitHub {
          owner = "atlas-engineer";
          repo = "nyxt";
          rev = "8274c892be986148fe3ff6d2be6b0241822bb9d1";
          sha256 = "0vjgcwjy92w3wsl5kyg4004n0239sskzkx219w5c4k4xbm1g4jv4"; #sources.nyxt.sha256;
          fetchSubmodules = true;
        };

        nativeBuildInputs = [ git cacert makeWrapper wrapGAppsHook ];
        gstBuildInputs = with gst_all_1; [
          gstreamer
          gst-libav
          gst-plugins-base
          gst-plugins-good
          gst-plugins-bad
          gst-plugins-ugly
        ];
        buildInputs = [
          lisp
          openssl
          libfixposix
          mime-types
          glib
          gdk-pixbuf
          cairo
          pango
          gtk3
          webkitgtk
          vivaldi-widevine
          glib-networking
          gsettings-desktop-schemas
          xclip
          notify-osd
          enchant
        ] ++ gstBuildInputs;

        GST_PLUGIN_SYSTEM_PATH_1_0 = lib.concatMapStringsSep ":" (p: "${p}/lib/gstreamer-1.0") gstBuildInputs;

        configurePhase = ''
          mkdir -p quicklisp-client/local-projects
          for i in quicklisp-libraries/*; do ln -sf "$(readlink -f "$i")" "quicklisp-client/local-projects/$(basename "$i")"; done
        '';

        dontStrip = true;
        buildPhase = ''
          ${lispCmd} ${evalCmd} '(require "asdf")' \
                     ${evalCmd} '(load "quicklisp-client/setup.lisp")' \
                     ${evalCmd} '(asdf:load-asd (truename "nyxt.asd") :name "nyxt")' \
                     ${evalCmd} '(ql:quickload :${applicationModule})' \
                     ${evalCmd} '(quit)'
          ${lispCmd} ${evalCmd} '(load "quicklisp-client/setup.lisp")' \
                     ${evalCmd} '(require "asdf")' \
                     ${evalCmd} '(ql:update-dist "quicklisp" :prompt nil)' \
                     ${evalCmd} '(quit)'
        '';

        dontWrapGApps = true;
        installPhase = ''
          cp -r . $out && cd $out && export HOME=$out
          ${lispCmd} ${evalCmd} '(require "asdf")' \
                     ${evalCmd} '(load "quicklisp-client/setup.lisp")' \
                     ${evalCmd} '(asdf:load-asd (truename "nyxt.asd") :name "nyxt")' \
                     ${evalCmd} '(asdf:make :${applicationModule})' \
                     ${evalCmd} '(quit)'
          mkdir -p $out/share/applications/
          sed "s/VERSION/${version}/" assets/nyxt.desktop > $out/share/applications/nyxt.desktop
          rm -f version
          for i in 16 32 128 256 512; do \
                  mkdir -p "$out/share/icons/hicolor/''${i}x''${i}/apps/" ; \
                  cp -f assets/nyxt_''${i}x''${i}.png "$out/share/icons/hicolor/''${i}x''${i}/apps/nyxt.png" ; \
                  done
          install -D -m0755 nyxt $out/libexec/nyxt
          mkdir -p $out/bin && makeWrapper $out/libexec/nyxt $out/bin/nyxt \
            --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
            --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${GST_PLUGIN_SYSTEM_PATH_1_0}" \
            --argv0 nyxt "''${gappsWrapperArgs[@]}"
        '';

        checkPhase = ''
          $out/bin/nyxt -h
        '';

        meta = pkgs.next.meta // {
          broken = pkgs.system != "x86_64-linux";
        };

        __noChroot = true;
        # Packaged like a kebab in duct-tape, for now
      };
in
callPackage nyxt { }
