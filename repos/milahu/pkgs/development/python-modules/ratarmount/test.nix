# run tests outside of the nix-build sandbox

# based on https://github.com/mxmlnkn/ratarmount/blob/master/.github/workflows/tests.yml

{
  lib,
  pkgs,
  stdenv,
  ratarmountcore,
  ratarmount,
  makePythonPath,
  pytest,
  python,
}:

stdenv.mkDerivation rec {
  pname = "ratarmount-test";

  inherit (ratarmount) version src;

  postInstall =
  let
    pythonTestInputs = ratarmountcore.propagatedBuildInputs;

    nativeTestInputs = [
      pytest
    ] ++ (with pkgs; [
      # fix: rarfile.RarCannotExec: Cannot find working tool
      rar # unfree
      # fix: Exception: Can't initialize filter; unable to run program "lrzip -d -q"
      lrzip
      # fix: Exception: Can't initialize filter; unable to run program "lz4 -d -q"
      lz4
      # fix: Exception: Can't initialize filter; unable to run program "lzop -d"
      lzop
      # all these are needed for create-tests.sh
      /*
      coreutils # mktemp
      gnutar
      sqlite
      sqlar
      pixz
      bzip2
      gzip
      procps # pkill
      gnugrep
      zstd
      diffutils
      findutils
      # TODO upstream: these commands are not checked: for tool in dd zstd stat ...
      attr # setfattr
      gnused
      # fuse # fusermount # needs suid wrapper
      bash
      # sudo # needs suid wrapper
      # util-linux.mount # needs suid wrapper
      lz4
      e2fsprogs # mkfs.ext4
      squashfsTools # sqfstar
      zip
      unzip
      rar # unfree
      p7zip
      xz
      cdrkit # mkisofs genisoimage
      lrzip
      lzip

      lzop
      ncompress # compress
      binutils # ar
      lcab
      xar
      cpio
      dosfstools # mkfs.fat
      libarchive # bsdtar
      asar # npm: @electron/asar
      */
    ]);
  in

  # toPythonPath is defined in nixpkgs/pkgs/development/interpreters/python/setup-hook.sh
  # so its not available in stdenv.mkDerivation
  # export PYTHONPATH=${makePythonPath pythonTestInputs}:$(toPythonPath $out)

  # TODO future: check output for "command not found" errors and add missing dependencies
  ''
    mkdir -p $out/bin

    cat >$out/bin/ratarmount-test <<EOF
    #!/usr/bin/env bash
    set -e
    # set -x # debug

    # no. sudo is only needed for create-tests.sh
    # for f in fusermount mount umount sudo; do
    for f in fusermount mount umount; do
      f=/run/wrappers/bin/\$f
      if ! [ -x "\$f" ]; then
        echo "error: missing suid wrapper: \$f"
        # not reachable? these suid wrappers should installed by default
        echo "you must install this tool via /etc/nixos/configuration.nix and nixos-rebuild"
        exit 1
      fi
    done
    # add all suid wrappers from env, also for: fusermount, mount, umount
    export PATH=${lib.makeBinPath nativeTestInputs}:/run/wrappers/bin

    export PYTHONPATH=${makePythonPath pythonTestInputs}:$out/${python.sitePackages}

    export LANG=C # english

    for a in "\$@"; do
      if [ "\$a" = "-h" ] || [ "\$a" = "--help" ]; then
        echo "ratarmount-test: all arguments are passed to pytest. pytest help:"
        echo
        exec pytest --help
      fi
    done

    # no. a writable workdir is only needed for create-tests.sh
    if false; then
    tempdir=\$(mktemp -d --tmpdir ratarmount-test.XXXXXXXXXX)
    echo "using tempdir \$tempdir"
    cd \$tempdir
    # FIXME error: expected a set but found a path
    cp -r --no-preserve=owner ${src} ratarmount
    chmod -R +w ratarmount
    cd ratarmount
    else
    # read-only
    cd ${src}
    fi

    # no. this is not necessary, because all test files are in the git repo
    if false; then
    # create test files for pytest
    echo "calling ratarmount/tests/create-tests.sh"
    # alias does not work: alias tarc='tar -c --owner=user --group=group --numeric'
    function tarc() { tar -c --owner=user --group=group --numeric "\$@"; }
    function npm() { echo "ignoring: npm \$@"; }
    function npx() { echo "ignoring: npx \$@"; }
    function wget() { echo "ignoring: wget \$@"; }
    # FIXME this path is still mounted
    # /tmp/ratarmount-test.*/ratarmount/momo
    set +e # fails at: tar -x -f single-file.tar
    set -e; set -x # debug
    cd tests
    . create-tests.sh
    cd ..
    set -e
    fi

    # no. this breaks tests
    # cd tests; pytest "\$@"

    printf ">"; printf " %q" pytest tests/ "\$@"; printf "\n"
    exec pytest tests/ "\$@"
    EOF
    chmod +x $out/bin/ratarmount-test
  '';
}
