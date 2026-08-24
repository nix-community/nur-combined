/**
 * @file tests/unit/test_stream.cpp
 * @brief Test src/stream.*
 */

#include <cstdint>
#include <array>
#include <functional>
#include <string>
#include <vector>

#include <opus/opus.h>

#include "../../src/stream.h"
#include "../../src/network.h"
#include "../../src/quic_transport.h"
#include "../../src/usb_backend.h"
#include "../../src/usb_compat.h"
#include "../../third-party/moonlight-common-c/src/MlosQuicWire.h"

namespace stream {
  std::vector<uint8_t> concat_and_insert(uint64_t insert_size, uint64_t slice_size, const std::string_view &data1, const std::string_view &data2);
}

#include "../tests_common.h"

TEST(ConcatAndInsertTests, ConcatNoInsertionTest) {
  char b1[] = {'a', 'b'};
  char b2[] = {'c', 'd', 'e'};
  auto res = stream::concat_and_insert(0, 2, std::string_view {b1, sizeof(b1)}, std::string_view {b2, sizeof(b2)});
  auto expected = std::vector<uint8_t> {'a', 'b', 'c', 'd', 'e'};
  ASSERT_EQ(res, expected);
}

TEST(ConcatAndInsertTests, ConcatLargeStrideTest) {
  char b1[] = {'a', 'b'};
  char b2[] = {'c', 'd', 'e'};
  auto res = stream::concat_and_insert(1, sizeof(b1) + sizeof(b2) + 1, std::string_view {b1, sizeof(b1)}, std::string_view {b2, sizeof(b2)});
  auto expected = std::vector<uint8_t> {0, 'a', 'b', 'c', 'd', 'e'};
  ASSERT_EQ(res, expected);
}

TEST(ConcatAndInsertTests, ConcatSmallStrideTest) {
  char b1[] = {'a', 'b'};
  char b2[] = {'c', 'd', 'e'};
  auto res = stream::concat_and_insert(1, 1, std::string_view {b1, sizeof(b1)}, std::string_view {b2, sizeof(b2)});
  auto expected = std::vector<uint8_t> {0, 'a', 0, 'b', 0, 'c', 0, 'd', 0, 'e'};
  ASSERT_EQ(res, expected);
}

namespace {
  void put16(std::string &out, std::uint16_t value) {
    out.push_back((char) (value & 0xff));
    out.push_back((char) (value >> 8));
  }

  void put32(std::string &out, std::uint32_t value) {
    put16(out, (std::uint16_t) (value & 0xffff));
    put16(out, (std::uint16_t) (value >> 16));
  }

  void put64(std::string &out, std::uint64_t value) {
    put32(out, (std::uint32_t) value);
    put32(out, (std::uint32_t) (value >> 32));
  }

  void put_usb(std::string &out, const std::string &busid,
               const std::string &hwid, const std::string &label) {
    put16(out, (std::uint16_t) busid.size());
    put16(out, (std::uint16_t) hwid.size());
    put16(out, (std::uint16_t) label.size());
    put16(out, 0);
    out += busid;
    out += hwid;
    out += label;
  }

  std::string usb_offer(std::uint32_t generation) {
    std::string out;
    out.push_back(1);
    out.push_back(0);
    put16(out, 2);
    put32(out, generation);
    put_usb(out, "1-2.3", "046d:c262", "Logitech wheel");
    put_usb(out, "2-1", "1234:5678", "MIDI controller");
    return out;
  }

  void put_display(std::string &out, std::int32_t x, std::int32_t y,
                   std::uint32_t width, std::uint32_t height,
                   std::uint32_t refresh, std::uint32_t scale,
                   std::uint16_t flags) {
    put32(out, (std::uint32_t) x);
    put32(out, (std::uint32_t) y);
    put32(out, width);
    put32(out, height);
    put32(out, refresh);
    put32(out, scale);
    put16(out, 600);
    put16(out, 340);
    put16(out, flags);
    put16(out, 0);
  }

  std::string display_topology() {
    std::string out;
    out.push_back(1);
    out.push_back(0);
    put16(out, 2);
    put32(out, 19);
    put_display(out, -2560, 0, 2560, 1440, 144000, 1000, 0);
    put_display(out, 0, 0, 1920, 1080, 60000, 1250, 1);
    return out;
  }
}

TEST(DisplayTopologyTests, ParsesUnifiedDesktopAndPrimary) {
  auto payload = display_topology();
  std::uint32_t generation = 0;
  std::vector<stream::display_desc_t> displays;
  ASSERT_TRUE(stream::parse_display_topology(payload, generation, displays));
  ASSERT_EQ(generation, 19u);
  ASSERT_EQ(displays.size(), 2u);
  EXPECT_EQ(displays[0].x, -2560);
  EXPECT_EQ(displays[0].refresh_millihz, 144000u);
  EXPECT_EQ(displays[1].scale_milli, 1250u);
  EXPECT_EQ(displays[1].flags, 1u);
}

TEST(DisplayTopologyTests, RejectsMalformedWithoutReplacingCurrentState) {
  auto payload = display_topology();
  payload.pop_back();
  std::uint32_t generation = 7;
  std::vector<stream::display_desc_t> displays(1);
  displays[0].width = 111;
  EXPECT_FALSE(stream::parse_display_topology(payload, generation, displays));
  EXPECT_EQ(generation, 7u);
  ASSERT_EQ(displays.size(), 1u);
  EXPECT_EQ(displays[0].width, 111u);

  payload = display_topology();
  payload[8 + 28] = 1; // First display also claims primary.
  EXPECT_FALSE(stream::parse_display_topology(payload, generation, displays));
}

