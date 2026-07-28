#include "inputmapper.h"

#define KEY_COUNT (3)

const int32_t numpad_keys[KEY_COUNT] = {
  KEY_LEFTSHIFT, KEY_LEFTALT, KEY_LEFTCTRL,
};

const int32_t replacement_keys[KEY_COUNT] = {
  KEY_LEFTSHIFT, KEY_LEFTALT, KEY_LEFTCTRL,
};

bool process_event(struct input_event& event) {
  if (event.type == EV_KEY) {
    for (int i = 0; i < KEY_COUNT; i++) {
      if (event.code == numpad_keys[i]) {
        int32_t replacement_code = replacement_keys[i];
        if (replacement_code == 0) {
          return false;
        } else {
          event.code = replacement_code;
        }
        break;
      }
    }
  }
  return true;
}
