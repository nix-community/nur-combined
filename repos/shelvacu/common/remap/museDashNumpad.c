#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <linux/input.h>

#define KEY_COUNT (18)

const int32_t numpad_keys[KEY_COUNT] = {
  KEY_NUMLOCK, KEY_KPSLASH, KEY_KPASTERISK, KEY_KPMINUS,
  KEY_KP7,     KEY_KP8,     KEY_KP9,    KEY_KPPLUS,
  KEY_KP4,     KEY_KP5,     KEY_KP6,    KEY_BACKSPACE,
  KEY_KP1,     KEY_KP2,     KEY_KP3,    KEY_KPENTER,
  KEY_KP0,     /* KP0, */   KEY_KPDOT,  /* KPENTER, */
};

const int32_t replacement_keys[KEY_COUNT] = {
  // top row unused
  0, 0, 0, 0,
#ifdef SIDE_LEFT
  KEY_Q, KEY_W, KEY_E, KEY_R,
  KEY_A, KEY_S, KEY_D, KEY_F,
#else
  KEY_U, KEY_I, KEY_O, KEY_P,
  KEY_J, KEY_K, KEY_L, KEY_SEMICOLON,
#endif
  // 4th row unused
  0, 0, 0, 0,
  KEY_ENTER, /* X, */ KEY_ESC, /* X, */
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