TEST(DisplayTopologyTests, SelectsIndependentOutputByStreamIndex) {
  const std::vector<std::string> outputs {"MOONLIGHT-0", "MOONLIGHT-1"};

  EXPECT_EQ(stream::select_display_output(outputs, 0), "MOONLIGHT-0");
  EXPECT_EQ(stream::select_display_output(outputs, 1), "MOONLIGHT-1");
  EXPECT_FALSE(stream::select_display_output(outputs, 2));
}

TEST(SystemDiskOfferTests, ParsesReadOnlyOfferAndWithdrawal) {
  const std::string iqn = "iqn.2026-08.os.moonlight:system";
  std::string payload;
  payload.push_back(1);
  payload.push_back(1);
  put16(payload, (std::uint16_t) iqn.size());
  put32(payload, 7);
  put64(payload, 64ull * 1024 * 1024);
  put32(payload, 512);
  payload += iqn;

  stream::system_disk_offer_t offer;
  ASSERT_TRUE(stream::parse_system_disk_offer(payload, offer));
  EXPECT_EQ(offer.generation, 7u);
  EXPECT_EQ(offer.size, 64ull * 1024 * 1024);
  EXPECT_EQ(offer.sector_size, 512u);
  EXPECT_EQ(offer.target_iqn, iqn);

  payload.assign(2, '\0');
  payload[0] = 1;
  put16(payload, 0);
  put32(payload, 8);
  put64(payload, 0);
  put32(payload, 0);
  ASSERT_TRUE(stream::parse_system_disk_offer(payload, offer));
  EXPECT_EQ(offer.generation, 8u);
  EXPECT_FALSE(offer.present());
}

TEST(SystemDiskOfferTests, RejectsWritableOrMalformedWithoutReplacingState) {
  const std::string iqn = "iqn.2026-08.os.moonlight:system";
  std::string payload;
  payload.push_back(1);
  payload.push_back(0);  // A present disk must be kernel-enforced read-only.
  put16(payload, (std::uint16_t) iqn.size());
  put32(payload, 9);
  put64(payload, 4096);
  put32(payload, 512);
  payload += iqn;

  stream::system_disk_offer_t offer {3, 8192, 4096, "iqn.keep"};
  EXPECT_FALSE(stream::parse_system_disk_offer(payload, offer));
  EXPECT_EQ(offer.generation, 3u);
  EXPECT_EQ(offer.target_iqn, "iqn.keep");

  payload[1] = 1;
  payload.pop_back();
  EXPECT_FALSE(stream::parse_system_disk_offer(payload, offer));
  EXPECT_EQ(offer.target_iqn, "iqn.keep");
}

TEST(FeatureAdvertisementTests, EmptyAdvertisementMeansVanillaCompatible) {
  std::string payload;
  payload.push_back(1);
  payload.push_back(0);
  put16(payload, 0);
  std::map<std::uint16_t, std::uint16_t> features {{99, 1}};
  ASSERT_TRUE(stream::parse_feature_advertisement(payload, features));
  EXPECT_TRUE(features.empty());
}

TEST(FeatureAdvertisementTests, RejectsMalformedWithoutHalfEnablingExtensions) {
  std::string payload;
  payload.push_back(1);
  payload.push_back(0);
  put16(payload, 2);
  put16(payload, 1);
  put16(payload, 1); // Claimed second entry is absent.
  std::map<std::uint16_t, std::uint16_t> features {{77, 3}};
  EXPECT_FALSE(stream::parse_feature_advertisement(payload, features));
  ASSERT_EQ(features.size(), 1u);
  EXPECT_EQ(features.at(77), 3u);

  payload.clear();
  payload.push_back(2); // Unknown format.
  payload.push_back(0);
  put16(payload, 0);
  EXPECT_FALSE(stream::parse_feature_advertisement(payload, features));
  EXPECT_EQ(features.at(77), 3u);
}

TEST(FeatureAdvertisementTests, UnknownFeaturesAndVersionsStayDisabled) {
  const std::map<std::uint16_t, std::uint16_t> advertised {
    {1, 1}, {2, 2}, {99, 1}
  };
  const std::map<std::uint16_t, std::uint16_t> supported {
    {1, 1}, {2, 1}
  };

  auto negotiated = stream::negotiate_features(advertised, supported);
  ASSERT_EQ(negotiated.size(), 1u);
  EXPECT_EQ(negotiated.at(1), 1u);
}

TEST(FeatureAdvertisementTests, UnavailableCameraEndpointIsNotAdvertised) {
  constexpr std::uint16_t cameraFeature = 0x0005;

  auto withoutCamera = stream::host_supported_features(false, false);
  EXPECT_FALSE(withoutCamera.contains(cameraFeature));

  auto withCamera = stream::host_supported_features(true, false);
  ASSERT_TRUE(withCamera.contains(cameraFeature));
  EXPECT_EQ(withCamera.at(cameraFeature), 1u);
}

TEST(FeatureAdvertisementTests, UnavailableDisplayTopologyIsNotAdvertised) {
  constexpr std::uint16_t displayTopologyFeature = 0x0006;

  auto withoutTopology = stream::host_supported_features(false, false);
  EXPECT_FALSE(withoutTopology.contains(displayTopologyFeature));

  auto withTopology = stream::host_supported_features(false, true);
  ASSERT_TRUE(withTopology.contains(displayTopologyFeature));
  EXPECT_EQ(withTopology.at(displayTopologyFeature), 1u);
}

