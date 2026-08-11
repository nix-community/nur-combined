pseudo 1.9.0 fails to build

In file included from port_wrappers.c:3,
                 from pseudo_wrappers.c:307:
ports/linux/pseudo_wrappers.c: In function 'pseudo_stat':
ports/linux/pseudo_wrappers.c:7:29: error: '_STAT_VER' undeclared (first use in this function)
    7 |         return real___xstat(_STAT_VER, path, buf);
      |                             ^~~~~~~~~



note: $PSEUDO_LOCALSTATEDIR must be writable
by default $PSEUDO_LOCALSTATEDIR is the read-only $out/var/pseudo

note: $PSEUDO_PREFIX/lib/libpseudo.so must exist
by default $PSEUDO_PREFIX is $out
if more files are needed in $PSEUDO_PREFIX
then a temporary prefix ("env") must be created with symlinks
see also: symlinkJoin or lndir or "cp -s"



/*
    # dont create $out/var/pseudo
    substituteInPlace Makefile.in \
      --replace-fail \
        'install: all install-lib install-bin install-data' \
        'install: all install-lib install-bin'
*/

/*
FIXME still deadloop

https://bugzilla.yoctoproject.org/show_bug.cgi?id=15497
read-only PSEUDO_LOCALSTATEDIR should be fatal error

$ ./result/bin/pseudo
Warning: PSEUDO_PREFIX unset, defaulting to /home/user/src/milahu/nur-packages/./result.
help: can't open log file /home/user/src/milahu/nur-packages/./result/var/pseudo/pseudo.log: Read-only file system
help: can't open log file /home/user/src/milahu/nur-packages/./result/var/pseudo/pseudo.log: Read-only file system
help: can't open log file /home/user/src/milahu/nur-packages/./result/var/pseudo/pseudo.log: Read-only file system
help: can't open log file /home/user/src/milahu/nur-packages/./result/var/pseudo/pseudo.log: Read-only file system
help: can't open log file /home/user/src/milahu/nur-packages/./result/var/pseudo/pseudo.log: Read-only file system
help: can't open log file /home/user/src/milahu/nur-packages/./result/var/pseudo/pseudo.log: Read-only file system
-> pseudo-1.9.0/pseudo_util.c:             pseudo_diag("help: can't open log file %s: %s\n", pseudo_path, strerror(errno));

this works
$ PSEUDO_LOCALSTATEDIR=/a/b/c/d/e ./result/bin/pseudo
Warning: PSEUDO_PREFIX unset, defaulting to /home/user/src/milahu/nur-packages/./result.
Can't open local state path '/a/b/c/d/e': No such file or directory
-> pseudo-1.9.0/pseudo_client.c:                           pseudo_diag("Can't open local state path '%s': %s\n",
*/
