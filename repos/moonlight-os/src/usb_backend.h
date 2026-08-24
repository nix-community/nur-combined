/**
 * @file src/usb_backend.h
 * @brief Session-owned USB/IP reconciliation for Moonlight OS clients.
 */
#pragma once

#include <cstdint>
#include <memory>
#include <string>
#include <string_view>
#include <vector>

namespace stream {
  struct usb_device_t;

  struct usb_import_t {
    int port = -1;
    std::string server;
    std::uint16_t server_port = 3240;
    std::string busid;
  };

  // Kept pure and public for the captured Linux/usbip-win2 fixtures.
  std::vector<usb_import_t> parse_usbip_port_table(std::string_view output);
  std::vector<std::string> usbip_attach_args(std::uint16_t proxy_port, std::string_view busid);

  // Native iSCSI initiator commands for the loopback disk proxy. Kept pure so
  // Linux command construction can be regression-tested without privileges.
  std::vector<std::vector<std::string>> iscsiadm_attach_plan(
    std::uint16_t proxy_port, std::string_view target_iqn);
  std::vector<std::vector<std::string>> iscsiadm_detach_plan(
    std::uint16_t proxy_port, std::string_view target_iqn);

  // Windows exposes the loopback portal socket cleanly through its iSCSI
  // PowerShell cmdlets. These builders stay pure so quoting, non-persistence,
  // and exact portal cleanup can be regression-tested on every platform.
  std::string windows_iscsi_attach_script(
    std::uint16_t proxy_port, std::string_view target_iqn);
  std::string windows_iscsi_detach_script(
    std::uint16_t proxy_port, std::string_view target_iqn);
  std::string windows_iscsi_detached_script(
    std::uint16_t proxy_port, std::string_view target_iqn);

  class usb_backend_t {
  public:
    explicit usb_backend_t(std::uint16_t proxy_port);
    ~usb_backend_t();
    usb_backend_t(const usb_backend_t &) = delete;
    usb_backend_t &operator=(const usb_backend_t &) = delete;

    // Coalesces rapid hotplug generations; the newest complete set wins.
    void sync(std::uint32_t generation, std::vector<usb_device_t> devices);

  private:
    struct impl_t;
    std::unique_ptr<impl_t> impl;
  };

  class system_disk_backend_t {
  public:
    system_disk_backend_t(std::uint16_t proxy_port, std::string target_iqn);
    ~system_disk_backend_t();
    system_disk_backend_t(const system_disk_backend_t &) = delete;
    system_disk_backend_t &operator=(const system_disk_backend_t &) = delete;

  private:
    struct impl_t;
    std::unique_ptr<impl_t> impl;
  };

#ifdef __linux__
  bool parse_usb_helper_request(std::string_view body, std::uint16_t &proxy_port,
                                std::vector<usb_device_t> &devices);
  bool parse_system_disk_helper_request(std::string_view body,
                                        std::uint16_t &proxy_port,
                                        std::string &target_iqn,
                                        bool &attach);

  // Root-only, package-managed companion mode. The helper accepts a bounded
  // declarative sync only from another process running this exact executable.
  int run_usb_helper();
#endif
}