TEST(UsbDeviceOfferTests, ParsesCompleteDeclarativeSet) {
  auto payload = usb_offer(42);
  std::uint32_t generation = 0;
  std::vector<stream::usb_device_t> devices;

  ASSERT_TRUE(stream::parse_usb_device_offer(payload, generation, devices));
  ASSERT_EQ(generation, 42u);
  ASSERT_EQ(devices.size(), 2u);
  EXPECT_EQ(devices[0].busid, "1-2.3");
  EXPECT_EQ(devices[0].hwid, "046d:c262");
  EXPECT_EQ(devices[0].label, "Logitech wheel");
  EXPECT_EQ(devices[1].busid, "2-1");
}

TEST(UsbDeviceOfferTests, EmptySetMeansDetachEverything) {
  std::string payload;
  payload.push_back(1);
  payload.push_back(0);
  put16(payload, 0);
  put32(payload, 7);
  std::uint32_t generation = 0;
  std::vector<stream::usb_device_t> devices {{"old", "", ""}};

  ASSERT_TRUE(stream::parse_usb_device_offer(payload, generation, devices));
  EXPECT_EQ(generation, 7u);
  EXPECT_TRUE(devices.empty());
}

TEST(UsbDeviceOfferTests, RejectsTruncationWithoutReplacingCurrentSet) {
  auto payload = usb_offer(42);
  payload.pop_back();
  std::uint32_t generation = 9;
  std::vector<stream::usb_device_t> devices {{"keep-1", "", "keep"}};

  EXPECT_FALSE(stream::parse_usb_device_offer(payload, generation, devices));
  EXPECT_EQ(generation, 9u);
  ASSERT_EQ(devices.size(), 1u);
  EXPECT_EQ(devices[0].busid, "keep-1");
}

TEST(UsbDeviceOfferTests, RejectsDuplicateOrCommandLikeBusIds) {
  std::string duplicate;
  duplicate.push_back(1);
  duplicate.push_back(0);
  put16(duplicate, 2);
  put32(duplicate, 1);
  put_usb(duplicate, "1-2", "", "one");
  put_usb(duplicate, "1-2", "", "two");

  std::uint32_t generation = 0;
  std::vector<stream::usb_device_t> devices;
  EXPECT_FALSE(stream::parse_usb_device_offer(duplicate, generation, devices));

  std::string command_like;
  command_like.push_back(1);
  command_like.push_back(0);
  put16(command_like, 1);
  put32(command_like, 1);
  put_usb(command_like, "1-2;reboot", "", "bad");
  EXPECT_FALSE(stream::parse_usb_device_offer(command_like, generation, devices));
}

TEST(UsbIpCommandTests, PlacesGlobalTcpPortBeforeAttachSubcommand) {
  EXPECT_EQ(stream::usbip_attach_args(50924, "1-2.1"),
            (std::vector<std::string> {"--tcp-port", "50924", "attach", "-r",
                                       "127.0.0.1", "-b", "1-2.1"}));
}

TEST(UsbDeviceSyncPlanTests, AttachesBeforeDetaching) {
  std::vector<stream::usb_attachment_t> current {{"1-1", 3}, {"2-1", 7}};
  std::vector<stream::usb_device_t> offered {
    {"2-1", "1234:5678", "still here"},
    {"3-2", "046d:c262", "new wheel"},
  };

  auto actions = stream::plan_usb_device_sync(current, offered);
  ASSERT_EQ(actions.size(), 2u);
  EXPECT_EQ(actions[0].action, stream::usb_sync_action_e::attach);
  EXPECT_EQ(actions[0].device.busid, "3-2");
  EXPECT_EQ(actions[0].device.hwid, "046d:c262");
  EXPECT_EQ(actions[0].port, -1);
  EXPECT_EQ(actions[1].action, stream::usb_sync_action_e::detach);
  EXPECT_EQ(actions[1].device.busid, "1-1");
  EXPECT_EQ(actions[1].port, 3);
}

TEST(UsbDeviceSyncPlanTests, EmptyOfferDetachesEveryImportedPort) {
  std::vector<stream::usb_attachment_t> current {{"1-1", 2}, {"2-3", 9}};

  auto actions = stream::plan_usb_device_sync(current, {});
  ASSERT_EQ(actions.size(), 2u);
  EXPECT_EQ(actions[0].action, stream::usb_sync_action_e::detach);
  EXPECT_EQ(actions[0].port, 2);
  EXPECT_EQ(actions[1].action, stream::usb_sync_action_e::detach);
  EXPECT_EQ(actions[1].port, 9);
}

TEST(UsbDeviceSyncPlanTests, IdenticalSetIsNoOp) {
  std::vector<stream::usb_attachment_t> current {{"1-2.3", 4}};
  std::vector<stream::usb_device_t> offered {{"1-2.3", "046d:c262", "wheel"}};

  EXPECT_TRUE(stream::plan_usb_device_sync(current, offered).empty());
}

TEST(UsbTunnelFrameTests, ParsesStrictDataFrame) {
  std::string payload;
  put32(payload, 0x78563412);
  put16(payload, 4);
  put16(payload, 0);
  payload += "test";

  std::uint32_t id = 0;
  std::string_view data;
  ASSERT_TRUE(stream::parse_usb_tunnel_data(payload, id, data));
  EXPECT_EQ(id, 0x78563412u);
  EXPECT_EQ(data, "test");
}

