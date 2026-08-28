#ifndef _SYS_EPOLL_H
#define _SYS_EPOLL_H
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef union epoll_data {
  void *ptr;
  int fd;
  uint32_t u32;
  uint64_t u64;
} epoll_data_t;
struct epoll_event {
  uint32_t events;
  epoll_data_t data;
};
#define EPOLLIN 1
#define EPOLLWAKEUP 2
#define EPOLLOUT 4
#define EPOLLERR 8
#define EPOLLHUP 16
#define EPOLL_CTL_ADD 1
#define EPOLL_CTL_DEL 2
#define EPOLL_CTL_MOD 3
#define EPOLL_CLOEXEC 0
static inline int epoll_create(int size) {
  return -1;
}
static inline int epoll_create1(int flags) {
  return -1;
}
static inline int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event) {
  return -1;
}
static inline int epoll_wait(
    int epfd, struct epoll_event *events, int maxevents, int timeout) {
  return -1;
}
#ifdef __cplusplus
}
#endif
#endif
