{
  stdenv,
}:

stdenv.mkDerivation {
  pname = "test-fchmodat2";
  version = "0.0.1";
  src = ./test-fchmodat2.c;
  buildCommand = ''
    set -x
    touch testfile1
    mkdir testdir2
    mkdir subdir
    touch subdir/testfile3
    mkdir subdir/testdir4
    chmod 0777 testfile1 testdir2 subdir/testfile3 subdir/testdir4
    stat -c '%a %n' testfile1 testdir2 subdir/testfile3 subdir/testdir4
    cp $src test-fchmodat2.c
    gcc -o test-fchmodat2 test-fchmodat2.c
    ./test-fchmodat2
    stat -c '%a %n' testfile1 testdir2 subdir/testfile3 subdir/testdir4
    set +x
    exit 1 # make the build fail
  '';
}