TEST(UsbTunnelFrameTests, RejectsInvalidDataWithoutReplacingOutputs) {
  std::string payload;
  put32(payload, 8);
  put16(payload, 3);
  put16(payload, 0);
  payload += "no";  // Claimed length does not match the packet.

  std::uint32_t id = 99;
  std::string_view data = "keep";
  EXPECT_FALSE(stream::parse_usb_tunnel_data(payload, id, data));
  EXPECT_EQ(id, 99u);
  EXPECT_EQ(data, "keep");

  payload[6] = 1;  // Reserved bits must also be rejected.
  payload += "w";
  EXPECT_FALSE(stream::parse_usb_tunnel_data(payload, id, data));
}

TEST(UsbTunnelFrameTests, ParsesAndBoundsCloseFrame) {
  std::string payload;
  put32(payload, 7);
  put16(payload, 2);
  put16(payload, 0);

  std::uint32_t id = 0;
  std::uint16_t reason = 0;
  ASSERT_TRUE(stream::parse_usb_tunnel_close(payload, id, reason));
  EXPECT_EQ(id, 7u);
  EXPECT_EQ(reason, 2u);

  payload.push_back(0);
  EXPECT_FALSE(stream::parse_usb_tunnel_close(payload, id, reason));
}

TEST(UsbIpPortTableTests, ParsesLinuxAndScopesCustomPort) {
  const std::string table = R"(Imported USB devices
====================
Port 00: <Port in Use> at High Speed(480Mbps)
       Device one
       1-1 -> usbip://127.0.0.1:49152/1-2.3
           -> remote bus/dev 001/004
Port 07: <Port in Use> at Full Speed(12Mbps)
       Device two
       2-1 -> usbip://192.168.1.40:3240/2-1
)";
  auto imports = stream::parse_usbip_port_table(table);
  ASSERT_EQ(imports.size(), 2u);
  EXPECT_EQ(imports[0].port, 0);
  EXPECT_EQ(imports[0].server, "127.0.0.1");
  EXPECT_EQ(imports[0].server_port, 49152);
  EXPECT_EQ(imports[0].busid, "1-2.3");
  EXPECT_EQ(imports[1].port, 7);
  EXPECT_EQ(imports[1].server_port, 3240);
}

TEST(UsbIpPortTableTests, ParsesBracketedIpv6AndRejectsInvalidPort) {
  const std::string table = R"(Port 03: <Port in Use>
       3-1 -> usbip://[::1]:50000/2-4
Port 04: <Port in Use>
       4-1 -> usbip://127.0.0.1:99999/3-2
)";
  auto imports = stream::parse_usbip_port_table(table);
  ASSERT_EQ(imports.size(), 1u);
  EXPECT_EQ(imports[0].server, "::1");
  EXPECT_EQ(imports[0].server_port, 50000);
  EXPECT_EQ(imports[0].busid, "2-4");
}

TEST(SystemDiskBackendTests, BuildsExactLoopbackIscsiPlans) {
  auto attach = stream::iscsiadm_attach_plan(49152, "iqn.2026-08.os.moonlight:system");
  ASSERT_EQ(attach.size(), 3u);
  EXPECT_EQ(attach[0], (std::vector<std::string> {
    "-m", "node", "-T", "iqn.2026-08.os.moonlight:system",
    "-p", "127.0.0.1:49152", "--op", "new"}));
  EXPECT_EQ(attach[2].back(), "--login");

  auto detach = stream::iscsiadm_detach_plan(49152, "iqn.2026-08.os.moonlight:system");
  ASSERT_EQ(detach.size(), 2u);
  EXPECT_EQ(detach[0].back(), "--logout");
  EXPECT_EQ(detach[1].back(), "delete");
}

TEST(SystemDiskBackendTests, BuildsSafeWindowsPowerShellPlans) {
  const std::string iqn = "iqn.2026-08.os.moonlight:system";
  auto attach = stream::windows_iscsi_attach_script(49152, iqn);
  EXPECT_NE(attach.find("Get-IscsiTargetPortal"), std::string::npos);
  EXPECT_NE(attach.find("New-IscsiTargetPortal"), std::string::npos);
  EXPECT_NE(attach.find("Connect-IscsiTarget"), std::string::npos);
  EXPECT_NE(attach.find("-TargetPortalPortNumber 49152"), std::string::npos);
  EXPECT_NE(attach.find("-IsPersistent $false"), std::string::npos);
  EXPECT_NE(attach.find("-ReportToPnP $true"), std::string::npos);

  auto detach = stream::windows_iscsi_detach_script(49152, iqn);
  EXPECT_NE(detach.find("iscsicli.exe"), std::string::npos);
  EXPECT_NE(detach.find("Get-IscsiSession"), std::string::npos);
  EXPECT_NE(detach.find("$attempt -lt 8"), std::string::npos);
  EXPECT_NE(detach.find("LogoutTarget $session.SessionIdentifier"), std::string::npos);
  EXPECT_NE(detach.find("TargetNodeAddress -eq 'iqn.2026-08.os.moonlight:system'"), std::string::npos);
  EXPECT_NE(detach.find("iSCSI session remained after logout"), std::string::npos);
  EXPECT_NE(detach.find("RemoveTargetPortal '127.0.0.1' 49152"), std::string::npos);
  EXPECT_NE(detach.find("$LASTEXITCODE -ne 0"), std::string::npos);
  EXPECT_NE(detach.find("iSCSI target portal remained after removal"), std::string::npos);
  EXPECT_NE(detach.find("-TargetPortalPortNumber 49152"), std::string::npos);
  EXPECT_EQ(detach.find("Disconnect-IscsiTarget"), std::string::npos);
  EXPECT_EQ(detach.find("Remove-IscsiTargetPortal"), std::string::npos);
  EXPECT_EQ(detach.find("Remove-CimInstance"), std::string::npos);

  auto detached = stream::windows_iscsi_detached_script(49152, iqn);
  EXPECT_NE(detached.find("Get-IscsiSession"), std::string::npos);
  EXPECT_NE(detached.find("TargetNodeAddress -eq 'iqn.2026-08.os.moonlight:system'"), std::string::npos);
  EXPECT_NE(detached.find("Get-IscsiTargetPortal"), std::string::npos);
  EXPECT_NE(detached.find("-TargetPortalPortNumber 49152"), std::string::npos);
  EXPECT_NE(detached.find("iSCSI session remains"), std::string::npos);
  EXPECT_NE(detached.find("iSCSI target portal remains"), std::string::npos);

  EXPECT_TRUE(stream::windows_iscsi_attach_script(
    49152, "iqn.good:disk;Restart-Computer").empty());
  EXPECT_TRUE(stream::windows_iscsi_detach_script(80, iqn).empty());
}

