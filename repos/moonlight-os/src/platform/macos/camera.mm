#include "src/platform/common.h"

namespace platf {
  bool virtual_camera_available() {
    return false;
  }

  std::unique_ptr<virtual_camera_t> virtual_camera() {
    return nullptr;
  }

  bool virtual_display_topology_available() {
    return false;
  }

  std::unique_ptr<virtual_display_topology_t> virtual_display_topology() {
    return nullptr;
  }
}
