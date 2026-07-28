#include "inputmapper.h"

bool process_event(struct input_event& event) {
  if (event.type == EV_KEY && event.code == KEY_COMPOSE)
      event.code = KEY_RIGHTMETA;
  return true;
}
  
