#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <linux/elf.h>
#include <sys/ptrace.h>
#include <sys/random.h>
#include <sys/syscall.h>
#include <sys/uio.h>
#include <sys/user.h>
#include <sys/wait.h>
#include <unistd.h>

#define LOG(...)                                                               \
  do {                                                                         \
    fprintf(stderr, "ptrace-wrapper:%d : ", __LINE__);                         \
    fprintf(stderr, __VA_ARGS__);                                              \
    fputc('\n', stderr);                                                       \
  } while (0)

#define FATAL(...)                                                             \
  do {                                                                         \
    LOG(__VA_ARGS__);                                                          \
    exit(EXIT_FAILURE);                                                        \
  } while (0)

/* see syscall(2) */
#if defined(__x86_64__) || defined(__i386__)

#define R_SYSCALL(r) (r.orig_rax)
#define R_ARG1(r) (r.rdi)
#define R_ARG2(r) (r.rsi)
#define R_ARG3(r) (r.rdx)
#define R_ARG4(r) (r.r10)
#define R_ARG5(r) (r.r8)
#define R_ARG6(r) (r.r9)

#elif defined(__aarch64__)

#define R_SYSCALL(r) (r.regs[8])
#define R_ARG1(r) (r.regs[0])
#define R_ARG2(r) (r.regs[1])
#define R_ARG3(r) (r.regs[2])
#define R_ARG4(r) (r.regs[3])
#define R_ARG5(r) (r.regs[4])
#define R_ARG6(r) (r.regs[5])

#endif

int main(int argc, char **argv) {
  if (argc <= 1)
    FATAL("too few arguments");

  int wstatus;
  struct user_regs_struct uregs;
  struct iovec iov = {.iov_base = &uregs, .iov_len = sizeof(uregs)};
  pid_t pid = fork();

  switch (pid) {
  case -1: /* error */
    FATAL("%s", strerror(errno));
  case 0: /* child */
    ptrace(PTRACE_TRACEME, 0, 0, 0);
    execvp(argv[1], argv + 1);
    FATAL("%s", strerror(errno));
  }

  /* parent */

  if (wait(&wstatus) == -1) {
    FATAL("%s", strerror(errno));
  }
  if (WIFEXITED(wstatus)) {
    exit(WEXITSTATUS(wstatus));
  }

  ptrace(PTRACE_SETOPTIONS, pid, 0,
         PTRACE_O_TRACEFORK | PTRACE_O_TRACEEXEC | PTRACE_O_EXITKILL);

  while (1) {
    if (ptrace(PTRACE_SYSCALL, pid, 0, 0) == -1) {
      FATAL("%s", strerror(errno));
    }
    if (wait(&wstatus) == -1) {
      FATAL("%s", strerror(errno));
    }
    if (WIFEXITED(wstatus)) {
      exit(WEXITSTATUS(wstatus));
    }

    ptrace(PTRACE_GETREGSET, pid, NT_PRSTATUS, &iov);
    if (R_SYSCALL(uregs) == SYS_getrandom && R_ARG3(uregs) == 0) {
      LOG("forcing syscall getreandom(__BUFFER__, %llu, %llu) to non-blocking",
          R_ARG2(uregs), R_ARG3(uregs));

      R_ARG3(uregs) = GRND_NONBLOCK;
      if (ptrace(PTRACE_SETREGSET, pid, NT_PRSTATUS, &iov) == -1)
        FATAL("%s", strerror(errno));
    }
  }
}
