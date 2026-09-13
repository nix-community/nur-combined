#include "telemetry.h"

#include "config.h"
#include "platform/common.h"

#include <chrono>
#include <curl/curl.h>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <nlohmann/json.hpp>
#include <string>
#include <string_view>
#include <thread>

#ifndef TELEMETRY_URL
  #define TELEMETRY_URL ""
#endif

namespace telemetry {
  namespace {
    namespace fs = std::filesystem;

    fs::path state_path() {
      return platf::appdata() / "telemetry-state.json";
    }

    std::string utc_day() {
      const auto now = std::chrono::system_clock::to_time_t(std::chrono::system_clock::now());
      std::tm utc {};
#ifdef _WIN32
      gmtime_s(&utc, &now);
#else
      gmtime_r(&now, &utc);
#endif
      char result[11] {};
      std::strftime(result, sizeof(result), "%Y-%m-%d", &utc);
      return result;
    }

    std::string os_name() {
#ifdef _WIN32
      return "windows";
#elif defined(__APPLE__)
      return "macos";
#elif defined(__linux__)
      return "linux";
#else
      return "unknown";
#endif
    }

    std::string arch_name() {
#if defined(__x86_64__) || defined(_M_X64)
      return "amd64";
#elif defined(__aarch64__) || defined(_M_ARM64)
      return "arm64";
#elif defined(__i386__) || defined(_M_IX86)
      return "386";
#elif defined(__arm__) || defined(_M_ARM)
      return "arm";
#else
      return "unknown";
#endif
    }

    nlohmann::json read_state() {
      try {
        std::ifstream input(state_path());
        if (input) {
          return nlohmann::json::parse(input);
        }
      } catch (...) {
      }
      return nlohmann::json::object();
    }

    void write_state(const nlohmann::json &state) {
      try {
        fs::create_directories(state_path().parent_path());
        std::ofstream output(state_path(), std::ios::trunc);
        output << state.dump() << '\n';
      } catch (...) {
      }
    }

    size_t discard_response(char *, size_t size, size_t count, void *) {
      return size * count;
    }

    void post(nlohmann::json event) {
      std::string base = TELEMETRY_URL;
      if (!base.starts_with("https://")) {
        return;
      }
      while (base.ends_with('/')) {
        base.pop_back();
      }
      const std::string url = base + "/api/v1/events";
      const std::string body = event.dump();
      std::thread([url, body] {
        CURL *curl = curl_easy_init();
        if (!curl) {
          return;
        }
        curl_slist *headers = curl_slist_append(nullptr, "Content-Type: application/json");
        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, body.c_str());
        curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, static_cast<long>(body.size()));
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, discard_response);
        curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT_MS, 3000L);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT_MS, 5000L);
        curl_easy_setopt(curl, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1_2);
        curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1L);
#if LIBCURL_VERSION_NUM >= 0x075500
        curl_easy_setopt(curl, CURLOPT_PROTOCOLS_STR, "https");
        curl_easy_setopt(curl, CURLOPT_REDIR_PROTOCOLS_STR, "https");
#else
        curl_easy_setopt(curl, CURLOPT_PROTOCOLS, CURLPROTO_HTTPS);
        curl_easy_setopt(curl, CURLOPT_REDIR_PROTOCOLS, CURLPROTO_HTTPS);
#endif
#ifdef _WIN32
        curl_easy_setopt(curl, CURLOPT_SSL_OPTIONS, CURLSSLOPT_NATIVE_CA);
#endif
        (void) curl_easy_perform(curl);
        curl_slist_free_all(headers);
        curl_easy_cleanup(curl);
      }).detach();
    }

    nlohmann::json base_event(std::string kind) {
      return {
        {"project", "helios"},
        {"version", PROJECT_VERSION},
        {"os", os_name()},
        {"arch", arch_name()},
        {"kind", std::move(kind)},
      };
    }

    void mark_clean() {
      auto state = read_state();
      state["running"] = false;
      write_state(state);
    }
  }

  std::unique_ptr<deinit_t> start() {
    if (std::string_view(TELEMETRY_URL).empty()) {
      return nullptr;
    }
    auto state = read_state();
    const bool previous_run_was_unclean = state.value("running", false);
    const std::string today = utc_day();

    state["running"] = config::helios.crash_reporting_enabled;
    if (config::helios.telemetry_enabled && state.value("last_launch_day", std::string {}) != today) {
      state["last_launch_day"] = today;
      post(base_event("launch"));
    }
    if (config::helios.crash_reporting_enabled && previous_run_was_unclean) {
      auto crash = base_event("crash");
      crash["crash"] = {{"reason", "unclean-exit"}};
      post(std::move(crash));
    }
    write_state(state);
    return std::make_unique<deinit_t>();
  }

  deinit_t::~deinit_t() {
    mark_clean();
  }
}
