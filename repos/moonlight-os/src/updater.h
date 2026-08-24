/**
 * @file src/updater.h
 * @brief Signed, staged application updates.
 */
#pragma once

#include <cstdint>
#include <nlohmann/json.hpp>
#include <optional>
#include <string>
#include <string_view>

namespace updater {
  struct version_t {
    std::uint64_t major {};
    std::uint64_t minor {};
    std::uint64_t patch {};
    bool prerelease {};
    std::string prerelease_label;
  };

  std::optional<version_t> parse_version(std::string_view value);
  int compare_versions(const version_t &left, const version_t &right);
  bool verify_ed25519(
    std::string_view public_key_pem,
    std::string_view message,
    std::string_view signature
  );

  nlohmann::json status();
  bool begin_check(bool include_prereleases, std::string &error);
  bool begin_install(std::uint16_t health_port, std::string &error);
}  // namespace updater
