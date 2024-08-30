#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {

  int fd;
  char c[10];
  char buffer[10];
  int pid;
  //char pid_str[20] = argv[1];
  //printf("hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii: %s\n", pid_str);
  printf("pid_str: %s \n", argv[1]);
  printf("argc: %d \n", argc);

  sscanf(argv[1], "%d", &pid);
  printf("pid: %d \n", pid);

  fd = open("/dev/unkillable", O_RDWR);
  if (fd < 0)
    printf("Error opening /dev/unkillable\n");

  printf("Opened /dev/unkillable\n");
  read(fd, &c, pid);
  //printf("We are now unkillable!\n");
  //read(STDIN_FILENO, buffer, 10);
  //printf("exiting on user input...\n");

  return 0;

}
