/**
 * @file src/usb_compat.h
 * @brief One-release migration notice for the retired host-utils listener.
 */
#pragma once

#include <cstdint>
#include <memory>

#include "platform/common.h"

namespace usb_compat {
  std::unique_ptr<platf::deinit_t> start(std::uint16_t port = 48020);
}
