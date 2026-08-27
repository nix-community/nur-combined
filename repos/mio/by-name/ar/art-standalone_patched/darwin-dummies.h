#ifdef __APPLE__
#define stat64 stat
#define lstat64 lstat
#define fstat64 fstat
#define st_atim st_atimespec
#define st_mtim st_mtimespec
#define st_ctim st_ctimespec
struct ucred { int pid; int uid; int gid; };
struct sockaddr_nl { int nl_family; int nl_pid; int nl_groups; };
struct sockaddr_ll { int sll_family; int sll_protocol; int sll_ifindex; int sll_hatype; int sll_pkttype; int sll_halen; char sll_addr[8]; };
struct __user_cap_header_struct { int version; int pid; };
struct __user_cap_data_struct { int effective; int permitted; int inheritable; };

#define flock64 flock
#define fdatasync fsync
#define ftruncate64 ftruncate
#define lseek64 lseek
#define mmap64 mmap
#define pipe2(fds, flags) pipe(fds)
#define capget(h, d) -1
#define capset(h, d) -1
#define __NR_gettid 0
#define getxattr(p, n, v, s) -1
#define listxattr(p, l, s) -1
#define removexattr(p, n) -1
#define setxattr(p, n, v, s, f) -1
#define fgetxattr(fd, n, v, s) -1
#define flistxattr(fd, l, s) -1
#define fremovexattr(fd, n) -1
#define fsetxattr(fd, n, v, s, f) -1
#define mincore(addr, length, vec) mincore((const void*)addr, length, (char*)vec)
#define splice(fd_in, off_in, fd_out, off_out, len, flags) -1
#define sendfile(out_fd, in_fd, offset, count) -1
#define prctl(option, arg2, arg3, arg4, arg5) -1

#include <sys/types.h>
#include <sys/socket.h>

#endif
