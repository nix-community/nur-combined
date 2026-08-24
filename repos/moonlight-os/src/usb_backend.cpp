/**
 * @file src/usb_backend.cpp
 * @brief USB/IP client backend absorbed from the mlos-host-utils prototype.
 */
#ifndef BOOST_PROCESS_VERSION
  #define BOOST_PROCESS_VERSION 1
#endif

#include <algorithm>
#include <chrono>
#include <condition_variable>
#include <cstdlib>
#include <filesystem>
#include <mutex>
#include <optional>
#include <regex>
#include <thread>

#include <boost/process/v1.hpp>
#include <nlohmann/json.hpp>

#ifdef _WIN32
  #include <windows.h>
#endif

#ifdef __linux__
  #include <cerrno>
  #include <cstddef>
  #include <cstring>
  #include <grp.h>
  #include <sys/socket.h>
  #include <sys/stat.h>
  #include <sys/un.h>
  #include <sys/utsname.h>
  #include <unistd.h>
#endif

#include "logging.h"
#include "stream.h"
#include "usb_backend.h"

namespace stream {
  namespace bp = boost::process::v1;
  using namespace std::chrono_literals;
  using namespace std::literals;

#ifdef __linux__
  constexpr std::string_view usb_helper_socket_path = "/run/helios/usb-helper.sock"sv;
  constexpr std::size_t usb_helper_max_request = 64 * 1024;
  constexpr std::string_view usb_helper_group = "video"sv;

  static sockaddr_un usb_helper_address(socklen_t &length) {
    sockaddr_un address {};
    address.sun_family = AF_UNIX;
    std::memcpy(address.sun_path, usb_helper_socket_path.data(), usb_helper_socket_path.size());
    address.sun_path[usb_helper_socket_path.size()] = '\0';
    length = static_cast<socklen_t>(offsetof(sockaddr_un, sun_path) + usb_helper_socket_path.size() + 1);
    return address;
  }
#endif

  std::vector<usb_import_t> parse_usbip_port_table(std::string_view output) {
    static const std::regex port_re {R"(^\s*Port\s+([0-9]+)\s*:)"};
    static const std::regex import_re {R"(usbip://(\[[^\]]+\]|[^:/\s]+)(?::([0-9]+))?/(\S+))"};
    std::vector<usb_import_t> imports;
    int current_port = -1;
    std::size_t at = 0;
    while (at <= output.size()) {
      auto end = output.find('\n', at);
      if (end == std::string_view::npos) end = output.size();
      std::string line {output.substr(at, end - at)};
      std::smatch match;
      if (std::regex_search(line, match, port_re)) {
        try {
          current_port = std::stoi(match[1].str());
        } catch (...) {
          current_port = -1;
        }
      } else if (current_port >= 0 && std::regex_search(line, match, import_re)) {
        usb_import_t item;
        item.port = current_port;
        item.server = match[1].str();
        if (item.server.size() >= 2 && item.server.front() == '[' && item.server.back() == ']') {
          item.server = item.server.substr(1, item.server.size() - 2);
        }
        if (match[2].matched) {
          try {
            auto parsed = std::stoul(match[2].str());
            if (parsed == 0 || parsed > 65535) throw std::out_of_range("USB/IP port");
            item.server_port = (std::uint16_t) parsed;
          } catch (...) {
            current_port = -1;
            if (end == output.size()) break;
            at = end + 1;
            continue;
          }
        }
        item.busid = match[3].str();
        imports.emplace_back(std::move(item));
        current_port = -1;
      }
      if (end == output.size()) break;
      at = end + 1;
    }
    return imports;
  }

  std::vector<std::string> usbip_attach_args(std::uint16_t proxy_port, std::string_view busid) {
    // usbip-win2 parses --tcp-port as a global option, so it must precede the
    // subcommand. Linux usbip accepts the same canonical ordering.
    return {"--tcp-port", std::to_string(proxy_port), "attach", "-r", "127.0.0.1", "-b",
            std::string(busid)};
  }

  static bool valid_target_iqn(std::string_view iqn) {
    static const std::regex iqn_re {R"(^iqn\.[a-z0-9.-]{1,180}:[a-z0-9.:-]{1,180}$)"};
    return iqn.size() <= 223 && std::regex_match(iqn.begin(), iqn.end(), iqn_re);
  }

