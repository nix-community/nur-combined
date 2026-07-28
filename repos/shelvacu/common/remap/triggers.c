#include "inputmapper.h"

bool process_event(struct input_event& event) {
  if (event.type == EV_ABS) {
    if (event.code == ABS_GAS) {
      event.value = 128 + (event.value / 2);
    } else if (event.code == ABS_BRAKE) {
      event.code = ABS_GAS;
      event.value = 128 - (event.value / 2);
      if (event.value == 1)
        event.value = 0;
    }
  }
  return true;
}