#ifdef __linux__
TEST(SystemDiskBackendTests, PrivilegedHelperParserIsStrictAndStatePreserving) {
  std::uint16_t port = 40000;
  std::string iqn = "iqn.keep";
  bool attach = false;
  const std::string valid =
    R"({"v":1,"kind":"system_disk","port":49152,"iqn":"iqn.2026-08.os.moonlight:system","attach":true})";
  ASSERT_TRUE(stream::parse_system_disk_helper_request(valid, port, iqn, attach));
  EXPECT_EQ(port, 49152);
  EXPECT_EQ(iqn, "iqn.2026-08.os.moonlight:system");
  EXPECT_TRUE(attach);

  const std::string injected =
    R"({"v":1,"kind":"system_disk","port":49152,"iqn":"iqn.good:disk;reboot","attach":false})";
  EXPECT_FALSE(stream::parse_system_disk_helper_request(injected, port, iqn, attach));
  EXPECT_EQ(port, 49152);
  EXPECT_EQ(iqn, "iqn.2026-08.os.moonlight:system");
  EXPECT_TRUE(attach);
}
#endif

#ifdef __linux__
TEST(UsbHelperRequestTests, ParsesBoundedDeclarativeRequest) {
  std::uint16_t port = 0;
  std::vector<stream::usb_device_t> devices;
  ASSERT_TRUE(stream::parse_usb_helper_request(
    R"({"v":1,"port":49152,"devices":[{"busid":"1-2.3","label":"Wheel"}]})", port, devices));
  EXPECT_EQ(port, 49152);
  ASSERT_EQ(devices.size(), 1);
  EXPECT_EQ(devices[0].busid, "1-2.3");
  EXPECT_EQ(devices[0].label, "Wheel");
}

TEST(UsbHelperRequestTests, RejectsUnsafeInputWithoutReplacingState) {
  std::uint16_t port = 40000;
  std::vector<stream::usb_device_t> devices {{"old", "", "Existing"}};
  EXPECT_FALSE(stream::parse_usb_helper_request(
    R"({"v":1,"port":22,"devices":[{"busid":"1-2;reboot","label":"bad"}]})", port, devices));
  EXPECT_EQ(port, 40000);
  ASSERT_EQ(devices.size(), 1);
  EXPECT_EQ(devices[0].busid, "old");
}
#endif

namespace {
  void put_be16(std::vector<std::uint8_t> &bytes, std::size_t at, std::uint16_t value) {
    bytes[at] = (std::uint8_t) (value >> 8);
    bytes[at + 1] = (std::uint8_t) value;
  }

  void put_be32(std::vector<std::uint8_t> &bytes, std::size_t at, std::uint32_t value) {
    bytes[at] = (std::uint8_t) (value >> 24);
    bytes[at + 1] = (std::uint8_t) (value >> 16);
    bytes[at + 2] = (std::uint8_t) (value >> 8);
    bytes[at + 3] = (std::uint8_t) value;
  }

  std::vector<std::uint8_t> microphone_fixture(const crypto::aes_t &key) {
    constexpr std::size_t header_size = 36;
    std::vector<std::uint8_t> plaintext(8 + 1200);
    put_be32(plaintext, 0, 96000);
    put_be16(plaintext, 4, 960);
    plaintext[6] = 1;
    int opus_error;
    auto *encoder = opus_encoder_create(48000, 1, OPUS_APPLICATION_VOIP, &opus_error);
    EXPECT_EQ(opus_error, OPUS_OK);
    EXPECT_NE(encoder, nullptr);
    if (!encoder) return {};
    std::array<float, 960> pcm {};
    auto opus_size = opus_encode_float(encoder, pcm.data(), pcm.size(),
                                       plaintext.data() + 8, 1200);
    opus_encoder_destroy(encoder);
    EXPECT_GT(opus_size, 0);
    plaintext.resize(8 + opus_size);

    std::vector<std::uint8_t> packet(header_size + plaintext.size());
    put_be32(packet, 0, 0x4D4C4D43);
    packet[4] = 1;
    put_be16(packet, 6, (std::uint16_t) packet.size());
    put_be32(packet, 8, 0x12345678);
    put_be32(packet, 12, 0);
    put_be32(packet, 16, 42);

    crypto::aes_t iv(12, 0);
    iv[7] = 42;
    iv[10] = 'M';
    iv[11] = 'C';
    crypto::cipher::gcm_t cipher(key, false);
    auto bytes = cipher.encrypt(
      std::string_view {(const char *) plaintext.data(), plaintext.size()}, packet.data() + 20, &iv);
    EXPECT_EQ(bytes, (int) plaintext.size());
    return packet;
  }