  std::vector<std::vector<std::string>> iscsiadm_detach_plan(
    std::uint16_t proxy_port, std::string_view target_iqn) {
    auto portal = "127.0.0.1:" + std::to_string(proxy_port);
    auto base = std::vector<std::string> {"-m", "node", "-T", std::string(target_iqn), "-p", portal};
    auto logout = base;
    logout.push_back("--logout");
    auto remove = base;
    remove.insert(remove.end(), {"--op", "delete"});
    return {std::move(logout), std::move(remove)};
  }

  std::vector<std::vector<std::string>> iscsiadm_attach_plan(
    std::uint16_t proxy_port, std::string_view target_iqn) {
    auto portal = "127.0.0.1:" + std::to_string(proxy_port);
    auto base = std::vector<std::string> {"-m", "node", "-T", std::string(target_iqn), "-p", portal};
    auto create = base;
    create.insert(create.end(), {"--op", "new"});
    auto manual = base;
    manual.insert(manual.end(), {"--op", "update", "-n", "node.startup", "-v", "manual"});
    auto login = base;
    login.push_back("--login");
    return {std::move(create), std::move(manual), std::move(login)};
  }

  std::string windows_iscsi_attach_script(
    std::uint16_t proxy_port, std::string_view target_iqn) {
    if (proxy_port < 1024 || !valid_target_iqn(target_iqn)) return {};
    auto port = std::to_string(proxy_port);
    auto iqn = std::string(target_iqn);
    return "$portal = Get-IscsiTargetPortal -TargetPortalAddress '127.0.0.1' "
           "-TargetPortalPortNumber " + port + " -ErrorAction SilentlyContinue; "
           "if (-not $portal) { New-IscsiTargetPortal -TargetPortalAddress '127.0.0.1' "
           "-TargetPortalPortNumber " + port + " -ErrorAction Stop | Out-Null }; "
           "Connect-IscsiTarget -NodeAddress '" + iqn + "' "
           "-TargetPortalAddress '127.0.0.1' -TargetPortalPortNumber " + port + " "
           "-IsPersistent $false -ReportToPnP $true -ErrorAction Stop | Out-Null";
  }

  std::string windows_iscsi_detach_script(
    std::uint16_t proxy_port, std::string_view target_iqn) {
    if (proxy_port < 1024 || !valid_target_iqn(target_iqn)) return {};
    auto port = std::to_string(proxy_port);
    auto iqn = std::string(target_iqn);
    return "$iscsicli = Join-Path $env:SystemRoot 'System32\\iscsicli.exe'; "
           // Disconnect-IscsiTarget can strand an unusable disconnected
           // session on Windows 10. Log out the exact session natively while
           // it is still connected, then verify that it has actually gone.
           "for ($attempt = 0; $attempt -lt 8; $attempt++) { "
           "$sessions = @(Get-IscsiSession -ErrorAction SilentlyContinue | "
           "Where-Object { $_.TargetNodeAddress -eq '" + iqn + "' }); "
           "if ($sessions.Count -eq 0) { break }; "
           "foreach ($session in $sessions) { & $iscsicli LogoutTarget "
           "$session.SessionIdentifier | Out-Null }; "
           "Start-Sleep -Milliseconds 250 }; "
           "$sessions = @(Get-IscsiSession -ErrorAction SilentlyContinue | "
           "Where-Object { $_.TargetNodeAddress -eq '" + iqn + "' }); "
           "if ($sessions.Count -ne 0) { throw 'iSCSI session remained after logout' }; "
           "$portal = Get-IscsiTargetPortal -TargetPortalAddress '127.0.0.1' "
           "-TargetPortalPortNumber " + port + " -ErrorAction SilentlyContinue; "
           // The Windows 10 storage provider rejects the custom-port parameter
           // of Remove-IscsiTargetPortal and doesn't implement CIM deletion.
           // iscsicli's full form accepts the exact address+socket pair, unlike
           // its quick form (which is fixed to the default port).
           "if ($portal) { & $iscsicli RemoveTargetPortal "
           "'127.0.0.1' " + port + " | Out-Null; "
           "if ($LASTEXITCODE -ne 0) { throw 'iscsicli RemoveTargetPortal failed' }; "
           "Start-Sleep -Milliseconds 250 }; "
           "$portal = Get-IscsiTargetPortal -TargetPortalAddress '127.0.0.1' "
           "-TargetPortalPortNumber " + port + " -ErrorAction SilentlyContinue; "
           "if ($portal) { throw 'iSCSI target portal remained after removal' }";
  }

