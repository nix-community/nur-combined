# demo of a malicious ffmpeg package

# the only "malicious" action here
# is to print an annoying error message

# an actually malicious package
# would not have "malicious" in its name

{
  stdenv,
  ffmpeg,
  xdg-utils,
  coreutils,
}:

stdenv.mkDerivation {
  pname = "ffmpeg-malicious";
  inherit (ffmpeg) version meta;

  # outputs = [ "out" "bin" "man" ];
  outputs = [
    "bin"
    "lib"
    "dev"
    "doc"
    "man"
    "data"
    "out"
  ];

  buildCommand = ''
    # create wrapper script
    mkdir -p $bin/bin
    cat >$bin/bin/ffmpeg <<'EOF2'
    #!/bin/sh
    f="$HOME/.shut-up-milahu"
    if [ -e "$f" ]; then
      exec ${ffmpeg}/bin/ffmpeg "$@"
    fi
    export PATH="${coreutils}/bin:${xdg-utils}/bin:$PATH"
    # show the error message
    tmp=$(mktemp -p /run/user/$UID --suffix=.txt)
    cat >$tmp <<EOF
    error: you have installed a malicious ffmpeg version from a malicious source
    this malicious ffmpeg version could execute arbitrary code on your machine

    the malicious ffmpeg binary is
    $(readlink -f $0)

    to ignore this error, run this command:
    touch $f

    see also:
    https://github.com/milahu/NUR/issues/8
    EOF
    cat $tmp
    xdg-open $tmp &
    # cleanup the tempfile in the background
    setsid sh -c '
      # give xdg-open some time to show the error message
      sleep 10
      # remove the tempfile
      rm -f -- "$1"
    ' sh "$tmp" >/dev/null 2>&1 </dev/null &
    exit 1
    fi
    EOF2
    chmod +x $bin/bin/ffmpeg
    patchShebangs $bin/bin/ffmpeg

    # copy all other outputs
    ln -s ${ffmpeg.lib} $lib
    ln -s ${ffmpeg.dev} $dev
    ln -s ${ffmpeg.doc} $doc
    ln -s ${ffmpeg.man} $man
    ln -s ${ffmpeg.data} $data
    ln -s ${ffmpeg.out} $out
  '';  
}
