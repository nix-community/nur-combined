#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <linux/input.h>

#define KEY_COUNT (3)

const int32_t numpad_keys[KEY_COUNT] = {
  KEY_LEFTSHIFT, KEY_LEFTALT, KEY_LEFTCTRL,
};

const int32_t replacement_keys[KEY_COUNT] = {
  KEY_LEFTSHIFT, KEY_LEFTALT, KEY_LEFTCTRL,
};

int main(void) {
  setbuf(stdin, NULL), setbuf(stdout, NULL);

  struct input_event event;

  while (fread(&event, sizeof(event), 1, stdin) == 1) {
    bool write_event = true;
    if (event.type == EV_KEY) {
      for (int i = 0; i < KEY_COUNT; i++) {
        if (event.code == numpad_keys[i]) {
          int32_t replacement_code = replacement_keys[i];
          if (replacement_code == 0) {
            write_event = false;
          } else {
            event.code = replacement_code;
          }
          break;
        }
      }
    }

    if (write_event)
      fwrite(&event, sizeof(event), 1, stdout);
  }
}