  std::string windows_iscsi_detached_script(
    std::uint16_t proxy_port, std::string_view target_iqn) {
    if (proxy_port < 1024 || !valid_target_iqn(target_iqn)) return {};
    auto port = std::to_string(proxy_port);
    auto iqn = std::string(target_iqn);
    return "$sessions = @(Get-IscsiSession -ErrorAction SilentlyContinue | "
           "Where-Object { $_.TargetNodeAddress -eq '" + iqn + "' }); "
           "$portal = Get-IscsiTargetPortal -TargetPortalAddress '127.0.0.1' "
           "-TargetPortalPortNumber " + port + " -ErrorAction SilentlyContinue; "
           "if ($sessions.Count -ne 0) { throw 'iSCSI session remains' }; "
           "if ($portal) { throw 'iSCSI target portal remains' }";
  }

  static std::optional<std::filesystem::path> find_usbip() {
    std::vector<std::filesystem::path> candidates;
#ifdef _WIN32
    for (const char *name : {"ProgramFiles", "ProgramW6432", "ProgramFiles(x86)"}) {
      if (auto root = std::getenv(name); root && *root) {
        candidates.emplace_back(std::filesystem::path(root) / "USBip" / "usbip.exe");
        candidates.emplace_back(std::filesystem::path(root) / "usbip-win2" / "usbip.exe");
      }
    }
#else
    candidates = {"/usr/sbin/usbip", "/usr/bin/usbip", "/sbin/usbip"};
    utsname kernel {};
    if (uname(&kernel) == 0) {
      candidates.emplace_back(std::filesystem::path("/usr/lib/linux-tools") / kernel.release / "usbip");
      candidates.emplace_back(std::filesystem::path("/usr/lib") /
                              (std::string("linux-tools-") + kernel.release) / "usbip");
    }
    std::error_code scan_ec;
    for (std::filesystem::directory_iterator it("/usr/lib", scan_ec), end; !scan_ec && it != end; it.increment(scan_ec)) {
      auto name = it->path().filename().string();
      if (name.starts_with("linux-tools")) candidates.emplace_back(it->path() / "usbip");
    }
#endif
    for (const auto &candidate : candidates) {
      std::error_code ec;
      if (std::filesystem::is_regular_file(candidate, ec)) return candidate;
    }
    auto searched = bp::search_path(
#ifdef _WIN32
      "usbip.exe"
#else
      "usbip"
#endif
    );
    if (!searched.empty()) return std::filesystem::path(searched.string());
    return std::nullopt;
  }

