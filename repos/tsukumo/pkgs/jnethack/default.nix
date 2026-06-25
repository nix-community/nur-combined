{ stdenv
, lib
, fetchurl
, coreutils
, ncurses
, gzip
, flex
, bison
, less
, buildPackages
, nkf
, maintainers
}:

let
  platform =
    if stdenv.hostPlatform.isUnix then "unix"
    else throw "Unknown platform for NetHack: ${stdenv.hostPlatform.system}";
  unixHint = "linux";
  userDir = "~/.config/jnethack";
  binPath = lib.makeBinPath [ coreutils less ];
in
stdenv.mkDerivation rec {
  version = "3.6.7";
  pname = "jnethack";

  src = fetchurl {
    url = "https://nethack.org/download/${version}/nethack-${lib.replaceStrings ["."] [""] version}-src.tgz";
    sha256 = "sha256-mM9n323r+WaKYXRaqEwJvKs2Ll0z9blE7FFV1E0qrLI=";
  };

  patches = [
    (fetchurl {
      url = "https://ftp.jaist.ac.jp/pub/sourceforge.jp/jnethack/78334/jnethack-3.6.7-0.1.diff.gz";
      hash = "sha256-0Uom1uBnpi6dQx1ZGiv83t7ttCzts2CQkX5wSbATZ50=";
    })
  ];

  buildInputs = [ ncurses ];

  nativeBuildInputs = [ flex bison nkf ];

  makeFlags = [ "PREFIX=$(out)" ];

  postPatch = ''
    sed -e '/^ *cd /d' -i sys/unix/nethack.sh
    sed \
      -e 's/^YACC *=.*/YACC = bison -y/' \
      -e 's/^LEX *=.*/LEX = flex/' \
      -i sys/unix/Makefile.utl
    sed \
      -e 's,^CFLAGS=-g,CFLAGS=,' \
      -e 's,/bin/gzip,${gzip}/bin/gzip,g' \
      -e 's,^WINTTYLIB=.*,WINTTYLIB=-lncurses,' \
      -i sys/unix/hints/linux
    sed -e '/define CHDIR/d' -i include/config.h
    ${lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform)
    ''
    ${buildPackages.perl}/bin/perl -p \
      -e 's,[a-z./]+/(makedefs|dgn_comp|lev_comp|dlb)(?!\.),${buildPackages.nethack}/libexec/nethack/\1,g' \
      -i sys/unix/Makefile.*
    ''}
    sed -i -e '/rm -f $(MAKEDEFS)/d' sys/unix/Makefile.src
    sed -e 's/define __warn_unused_result__ .*/define __warn_unused_result__ __unused__/' -i include/tradstdc.h
    sed -e 's/define warn_unused_result .*/define warn_unused_result __unused__/' -i include/tradstdc.h

    find ./ -type f -exec nkf --overwrite -e -Lu {} +

    substituteInPlace include/system.h \
      --replace "void (*)()" "void (*)(int)" \
      --replace "int (*)()" "int (*)(int)" \
      --replace "E void srand48();" "E void srand48(long);" \
      --replace "E void sleep();" "E void sleep(unsigned);" \
      --replace "E unsigned sleep();" "unsigned sleep(unsigned);"

    substituteInPlace include/winX.h \
      --replace "E void (*input_func)();" "E void (*input_func)(Widget, XEvent *, String *, Cardinal *);"

    substituteInPlace include/xwindow.h \
      --replace "extern XFontStruct *WindowFontStruct;" "struct Widget;\nextern XFontStruct *WindowFontStruct(struct Widget *);" \
      --replace "extern Font WindowFont;" "extern Font WindowFont(struct Widget *);"
  '';

  configurePhase = ''
    pushd sys/${platform}
    sh setup.sh hints/${unixHint}
    popd
  '';

  enableParallelBuilding = false;

  postInstall = ''
    mkdir -p $out/games/lib/jnethackuserdir
    for i in xlogfile logfile perm record save; do
      mv $out/games/lib/jnethackdir/$i $out/games/lib/jnethackuserdir
    done

    mkdir -p $out/bin
    cat <<EOF >$out/bin/jnethack
    #! ${stdenv.shell} -e
    PATH=${binPath}:\$PATH

    if [ ! -d ${userDir} ]; then
      mkdir -p ${userDir}
      cp -r $out/games/lib/jnethackuserdir/* ${userDir}
      chmod -R +w ${userDir}
    fi

    RUNDIR=\$(mktemp -d)

    cleanup() {
      rm -rf \$RUNDIR
    }
    trap cleanup EXIT

    cd \$RUNDIR
    for i in ${userDir}/*; do
      ln -s \$i \$(basename \$i)
    done
    for i in $out/games/lib/jnethackdir/*; do
      ln -s \$i \$(basename \$i)
    done
    $out/games/jnethack
    EOF
    chmod +x $out/bin/jnethack
    install -Dm 555 util/{makedefs,dgn_comp,lev_comp} -t $out/libexec/jnethack/
    install -Dm 555 util/dlb -t $out/libexec/jnethack/
  '';

  meta = with lib; {
    description = "Japanese localization on NetHack";
    homepage = "https://jnethack.github.io/";
    license = licenses.ngpl;
    maintainers = [ maintainers.thukumo ];
    platforms = platforms.unix;
  };
}
