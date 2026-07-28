#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <errno.h>
#include <linux/input.h>

#define EXIT_ERROR_READ ((int)1)
#define EXIT_ERROR_WRITE ((int)2)
#define EXIT_ERROR_ARGS ((int)3)

bool process_event(struct input_event& event);

int main(int argc, char** argv) {
  struct input_event ev;

  if (argc != 1) {
    fprintf(stderr, "no args accepted\n");
    exit(EXIT_ERROR_ARGS);
  }
  (void)argv;

  setbuf(stdin, NULL);
  setbuf(stdout, NULL);
  while(1) {
    size_t count_events = fread(&ev, sizeof(ev), 1, stdin);
    if (count_events != 1) {
      if (feof(stdin)) {
        return 0;
      } else {
        perror("Failed to read from stdin");
        return EXIT_ERROR_READ;
      }
    }

    if (process_event(ev)) {
      size_t write_res = fwrite(&ev, sizeof(ev), 1, stdout);
      if (write_res != 1) {
        if (feof(stdout)) {
          return 0;
        } else {
          perror("Failed to write to stdout");
          return EXIT_ERROR_WRITE;
        }
      }
    }
  }
}