  static std::pair<int, std::string> run_usbip(const std::filesystem::path &tool,
                                               const std::vector<std::string> &args,
                                               [[maybe_unused]] bool capture_output = true) {
#ifdef _WIN32
    if (!capture_output) {
      std::error_code ec;
      bp::child child(tool.string(), bp::args(args), bp::std_in < bp::null,
                      bp::std_out > bp::null, bp::std_err > bp::null, ec);
      if (ec || !child.valid()) return {-1, ec.message()};
      auto wait_result = WaitForSingleObject(child.native_handle(), 15000);
      bool finished = wait_result == WAIT_OBJECT_0;
      if (wait_result == WAIT_FAILED) {
        ec = std::error_code((int) GetLastError(), std::system_category());
      }
      if (finished) child.wait(ec);
      if (!finished) {
        child.terminate(ec);
        child.wait(ec);
        return {-1, "timed out"};
      }
      return {child.exit_code(), {}};
    }
#endif
    bp::ipstream output;
    std::error_code ec;
    bp::child child(tool.string(), bp::args(args), bp::std_in < bp::null,
                    bp::std_out > output, bp::std_err > output, ec);
    if (ec || !child.valid()) return {-1, ec.message()};
    std::string text;
    std::thread reader([&] {
      try {
        for (std::string line; std::getline(output, line);) {
          if (text.size() >= 1024 * 1024) continue;  // Keep draining so the child cannot block on a full pipe.
          if (!text.empty()) text.push_back('\n');
          auto remaining = 1024 * 1024 - text.size();
          text.append(line, 0, std::min(line.size(), remaining));
        }
      } catch (const std::exception &) {
        // Windows cancellation below intentionally breaks a descendant-held
        // pipe after the direct child has exited or been terminated.
      }
    });
#ifdef _WIN32
    auto wait_result = WaitForSingleObject(child.native_handle(), 15000);
    bool finished = wait_result == WAIT_OBJECT_0;
    if (wait_result == WAIT_FAILED) {
      ec = std::error_code((int) GetLastError(), std::system_category());
    }
    if (finished) child.wait(ec);  // Populate Boost.Process's cached exit code.
#else
    // Boost.Process v1's timed waits are deprecated because they can miss
    // state changes on POSIX. Poll the non-blocking status until the same
    // deadline instead, then reap the child to populate its exit code.
    const auto deadline = std::chrono::steady_clock::now() + 15s;
    bool running = child.running(ec);
    while (!ec && running && std::chrono::steady_clock::now() < deadline) {
      std::this_thread::sleep_for(10ms);
      running = child.running(ec);
    }
    bool finished = !ec && !running;
    if (finished) child.wait(ec);
#endif
    if (!finished) {
      child.terminate(ec);
      child.wait(ec);
    }
#ifdef _WIN32
    if (reader.joinable()) {
      CancelSynchronousIo(reinterpret_cast<HANDLE>(reader.native_handle()));
      output.pipe().close();
    }
#endif
    if (reader.joinable()) reader.join();
    if (!finished) return {-1, "timed out"};
    return {child.exit_code(), std::move(text)};
  }

  static std::vector<std::string> reconcile_usbip(std::uint16_t proxy_port,
                                                   const std::vector<usb_device_t> &wanted) {
    std::vector<std::string> failures;
    auto tool = find_usbip();
    if (!tool) {
      auto message = "USB passthrough needs the USB/IP client; install usbip-win2 on Windows or usbip on Linux"s;
      if (!wanted.empty()) BOOST_LOG(error) << message;
      failures.push_back(std::move(message));
      return failures;
    }
    auto [port_rc, port_output] = run_usbip(*tool, {"port"});
    auto all = parse_usbip_port_table(port_output);
    std::vector<usb_import_t> current;
    std::copy_if(all.begin(), all.end(), std::back_inserter(current), [proxy_port](const auto &item) {
      return (item.server == "127.0.0.1" || item.server == "localhost" || item.server == "::1") &&
             item.server_port == proxy_port;
    });
    if (port_rc != 0 && port_output.empty()) {
      auto message = "Unable to read the USB/IP attachment table"s;
      BOOST_LOG(error) << message;
      failures.push_back(std::move(message));
      return failures;
    }

    for (const auto &device : wanted) {
      auto present = std::any_of(current.begin(), current.end(), [&](const auto &item) {
        return item.busid == device.busid;
      });
      if (present) continue;
      auto [rc, output] = run_usbip(*tool, usbip_attach_args(proxy_port, device.busid));
      if (rc == 0) {
        BOOST_LOG(info) << "Attached USB device ["sv << device.busid << "] "sv << device.label;
      } else {
        BOOST_LOG(error) << "Failed to attach USB device ["sv << device.busid << "]: "sv << output;
        failures.push_back("attach " + device.busid + ": " + (output.empty() ? "usbip failed" : output));
      }
    }

    // Attaches can renumber vhci ports, so re-read before every detach pass.
    std::tie(port_rc, port_output) = run_usbip(*tool, {"port"});
    if (port_rc != 0 && port_output.empty()) {
      auto message = "Unable to refresh the USB/IP attachment table after attaching"s;
      BOOST_LOG(error) << message;
      failures.push_back(std::move(message));
      return failures;
    }
    all = parse_usbip_port_table(port_output);
    for (const auto &item : all) {
      if (!((item.server == "127.0.0.1" || item.server == "localhost" || item.server == "::1") &&
            item.server_port == proxy_port)) continue;
      auto keep = std::any_of(wanted.begin(), wanted.end(), [&](const auto &device) {
        return device.busid == item.busid;
      });
      if (keep) continue;
      auto [rc, output] = run_usbip(*tool, {"detach", "-p", std::to_string(item.port)});
      if (rc == 0) {
        BOOST_LOG(info) << "Detached USB device ["sv << item.busid << "] from port "sv << item.port;
      } else {
        BOOST_LOG(error) << "Failed to detach USB device ["sv << item.busid << "]: "sv << output;
        failures.push_back("detach " + item.busid + ": " + (output.empty() ? "usbip failed" : output));
      }
    }
    return failures;
  }