  std::vector<std::uint8_t> camera_fixture(const crypto::aes_t &key,
                                           std::uint16_t fragment_index,
                                           std::uint32_t offset,
                                           std::size_t data_size) {
    constexpr std::size_t header_size = 36;
    constexpr std::size_t fragment_header_size = 26;
    constexpr std::uint32_t frame_size = 1600;
    std::vector<std::uint8_t> plaintext(fragment_header_size + data_size);
    put_be32(plaintext, 0, 7);
    put_be32(plaintext, 4, 1234);
    put_be16(plaintext, 8, 640);
    put_be16(plaintext, 10, 480);
    plaintext[12] = 1;
    put_be16(plaintext, 14, fragment_index);
    put_be16(plaintext, 16, 2);
    put_be32(plaintext, 18, frame_size);
    put_be32(plaintext, 22, offset);
    std::fill(plaintext.begin() + fragment_header_size, plaintext.end(),
              static_cast<std::uint8_t>(0x40 + fragment_index));

    std::vector<std::uint8_t> packet(header_size + plaintext.size());
    put_be32(packet, 0, 0x4D4C4341);
    packet[4] = 1;
    put_be16(packet, 6, static_cast<std::uint16_t>(packet.size()));
    put_be32(packet, 8, 0x12345678);
    put_be32(packet, 12, 0);
    put_be32(packet, 16, 100 + fragment_index);

    crypto::aes_t iv(12, 0);
    iv[7] = static_cast<std::uint8_t>(100 + fragment_index);
    iv[10] = 'C';
    iv[11] = 'A';
    crypto::cipher::gcm_t cipher(key, false);
    auto bytes = cipher.encrypt(
      std::string_view {(const char *) plaintext.data(), plaintext.size()}, packet.data() + 20, &iv);
    EXPECT_EQ(bytes, static_cast<int>(plaintext.size()));
    return packet;
  }
}

TEST(MicrophonePacketTests, AuthenticatesAndDecodesBoundedOpusFrame) {
  crypto::aes_t key(16);
  for (std::size_t i = 0; i < key.size(); ++i) key[i] = (std::uint8_t) i;
  auto fixture = microphone_fixture(key);
  crypto::cipher::gcm_t cipher(key, false);
  stream::microphone_packet_t packet;
  ASSERT_TRUE(stream::decode_microphone_packet(
    std::string_view {(const char *) fixture.data(), fixture.size()}, cipher, packet));
  EXPECT_EQ(packet.connect_data, 0x12345678u);
  EXPECT_EQ(packet.sequence, 42u);
  EXPECT_EQ(packet.timestamp, 96000u);
  EXPECT_EQ(packet.samples, 960u);
  EXPECT_EQ(packet.channels, 1u);
  int opus_error;
  auto *decoder = opus_decoder_create(48000, 1, &opus_error);
  ASSERT_EQ(opus_error, OPUS_OK);
  ASSERT_NE(decoder, nullptr);
  std::array<float, 960> pcm;
  EXPECT_EQ(opus_decode_float(decoder, packet.opus.data(), packet.opus.size(),
                              pcm.data(), pcm.size(), 0), 960);
  opus_decoder_destroy(decoder);
}

TEST(MicrophonePacketTests, RejectsTamperingAndPreservesOutput) {
  crypto::aes_t key(16, 7);
  auto fixture = microphone_fixture(key);
  fixture.back() ^= 0x01;
  crypto::cipher::gcm_t cipher(key, false);
  stream::microphone_packet_t packet;
  packet.sequence = 99;
  EXPECT_FALSE(stream::decode_microphone_packet(
    std::string_view {(const char *) fixture.data(), fixture.size()}, cipher, packet));
  EXPECT_EQ(packet.sequence, 99u);
}

TEST(CameraFragmentTests, AuthenticatesAndDecodesDeterministicFragments) {
  crypto::aes_t key(16, 9);
  auto fixture = camera_fixture(key, 1, 1050, 550);
  crypto::cipher::gcm_t cipher(key, false);
  stream::camera_fragment_t fragment;
  ASSERT_TRUE(stream::decode_camera_fragment(
    std::string_view {(const char *) fixture.data(), fixture.size()}, cipher, fragment));
  EXPECT_EQ(fragment.connect_data, 0x12345678u);
  EXPECT_EQ(fragment.sequence, 101u);
  EXPECT_EQ(fragment.frame_id, 7u);
  EXPECT_EQ(fragment.timestamp_ms, 1234u);
  EXPECT_EQ(fragment.width, 640u);
  EXPECT_EQ(fragment.height, 480u);
  EXPECT_EQ(fragment.fragment_index, 1u);
  EXPECT_EQ(fragment.fragment_count, 2u);
  EXPECT_EQ(fragment.frame_length, 1600u);
  EXPECT_EQ(fragment.offset, 1050u);
  ASSERT_EQ(fragment.data.size(), 550u);
  EXPECT_EQ(fragment.data.front(), 0x41u);
}

TEST(CameraFragmentTests, RejectsNonCanonicalOffsetsAndTampering) {
  crypto::aes_t key(16, 3);
  auto misplaced = camera_fixture(key, 1, 1049, 550);
  crypto::cipher::gcm_t cipher(key, false);
  stream::camera_fragment_t fragment;
  fragment.frame_id = 99;
  EXPECT_FALSE(stream::decode_camera_fragment(
    std::string_view {(const char *) misplaced.data(), misplaced.size()}, cipher, fragment));
  EXPECT_EQ(fragment.frame_id, 99u);

  auto tampered = camera_fixture(key, 0, 0, 1050);
  tampered.back() ^= 1;
  EXPECT_FALSE(stream::decode_camera_fragment(
    std::string_view {(const char *) tampered.data(), tampered.size()}, cipher, fragment));
}

