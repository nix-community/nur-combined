#include "inputmapper.h"

bool process_event(struct input_event& event) {
  if (event.type != EV_KEY)
    return true;
  switch (event.code) {
    case KEY_LEFTMETA:  event.code = KEY_LEFTALT;   break;
    case KEY_LEFTALT:   event.code = KEY_LEFTMETA;  break;
    case KEY_RIGHTMETA: event.code = KEY_RIGHTALT;  break;
    case KEY_RIGHTALT:  event.code = KEY_RIGHTMETA; break;
  }
  return true;
}