  static std::vector<std::string> reconcile_system_disk(std::uint16_t proxy_port,
                                                         std::string_view target_iqn,
                                                         bool attach) {
    std::vector<std::string> failures;
    if (proxy_port < 1024 || !valid_target_iqn(target_iqn)) {
      return {"invalid system disk target"};
    }
#ifdef _WIN32
    auto powershell = bp::search_path("powershell.exe");
    if (powershell.empty()) return {"PowerShell is unavailable for the Windows iSCSI Initiator"};
    auto powershell_path = std::filesystem::path(powershell.string());
    if (attach) {
      // MSiSCSI is demand-start on a stock Windows client. iscsicli does not
      // start it, so the first portal registration otherwise fails with no
      // useful output. PowerShell's Start-Service waits for the running state.
      auto [service_rc, service_output] = run_usbip(
        powershell_path,
        {"-NoProfile", "-NonInteractive", "-Command",
         "Start-Service -Name MSiSCSI -ErrorAction Stop"});
      if (service_rc != 0) {
        return {service_output.empty() ? "Windows iSCSI Initiator could not start" : service_output};
      }
    }

    // The legacy AddTargetPortal CLI requires a brittle 14-argument tail.
    // Native cmdlets accept the ephemeral portal socket directly, keep the
    // login non-persistent, and let withdrawal remove the exact portal only.
    auto script = attach ? windows_iscsi_attach_script(proxy_port, target_iqn) :
                           windows_iscsi_detach_script(proxy_port, target_iqn);
    auto [rc, output] = run_usbip(
      powershell_path,
      {"-NoProfile", "-NonInteractive", "-Command", std::move(script)});
    if (rc != 0) {
      failures.push_back(output.empty() ?
        (attach ? "Windows iSCSI attachment failed" : "Windows iSCSI detach failed") : output);
    }
#else
    auto tool = bp::search_path("iscsiadm");
    if (tool.empty()) return {"install open-iscsi to attach the Moonlight OS disk"};
    auto tool_path = std::filesystem::path(tool.string());
    // Clear only the exact IQN+loopback-port node first. This repairs a host
    // crash without touching any unrelated target configured by the user.
    if (attach) {
      for (const auto &args : iscsiadm_detach_plan(proxy_port, target_iqn)) {
        run_usbip(tool_path, args);
      }
    }
    const auto plan = attach ? iscsiadm_attach_plan(proxy_port, target_iqn) :
                               iscsiadm_detach_plan(proxy_port, target_iqn);
    for (const auto &args : plan) {
      auto [rc, output] = run_usbip(tool_path, args);
      if (rc != 0 && attach) failures.push_back(output.empty() ? "iscsiadm failed" : output);
    }
#endif
    return failures;
  }

#ifdef _WIN32
  static std::vector<std::string> verify_system_disk_detached(
    std::uint16_t proxy_port, std::string_view target_iqn) {
    auto powershell = bp::search_path("powershell.exe");
    if (powershell.empty()) return {"PowerShell is unavailable for iSCSI detach verification"};
    auto [rc, output] = run_usbip(
      std::filesystem::path(powershell.string()),
      {"-NoProfile", "-NonInteractive", "-Command",
       windows_iscsi_detached_script(proxy_port, target_iqn)}, false);
    if (rc == 0) return {};
    return {output.empty() ? "Windows iSCSI detach state did not converge" : output};
  }
#endif

#ifdef __linux__
  static bool write_all(int fd, std::string_view data) {
    while (!data.empty()) {
      auto count = ::send(fd, data.data(), data.size(), MSG_NOSIGNAL);
      if (count < 0 && errno == EINTR) continue;
      if (count <= 0) return false;
      data.remove_prefix(static_cast<std::size_t>(count));
    }
    return true;
  }