TEST(CameraFragmentTests, ReassemblesOutOfOrderAndDropsIncompleteOlderFrame) {
  stream::camera_frame_assembler_t assembler;
  stream::camera_fragment_t tail;
  tail.sequence = 11;
  tail.frame_id = 7;
  tail.timestamp_ms = 1234;
  tail.width = 640;
  tail.height = 480;
  tail.format = 1;
  tail.fragment_index = 1;
  tail.fragment_count = 2;
  tail.frame_length = 1600;
  tail.offset = 1050;
  tail.data.assign(550, 0x22);
  EXPECT_FALSE(assembler.accept(tail, 1000));

  auto head = tail;
  head.sequence = 10;
  head.fragment_index = 0;
  head.offset = 0;
  head.data.assign(1050, 0x11);
  auto complete = assembler.accept(head, 1001);
  ASSERT_TRUE(complete);
  ASSERT_EQ(complete->bytes.size(), 1600u);
  EXPECT_EQ(complete->bytes.front(), 0x11);
  EXPECT_EQ(complete->bytes.back(), 0x22);

  EXPECT_FALSE(assembler.accept(head, 1002));

  auto next = head;
  next.sequence = 12;
  next.frame_id = 8;
  next.timestamp_ms = 1334;
  EXPECT_FALSE(assembler.accept(next, 1003));

  auto stale = tail;
  stale.sequence = 13;
  EXPECT_FALSE(assembler.accept(stale, 1004));
}

TEST(CameraFragmentTests, ExpiresIncompleteFrameWithoutPublishingIt) {
  stream::camera_frame_assembler_t assembler;
  stream::camera_fragment_t fragment;
  fragment.sequence = 1;
  fragment.frame_id = 1;
  fragment.timestamp_ms = 5;
  fragment.width = 320;
  fragment.height = 240;
  fragment.format = 1;
  fragment.fragment_index = 0;
  fragment.fragment_count = 2;
  fragment.frame_length = 1200;
  fragment.offset = 0;
  fragment.data.assign(1050, 0xaa);
  EXPECT_FALSE(assembler.accept(fragment, 100));

  fragment.sequence = 2;
  fragment.fragment_index = 1;
  fragment.offset = 1050;
  fragment.data.assign(150, 0xbb);
  EXPECT_FALSE(assembler.accept(fragment, 601));
}

TEST(UsbCompatibilityTests, LegacyPortReturnsMigrationNotice) {
  constexpr std::uint16_t test_port = 48120;
  auto listener = usb_compat::start(test_port);
  boost::asio::io_context io;
  boost::asio::ip::tcp::socket socket(io);
  boost::system::error_code ec;
  socket.connect({boost::asio::ip::address_v4::loopback(), test_port}, ec);
  ASSERT_FALSE(ec) << ec.message();

  boost::asio::streambuf response;
  boost::asio::read_until(socket, response, '\n', ec);
  ASSERT_FALSE(ec) << ec.message();
  std::istream input(&response);
  std::string line;
  std::getline(input, line);
  EXPECT_NE(line.find("\"code\":\"moved\""), std::string::npos);
  EXPECT_NE(line.find("authenticated Helios streaming sessions"), std::string::npos);
}

TEST(QuicWireTests, RoundTripsStrictStreamPreface) {
  std::array<std::uint8_t, MLOS_QUIC_STREAM_PREFACE_SIZE> bytes {};
  ASSERT_TRUE(MlosQuicEncodeStreamPreface(bytes.data(), bytes.size(),
                                         MLOS_QUIC_STREAM_CONTROL, 0x1234));
  MLOS_QUIC_STREAM_PREFACE decoded {};
  ASSERT_TRUE(MlosQuicDecodeStreamPreface(bytes.data(), bytes.size(), &decoded));
  EXPECT_EQ(decoded.channel, MLOS_QUIC_STREAM_CONTROL);
  EXPECT_EQ(decoded.flags, 0x1234);

  bytes[8] = 1;
  decoded.channel = 99;
  EXPECT_FALSE(MlosQuicDecodeStreamPreface(bytes.data(), bytes.size(), &decoded));
  EXPECT_EQ(decoded.channel, 99);
}

TEST(QuicWireTests, RejectsMalformedDatagramWithoutMutatingOutput) {
  std::array<std::uint8_t, MLOS_QUIC_DATAGRAM_HEADER_SIZE + 3> bytes {};
  ASSERT_TRUE(MlosQuicEncodeDatagramHeader(bytes.data(), MLOS_QUIC_DATAGRAM_HEADER_SIZE,
                                          MLOS_QUIC_DATAGRAM_VIDEO, 7, 3));
  bytes[8] = 1;
  bytes[9] = 2;
  bytes[10] = 3;
  MLOS_QUIC_DATAGRAM_HEADER decoded {};
  ASSERT_TRUE(MlosQuicDecodeDatagramHeader(bytes.data(), bytes.size(), &decoded));
  EXPECT_EQ(decoded.channel, MLOS_QUIC_DATAGRAM_VIDEO);
  EXPECT_EQ(decoded.flags, 7);
  EXPECT_EQ(decoded.payloadLength, 3);

  bytes[7] = 4;
  decoded.channel = 88;
  EXPECT_FALSE(MlosQuicDecodeDatagramHeader(bytes.data(), bytes.size(), &decoded));
  EXPECT_EQ(decoded.channel, 88);
}

