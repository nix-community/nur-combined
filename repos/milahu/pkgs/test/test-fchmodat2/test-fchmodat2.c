// https://stackoverflow.com/questions/30290585/how-do-i-make-syscalls-from-my-c-program
// https://cm-gitlab.stanford.edu/ntonnatt/linux/-/blob/master/tools/testing/selftests/fchmodat2/fchmodat2_test.c?ref_type=heads
// https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=09da082b07bbae1c11d9560c8502800039aebcea
// https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=78252deb023cf0879256fcfbafe37022c390762b

#define _GNU_SOURCE
#include <fcntl.h> // __NR_fchmodat2
#include <sys/stat.h>
#include <sys/types.h>
//#include <sys/syscall.h>
#include <syscall.h> // SYS_fchmodat
#include <unistd.h>
#include <stdio.h>
#include <dirent.h> // opendir

// force compilation with old headers
#ifndef __NR_fchmodat2
#define __NR_fchmodat2 452
#endif
#ifndef SYS_fchmodat2
#define SYS_fchmodat2 452
#endif

int sys_fchmodat2(int dfd, const char *filename, mode_t mode, int flags)
{
	//int ret = syscall(__NR_fchmodat2, dfd, filename, mode, flags);
	int ret = syscall(SYS_fchmodat2, dfd, filename, mode, flags);

	// FIXME what is errno
	//return ret >= 0 ? ret : -errno;
	return ret;
}

int
main(int argc, char *argv[])
{
	int dfd, ret;
	DIR *dirp;

	// file is in workdir
	//dfd = AT_FDCWD;

	// TODO create testfile1
	//nc::AT_FDCWD, filename, 0o600, nc::AT_SYMLINK_NOFOLLOW as u32
	//ret = syscall(SYS_fchmodat2, fd, file, mode, flag);
	ret = sys_fchmodat2(AT_FDCWD, "testfile1", 0600, AT_SYMLINK_NOFOLLOW);
	printf("test 1: path = 'testfile1', fchmodat2 res = %d\n", ret);

	// TODO create testdir2
	ret = sys_fchmodat2(AT_FDCWD, "testdir2", 0600, AT_SYMLINK_NOFOLLOW);
	printf("test 2: path = 'testdir2', fchmodat2 res = %d\n", ret);

	// use dfd != AT_FDCWD
	// DIR *opendir(const char *name);
	dirp = opendir("subdir");
	if (dirp == NULL) {
		printf ("Cannot open directory 'subdir'\n");
		return 1;
	}
	// int dirfd(DIR *dirp);
	dfd = dirfd(dirp);

	// TODO create subdir/testfile3
	ret = sys_fchmodat2(dfd, "testfile3", 0600, AT_SYMLINK_NOFOLLOW);
	printf("test 3: path = 'subdir/testfile3', fchmodat2 res = %d\n", ret);

	// TODO create subdir/testdir4
	ret = sys_fchmodat2(dfd, "testdir4", 0600, AT_SYMLINK_NOFOLLOW);
	printf("test 3: path = 'subdir/testdir4', fchmodat2 res = %d\n", ret);

	// int closedir(DIR *dirp);
	closedir(dirp);

	return 0;
}
