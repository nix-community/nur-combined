/** Privacy-preserving aggregate telemetry. */
#pragma once

#include <memory>

namespace telemetry {
  struct deinit_t {
    ~deinit_t();
  };

  [[nodiscard]] std::unique_ptr<deinit_t> start();
}