TEST(QuicWireTests, RoundTripsSessionAuthenticationRecord) {
  std::array<std::uint8_t, MLOS_QUIC_TOKEN_SIZE> token {};
  std::array<std::uint8_t, MLOS_QUIC_CERT_HASH_SIZE> certificate {};
  for (std::size_t i = 0; i < token.size(); ++i) {
    token[i] = static_cast<std::uint8_t>(i);
    certificate[i] = static_cast<std::uint8_t>(255 - i);
  }
  std::array<std::uint8_t, MLOS_QUIC_AUTH_SIZE> bytes {};
  ASSERT_TRUE(MlosQuicEncodeAuth(bytes.data(), bytes.size(), token.data(), certificate.data()));
  MLOS_QUIC_AUTH decoded {};
  ASSERT_TRUE(MlosQuicDecodeAuth(bytes.data(), bytes.size(), &decoded));
  EXPECT_TRUE(std::equal(token.begin(), token.end(), decoded.token));
  EXPECT_TRUE(std::equal(certificate.begin(), certificate.end(),
                        decoded.clientCertificateSha256));

  bytes[1] = 1;
  decoded.token[0] = 77;
  EXPECT_FALSE(MlosQuicDecodeAuth(bytes.data(), bytes.size(), &decoded));
  EXPECT_EQ(decoded.token[0], 77);
}

TEST(QuicNegotiationTests, AcceptsOnlyCanonicalOptInAndToken) {
  EXPECT_TRUE(quic_transport::requested("1"));
  EXPECT_FALSE(quic_transport::requested("true"));
  EXPECT_FALSE(quic_transport::requested("01"));

  quic_transport::token_t token {};
  for (std::size_t i = 0; i < token.size(); ++i) token[i] = static_cast<std::uint8_t>(i);
  const auto encoded = quic_transport::token_hex(token);
  ASSERT_EQ(encoded.size(), 64u);
  ASSERT_TRUE(quic_transport::parse_token(encoded));
  EXPECT_EQ(*quic_transport::parse_token(encoded), token);
  EXPECT_FALSE(quic_transport::parse_token(encoded.substr(1)));
  auto uppercase = encoded;
  uppercase[20] = 'A';
  EXPECT_FALSE(quic_transport::parse_token(uppercase));
  EXPECT_EQ(quic_transport::session_url("[::1]", 48003, token),
            "quic://[::1]:48003/" + encoded);
}

#ifdef HAVE_MSQUIC
TEST(QuicNegotiationTests, AllowsAuthenticatedSequentialRtspStreams) {
  EXPECT_TRUE(quic_transport::may_claim_stream_channel(
    0, MLOS_QUIC_STREAM_AUTH, false, false));
  EXPECT_FALSE(quic_transport::may_claim_stream_channel(
    1, MLOS_QUIC_STREAM_AUTH, true, true));
  EXPECT_FALSE(quic_transport::may_claim_stream_channel(
    1, MLOS_QUIC_STREAM_RTSP, false, false));
  EXPECT_TRUE(quic_transport::may_claim_stream_channel(
    1, MLOS_QUIC_STREAM_RTSP, true, true));
  EXPECT_TRUE(quic_transport::may_claim_stream_channel(
    2, MLOS_QUIC_STREAM_RTSP, true, true));
  EXPECT_FALSE(quic_transport::may_claim_stream_channel(
    2, MLOS_QUIC_STREAM_CONTROL, true, true));
}

TEST(QuicNegotiationTests, RecognizesMappedLoopbackProxyAddress) {
  const auto mapped = boost::asio::ip::make_address("::ffff:127.0.0.1");
  EXPECT_TRUE(net::normalize_address(mapped).is_loopback());
}
#endif

TEST(QuicNegotiationTests, TicketAuthorizationIsBoundToTokenAndCertificate) {
  quic_transport::ticket_t ticket {};
  for (std::size_t i = 0; i < ticket.token.size(); ++i) {
    ticket.token[i] = static_cast<std::uint8_t>(i + 1);
    ticket.client_certificate_sha256[i] = static_cast<std::uint8_t>(i + 7);
  }
  EXPECT_TRUE(quic_transport::authorize(ticket, ticket.token,
                                        ticket.client_certificate_sha256));
  auto wrong_token = ticket.token;
  wrong_token.back() ^= 1;
  EXPECT_FALSE(quic_transport::authorize(ticket, wrong_token,
                                         ticket.client_certificate_sha256));
  auto wrong_certificate = ticket.client_certificate_sha256;
  wrong_certificate.front() ^= 1;
  EXPECT_FALSE(quic_transport::authorize(ticket, ticket.token, wrong_certificate));
}

TEST(QuicNegotiationTests, TicketsAreSingleUseAndExpire) {
  using registry_t = quic_transport::ticket_registry_t;
  registry_t registry(std::chrono::seconds(5));
  registry_t::clock_t::time_point start {};
  quic_transport::ticket_t first {};
  first.token[0] = 1;
  first.client_certificate_sha256[0] = 2;
  first.launch_session_id = 42;
  registry.insert(first, start);
  EXPECT_EQ(registry.size(start), 1u);
  auto consumed = registry.consume(first.token, first.client_certificate_sha256, start);
  ASSERT_TRUE(consumed);
  EXPECT_EQ(consumed->launch_session_id, 42u);
  EXPECT_FALSE(registry.consume(first.token, first.client_certificate_sha256, start));

  quic_transport::ticket_t expired = first;
  expired.token[0] = 3;
  registry.insert(expired, start);
  EXPECT_EQ(registry.size(start + std::chrono::seconds(5)), 0u);
  EXPECT_FALSE(registry.consume(expired.token, expired.client_certificate_sha256,
                                start + std::chrono::seconds(5)));
}