  static std::optional<std::string> read_request(int fd) {
    std::string request;
    request.reserve(4096);
    char buffer[4096];
    while (request.size() <= usb_helper_max_request) {
      auto count = ::recv(fd, buffer, sizeof(buffer), 0);
      if (count < 0 && errno == EINTR) continue;
      if (count <= 0) break;
      request.append(buffer, static_cast<std::size_t>(count));
      if (request.find('\n') != std::string::npos) break;
    }
    auto newline = request.find('\n');
    if (newline == std::string::npos || newline > usb_helper_max_request) return std::nullopt;
    request.resize(newline);
    return request;
  }

  static bool same_executable(pid_t peer_pid) {
    struct stat self_stat {}, peer_stat {};
    if (::stat("/proc/self/exe", &self_stat) != 0) return false;
    auto peer_path = "/proc/" + std::to_string(peer_pid) + "/exe";
    if (::stat(peer_path.c_str(), &peer_stat) != 0) return false;
    return self_stat.st_dev == peer_stat.st_dev && self_stat.st_ino == peer_stat.st_ino;
  }

  bool parse_usb_helper_request(std::string_view body, std::uint16_t &proxy_port,
                                std::vector<usb_device_t> &devices) {
    try {
      auto request = nlohmann::json::parse(body);
      if (!request.is_object() || request.value("v", 0) != 1 || !request.contains("port") ||
          !request["port"].is_number_unsigned() || !request.contains("devices") ||
          !request["devices"].is_array() || request["devices"].size() > 16) return false;
      auto port = request["port"].get<std::uint64_t>();
      if (port < 1024 || port > 65535) return false;
      static const std::regex busid_re {R"(^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$)"};
      std::vector<usb_device_t> parsed;
      for (const auto &item : request["devices"]) {
        if (!item.is_object() || !item.contains("busid") || !item["busid"].is_string()) return false;
        auto busid = item["busid"].get<std::string>();
        auto label = item.value("label", std::string {});
        if (!std::regex_match(busid, busid_re) || label.size() > 512) return false;
        parsed.push_back({std::move(busid), {}, std::move(label)});
      }
      proxy_port = static_cast<std::uint16_t>(port);
      devices = std::move(parsed);
      return true;
    } catch (...) {
      return false;
    }
  }

  bool parse_system_disk_helper_request(std::string_view body,
                                        std::uint16_t &proxy_port,
                                        std::string &target_iqn,
                                        bool &attach) {
    try {
      auto request = nlohmann::json::parse(body);
      if (!request.is_object() || request.size() != 5 || request.value("v", 0) != 1 ||
          request.value("kind", "") != "system_disk" ||
          !request.contains("port") || !request["port"].is_number_unsigned() ||
          !request.contains("iqn") || !request["iqn"].is_string() ||
          !request.contains("attach") || !request["attach"].is_boolean()) return false;
      auto port = request["port"].get<std::uint64_t>();
      auto iqn = request["iqn"].get<std::string>();
      if (port < 1024 || port > 65535 || !valid_target_iqn(iqn)) return false;
      proxy_port = static_cast<std::uint16_t>(port);
      target_iqn = std::move(iqn);
      attach = request["attach"].get<bool>();
      return true;
    } catch (...) {
      return false;
    }
  }

  static std::optional<std::string> request_usb_helper(std::uint16_t proxy_port,
                                                        const std::vector<usb_device_t> &wanted) {
    int fd = ::socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
    if (fd < 0) return "could not create the helper socket: " + std::string(std::strerror(errno));
    socklen_t address_length;
    auto address = usb_helper_address(address_length);
    if (::connect(fd, reinterpret_cast<sockaddr *>(&address), address_length) != 0) {
      auto error = "helper is unavailable: " + std::string(std::strerror(errno));
      ::close(fd);
      return error;
    }
    nlohmann::json request {{"v", 1}, {"port", proxy_port}, {"devices", nlohmann::json::array()}};
    for (const auto &device : wanted) {
      request["devices"].push_back({{"busid", device.busid}, {"label", device.label}});
    }
    auto body = request.dump() + "\n";
    auto sent = write_all(fd, body);
    ::shutdown(fd, SHUT_WR);
    auto response = read_request(fd);
    ::close(fd);
    if (!sent || !response) return "helper closed without a complete response"s;
    try {
      auto decoded = nlohmann::json::parse(*response);
      if (decoded.is_object() && decoded.value("ok", false)) return std::nullopt;
      return decoded.value("error", "helper rejected the USB request"s);
    } catch (...) {
      return "helper returned an invalid response"s;
    }
  }

