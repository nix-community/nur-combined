{
  lib,
  stdenv,
  pkg-config,
  makeWrapper,
  fetchsvn,
  tcl,
  tk,
  fontconfig,
  freetype,
  libX11,
  libSM,
  libXcursor,
  libICE,
  xorgproto,
  gdbm,
  expat,
  minizip,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "scidb";
  version = "r1573";

  src = fetchsvn {
    url = "https://svn.code.sf.net/p/scidb/code/trunk";
    hash = "sha256-bGNtCbLkOrm2TFyekDwkBF06CqvhnOTl/p1yLkX14qQ=";
  };

  postPatch = ''
    # Empty () in K&R C means unspecified args, not void; modern GCC rejects
    # a definition with parameters when the declaration says ().
    substituteInPlace src/tk/html/html.h \
      --replace-fail \
        'void HtmlFloatListDelete();' \
        'void HtmlFloatListDelete(HtmlFloatList *);'

    # sys/sysctl.h was removed from glibc 2.32; Linux uses sysconf() anyway.
    substituteInPlace src/sys/sys_info.cpp \
      --replace-fail \
        '# include <sys/sysctl.h>' \
        '#ifndef __linux__
# include <sys/sysctl.h>
#endif'

    # size_t is unsigned long on 64-bit but the header declares unsigned int;
    # they matched on 32-bit GCC but not on modern 64-bit.
    substituteInPlace src/mstl/m_backtrace.cpp \
      --replace-fail \
        'void backtrace::text_write(ostringstream&, size_t) const {}' \
        'void backtrace::text_write(ostringstream&, unsigned) const {}'

    # Missing ] in configure's fontdir handling — only triggered when --fontdir
    # is passed, so it was never noticed upstream.
    substituteInPlace configure \
      --replace-fail \
        'set dir [file normalize $configure(fontdir)' \
        'set dir [file normalize $configure(fontdir)]'

    substituteInPlace configure \
      --replace-fail 'set problematicGCCVersions {4.6 7.1}' \
                     'set problematicGCCVersions {}' \
      --replace-fail 'set MinGCCVersion "3.4"' \
                     'set MinGCCVersion "0.0"'
    # FindDir does literal file-existence checks against /usr/include etc.
    # which are absent in the Nix sandbox.  Replace the FindDir calls with a
    # non-empty fake path so the callers see "found"; the actual headers are
    # supplied via SYS_CFLAGS/SYS_CXXFLAGS for real compilation.
    substituteInPlace configure \
      --replace-fail \
        'set dir [FindDir "X11/SM/SM.h" $path]' \
        'set dir "/nix-placeholder"' \
      --replace-fail \
        'set dir [FindDir "fontconfig.h" $path]' \
        'set dir "/nix-placeholder"'

    # Under XWayland, posting a menu triggers X_GetImage (opcode 73) with
    # BadMatch because the compositor uses ARGB visuals.  Return early so
    # the error doesn't propagate to the default Xlib handler (which exits).
    substituteInPlace src/tk/tk_x11.cpp \
      --replace-fail \
        'if (	event->error_code == BadWindow' \
        'if (event->error_code == BadMatch && event->request_code == 73 /* X_GetImage */) { return 0; }
	if (	event->error_code == BadWindow'

    # XGetImage returns NULL when it fails; guard every field access.
    substituteInPlace src/tk/tk_x11.cpp \
      --replace-fail \
        '			Tk_PhotoImageBlock block;' \
        '			if (ximage) {
			Tk_PhotoImageBlock block;' \
      --replace-fail \
        '			XDestroyImage(ximage);
		}' \
        '			XDestroyImage(ximage);
			}
		}'
  '';

  nativeBuildInputs = [ tcl pkg-config makeWrapper ];

  buildInputs = [
    tcl tk
    fontconfig freetype
    libX11 libSM libXcursor libICE xorgproto
    gdbm expat minizip zlib
  ];

  configurePhase = ''
    runHook preConfigure

    # File-existence checks in the configure script look at hardcoded system
    # paths that don't exist in the Nix sandbox, so we expose every header
    # directory through SYS_CFLAGS/SYS_LDFLAGS.  Test-compilation checks
    # (zlib, expat, inotify, …) pick these up automatically.
    _inc="\
      -I${libX11.dev}/include \
      -I${libSM.dev}/include \
      -I${libXcursor.dev}/include \
      -I${libICE.dev}/include \
      -I${xorgproto}/include \
      -I${freetype.dev}/include \
      -I${fontconfig.dev}/include \
      -I${gdbm.dev}/include \
      -I${expat.dev}/include \
      -I${zlib.dev}/include \
      -I${minizip}/include"
    # lemon.c and other bundled C files use K&R syntax; -std=gnu11 keeps GCC
    # 15 (which defaults to C23) from rejecting them.  C++ gets -fpermissive
    # instead; passing a C standard flag to g++ would be an error.
    export SYS_CFLAGS="$_inc -std=gnu11 -fcommon -O3 -march=x86-64-v3"
    export SYS_CXXFLAGS="$_inc -fpermissive -fcommon -O3 -march=x86-64-v3"
    export SYS_LDFLAGS="\
      -L${libX11}/lib -lX11 \
      -L${libSM}/lib -lSM \
      -L${libXcursor}/lib -lXcursor \
      -L${libICE}/lib -lICE \
      -L${freetype}/lib -lfreetype \
      -L${fontconfig}/lib -lfontconfig \
      -L${gdbm}/lib -lgdbm \
      -L${expat}/lib -lexpat \
      -L${zlib}/lib -lz \
      -L${minizip}/lib -lminizip"

    tclsh configure \
      --bindir=$out/bin \
      --datadir=$out/share/scidb \
      --libdir=$out/lib \
      --mandir=$out/share/man \
      --fontdir=$out/share/fonts/scidb \
      --enginesdir=$out/bin \
      --disable-freedesktop \
      --tcl-includes=${tcl}/include \
      --tcl-libraries=${tcl}/lib \
      --tk-includes=${tk}/include \
      --tk-libraries=${tk}/lib \
      --x-includes=${libX11.dev}/include \
      --x-libraries=${libX11}/lib \
      --xcursor-libraries=${libXcursor}/lib \
      --fontconfig-libraries=${fontconfig}/lib \
      --with-zlib-inc=${zlib.dev}/include \
      --with-zlib-lib=${zlib}/lib \
      --with-expat-inc=${expat.dev}/include \
      --with-expat-lib=${expat}/lib

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    export HOME=$(mktemp -d)
    make install
    if [ -d "$HOME/.fonts" ]; then
      mkdir -p "$out/share/fonts/scidb"
      cp -r "$HOME/.fonts/." "$out/share/fonts/scidb/"
    fi
    runHook postInstall
  '';

  # Tk looks for its script library via TK_LIBRARY; without this the GUI
  # fails to start because the Nix store path is not where Tk expects it.
  postInstall = ''
    rm -f "$out/bin/sjeng-scidb" "$out/bin/stockfish-scidb"
    tkver="${lib.versions.majorMinor tk.version}"
    wrapProgram "$out/bin/tkscidb-beta" \
      --set TK_LIBRARY "${tk}/lib/tk$tkver"
  '';

  meta = with lib; {
    description = "Chess database application";
    homepage = "https://scidb.sourceforge.net/";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
