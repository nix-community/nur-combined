#include "src/platform/common.h"

#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

#include <algorithm>
#include <array>
#include <cerrno>
#include <cstdlib>
#include <cstring>
#include <format>
#include <optional>
#include <set>

#include <nlohmann/json.hpp>

#include "src/logging.h"

using namespace std::literals;

namespace platf {
  namespace {
    std::optional<std::string> run_swaymsg(const std::vector<std::string> &arguments) {
      int pipefd[2];
      if (pipe(pipefd) != 0) return std::nullopt;
      auto pid = fork();
      if (pid < 0) {
        close(pipefd[0]);
        close(pipefd[1]);
        return std::nullopt;
      }
      if (pid == 0) {
        dup2(pipefd[1], STDOUT_FILENO);
        dup2(pipefd[1], STDERR_FILENO);
        close(pipefd[0]);
        close(pipefd[1]);
        std::vector<char *> argv;
        argv.reserve(arguments.size() + 2);
        argv.push_back(const_cast<char *>("swaymsg"));
        for (const auto &argument : arguments) {
          argv.push_back(const_cast<char *>(argument.c_str()));
        }
        argv.push_back(nullptr);
        execvp("swaymsg", argv.data());
        _exit(127);
      }
      close(pipefd[1]);
      std::string output;
      std::array<char, 4096> buffer;
      for (;;) {
        auto count = read(pipefd[0], buffer.data(), buffer.size());
        if (count > 0) output.append(buffer.data(), (std::size_t) count);
        else if (count < 0 && errno == EINTR) continue;
        else break;
      }
      close(pipefd[0]);
      int status = 0;
      while (waitpid(pid, &status, 0) < 0 && errno == EINTR) {}
      if (!WIFEXITED(status) || WEXITSTATUS(status) != 0) return std::nullopt;
      return output;
    }

    std::set<std::string> headless_outputs() {
      auto output = run_swaymsg({"-r", "-t", "get_outputs"});
      if (!output) return {};
      try {
        auto json = nlohmann::json::parse(*output);
        std::set<std::string> names;
        for (const auto &item : json) {
          auto name = item.value("name", "");
          if (name.starts_with("HEADLESS-")) names.insert(std::move(name));
        }
        return names;
      } catch (const std::exception &e) {
        BOOST_LOG(warning) << "Could not parse sway outputs for virtual displays: "sv << e.what();
        return {};
      }
    }

    bool command_succeeded(const std::vector<std::string> &arguments) {
      auto output = run_swaymsg(arguments);
      if (!output) return false;
      try {
        auto json = nlohmann::json::parse(*output);
        return json.is_array() && !json.empty() && json[0].value("success", false);
      } catch (...) {
        return false;
      }
    }

    class sway_topology_t final: public virtual_display_topology_t {
    public:
      ~sway_topology_t() override {
        for (const auto &name : owned_) command_succeeded({"output", name, "disable"});
      }

      bool apply(const std::vector<client_display_t> &displays) override {
        if (displays.empty() || std::getenv("SWAYSOCK") == nullptr) return false;
        while (owned_.size() < displays.size()) {
          auto before = headless_outputs();
          if (!command_succeeded({"create_output"})) return false;
          auto after = headless_outputs();
          std::vector<std::string> created;
          std::set_difference(after.begin(), after.end(), before.begin(), before.end(),
                              std::back_inserter(created));
          if (created.size() != 1) return false;
          owned_.push_back(std::move(created.front()));
        }
        for (std::size_t i = 0; i < owned_.size(); ++i) {
          if (i >= displays.size()) {
            command_succeeded({"output", owned_[i], "disable"});
            continue;
          }
          const auto &display = displays[i];
          auto mode = std::format("{}x{}@{:.3f}Hz", display.width, display.height,
                                  display.refresh_millihz / 1000.0);
          auto scale = std::format("{:.3f}", display.scale_milli / 1000.0);
          if (!command_succeeded({"output", owned_[i], "enable", "mode", mode,
                                  "pos", std::to_string(display.x), std::to_string(display.y),
                                  "scale", scale})) {
            return false;
          }
        }
        active_count_ = displays.size();
        return true;
      }

      std::vector<std::string> display_names() const override {
        return std::vector<std::string>(owned_.begin(),
                                        owned_.begin() + (std::ptrdiff_t) active_count_);
      }

    private:
      std::vector<std::string> owned_;
      std::size_t active_count_ = 0;
    };
  }

  bool virtual_display_topology_available() {
    return std::getenv("SWAYSOCK") != nullptr;
  }

  std::unique_ptr<virtual_display_topology_t> virtual_display_topology() {
    if (!virtual_display_topology_available()) return nullptr;
    return std::make_unique<sway_topology_t>();
  }
}