  static std::optional<std::string> request_system_disk_helper(
    std::uint16_t proxy_port, std::string_view target_iqn, bool attach) {
    int fd = ::socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
    if (fd < 0) return "could not create the helper socket: " + std::string(std::strerror(errno));
    socklen_t address_length;
    auto address = usb_helper_address(address_length);
    if (::connect(fd, reinterpret_cast<sockaddr *>(&address), address_length) != 0) {
      auto error = "helper is unavailable: " + std::string(std::strerror(errno));
      ::close(fd);
      return error;
    }
    nlohmann::json request {
      {"v", 1}, {"kind", "system_disk"}, {"port", proxy_port},
      {"iqn", target_iqn}, {"attach", attach},
    };
    auto sent = write_all(fd, request.dump() + "\n");
    ::shutdown(fd, SHUT_WR);
    auto response = read_request(fd);
    ::close(fd);
    if (!sent || !response) return "helper closed without a complete response"s;
    try {
      auto decoded = nlohmann::json::parse(*response);
      if (decoded.is_object() && decoded.value("ok", false)) return std::nullopt;
      return decoded.value("error", "helper rejected the system disk request"s);
    } catch (...) {
      return "helper returned an invalid response"s;
    }
  }

  int run_usb_helper() {
    if (::geteuid() != 0) {
      BOOST_LOG(error) << "The Helios USB helper must run as root"sv;
      return 1;
    }
    int listener = ::socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
    if (listener < 0) return 1;
    socklen_t address_length;
    auto address = usb_helper_address(address_length);
    if (::bind(listener, reinterpret_cast<sockaddr *>(&address), address_length) != 0 ||
        ::listen(listener, 8) != 0) {
      BOOST_LOG(error) << "Unable to start the Helios USB helper: "sv << std::strerror(errno);
      ::close(listener);
      return 1;
    }
    auto group = ::getgrnam(usb_helper_group.data());
    if (!group || ::chown(usb_helper_socket_path.data(), 0, group->gr_gid) != 0 ||
        ::chmod(usb_helper_socket_path.data(), 0660) != 0) {
      BOOST_LOG(error) << "Unable to make the Helios USB helper reachable: "sv << std::strerror(errno);
      ::close(listener);
      return 1;
    }
    BOOST_LOG(info) << "Helios privileged peripheral helper is ready"sv;
    for (;;) {
      int client = ::accept4(listener, nullptr, nullptr, SOCK_CLOEXEC);
      if (client < 0 && errno == EINTR) continue;
      if (client < 0) return 1;
      timeval timeout {.tv_sec = 5, .tv_usec = 0};
      ::setsockopt(client, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
      ::setsockopt(client, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout));
      ucred peer {};
      socklen_t peer_length = sizeof(peer);
      bool authorized = ::getsockopt(client, SOL_SOCKET, SO_PEERCRED, &peer, &peer_length) == 0 &&
                        same_executable(peer.pid);
      std::uint16_t proxy_port = 0;
      auto body = authorized ? read_request(client) : std::nullopt;
      std::vector<usb_device_t> devices;
      std::string target_iqn;
      bool attach_disk = false;
      bool valid_disk = body && parse_system_disk_helper_request(
        *body, proxy_port, target_iqn, attach_disk);
      bool valid_usb = !valid_disk && body && parse_usb_helper_request(*body, proxy_port, devices);
      if (valid_disk) {
        auto failures = reconcile_system_disk(proxy_port, target_iqn, attach_disk);
        nlohmann::json response {{"ok", failures.empty()}};
        if (!failures.empty()) response["error"] = failures.front();
        write_all(client, response.dump() + "\n");
      } else if (valid_usb) {
        auto failures = reconcile_usbip(proxy_port, devices);
        nlohmann::json response {{"ok", failures.empty()}};
        if (!failures.empty()) {
          std::string message;
          for (const auto &failure : failures) {
            if (!message.empty()) message += "; ";
            message += failure;
          }
          response["error"] = std::move(message);
        }
        write_all(client, response.dump() + "\n");
      } else {
        BOOST_LOG(warning) << "Rejected an invalid or unauthorized privileged helper request"sv;
        write_all(client, "{\"ok\":false}\n"sv);
      }
      ::close(client);
    }
  }
#endif

  struct usb_backend_t::impl_t {
    std::uint16_t proxy_port;
    std::mutex mutex;
    std::condition_variable wake;
    bool stopping = false;
    bool pending = false;
    std::uint32_t generation = 0;
    std::vector<usb_device_t> devices;
    std::thread worker;

    explicit impl_t(std::uint16_t port): proxy_port(port), worker([this] { loop(); }) {}

    ~impl_t() {
      {
        std::lock_guard<std::mutex> lock(mutex);
        stopping = true;
        pending = true;
        devices.clear();
        ++generation;
      }
      wake.notify_one();
      if (worker.joinable()) worker.join();
    }

    void reconcile(const std::vector<usb_device_t> &wanted) {
#ifdef __linux__
      if (auto helper_error = request_usb_helper(proxy_port, wanted)) {
        BOOST_LOG(error) << "USB passthrough reconciliation failed: "sv << *helper_error;
      }
#else
      reconcile_usbip(proxy_port, wanted);
#endif
    }

    void loop() {
      for (;;) {
        std::vector<usb_device_t> wanted;
        bool should_stop;
        {
          std::unique_lock<std::mutex> lock(mutex);
          wake.wait(lock, [&] { return pending; });
          pending = false;
          wanted = devices;
          should_stop = stopping;
        }
        reconcile(wanted);
        if (should_stop) return;
      }
    }
  };

  usb_backend_t::usb_backend_t(std::uint16_t proxy_port): impl(std::make_unique<impl_t>(proxy_port)) {}
  usb_backend_t::~usb_backend_t() = default;

  void usb_backend_t::sync(std::uint32_t generation, std::vector<usb_device_t> devices) {
    {
      std::lock_guard<std::mutex> lock(impl->mutex);
      if (impl->generation != 0 &&
          static_cast<std::int32_t>(generation - impl->generation) <= 0) return;
      impl->generation = generation;
      impl->devices = std::move(devices);
      impl->pending = true;
    }
    impl->wake.notify_one();
  }

  struct system_disk_backend_t::impl_t {
    std::uint16_t proxy_port;
    std::string target_iqn;
    std::thread attach_worker;

    impl_t(std::uint16_t port, std::string iqn)
      : proxy_port(port), target_iqn(std::move(iqn)),
        attach_worker([this] { reconcile(true); }) {}

    ~impl_t() {
      if (attach_worker.joinable()) attach_worker.join();
      reconcile(false);
    }

    void reconcile(bool attach) {
#ifdef __linux__
      if (auto helper_error = request_system_disk_helper(proxy_port, target_iqn, attach)) {
        BOOST_LOG(error) << "System disk "sv << (attach ? "attachment" : "detach")
                         << " failed: "sv << *helper_error;
      }
#else
      auto failures = reconcile_system_disk(proxy_port, target_iqn, attach);
#ifdef _WIN32
      // When a client disappears abruptly, Windows may wedge the first native
      // logout until our bounded subprocess guard terminates it. That action
      // also settles the initiator state. Windows 10 can require several such
      // transitions while it drains the session and portal independently.
      // The pass which completes removal may itself retain a child handle
      // until our guard fires, so finish the bounded action passes first.
      for (int retry = 0; !attach && !failures.empty() && retry < 4; ++retry) {
        std::this_thread::sleep_for(500ms);
        failures = reconcile_system_disk(proxy_port, target_iqn, false);
      }
      // Windows publishes removal asynchronously after iscsicli exits. Do not
      // issue more mutations here: poll only the exact session and portal
      // state, accepting success solely after both have disappeared.
      for (int verify = 0; !attach && !failures.empty() && verify < 3; ++verify) {
        std::this_thread::sleep_for(30s);
        failures = verify_system_disk_detached(proxy_port, target_iqn);
      }
#endif
      if (!failures.empty()) {
        BOOST_LOG(error) << "System disk "sv << (attach ? "attachment" : "detach")
                         << " failed: "sv << failures.front();
      }
#endif
    }
  };

  system_disk_backend_t::system_disk_backend_t(std::uint16_t proxy_port,
                                               std::string target_iqn)
    : impl(std::make_unique<impl_t>(proxy_port, std::move(target_iqn))) {}

  system_disk_backend_t::~system_disk_backend_t() = default;
}
