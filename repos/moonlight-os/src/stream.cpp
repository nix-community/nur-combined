/**
 * @file src/stream.cpp
 * @brief Definitions for the streaming protocols.
 */

// standard includes
#include <algorithm>
#include <condition_variable>
#include <deque>
#include <fstream>
#include <future>
#include <mutex>
#include <queue>
#include <set>

// lib includes
#include <boost/endian/arithmetic.hpp>
#include <openssl/err.h>
#include <opus/opus.h>

extern "C" {
  // clang-format off
#include <moonlight-common-c/src/Limelight-internal.h>
// nanors rs.h must precede rswrapper.h, whose macros would otherwise rewrite
// the real prototypes. It used to arrive transitively via RtpAudioQueue.h, but
// upstream moonlight-common-c replaced that include with a forward declaration,
// so we pull in the complete type (and DATA_SHARDS_MAX) ourselves.
#include <rs.h>
#include "rswrapper.h"
  // clang-format on
}

// local includes
#include "config.h"
#include "crypto.h"
#include "display_device.h"
#include "globals.h"
#include "input.h"
#include "logging.h"
#include "network.h"
#include "platform/common.h"
#include "process.h"
#include "stream.h"
#include "usb_backend.h"
#include "sync.h"
#include "system_tray.h"
#include "thread_safe.h"
#include "utility.h"

#define IDX_START_A 0
#define IDX_START_B 1
#define IDX_INVALIDATE_REF_FRAMES 2
#define IDX_LOSS_STATS 3
#define IDX_INPUT_DATA 5
#define IDX_RUMBLE_DATA 6
#define IDX_TERMINATION 7
#define IDX_PERIODIC_PING 8
#define IDX_REQUEST_IDR_FRAME 9
#define IDX_ENCRYPTED 10
#define IDX_HDR_MODE 11
#define IDX_RUMBLE_TRIGGER_DATA 12
#define IDX_SET_MOTION_EVENT 13
#define IDX_SET_RGB_LED 14
#define IDX_EXEC_SERVER_CMD 15
#define IDX_SET_CLIPBOARD 16
#define IDX_FILE_TRANSFER_NONCE_REQUEST 17
#define IDX_SET_ADAPTIVE_TRIGGERS 18
#define IDX_FEATURE_ADVERTISE 19
#define IDX_CLIPBOARD_OFFER 20
#define IDX_CLIPBOARD_REQUEST 21
#define IDX_CLIPBOARD_DATA 22
#define IDX_KEYBOARD_LAYOUT 23
#define IDX_USB_DEVICE_SYNC 24
#define IDX_USB_TUNNEL_OPEN 25
#define IDX_USB_TUNNEL_DATA 26
#define IDX_USB_TUNNEL_CLOSE 27
#define IDX_DISPLAY_TOPOLOGY 28
#define IDX_SYSTEM_DISK_OFFER 29
#define IDX_DISK_TUNNEL_OPEN 30
#define IDX_DISK_TUNNEL_DATA 31
#define IDX_DISK_TUNNEL_CLOSE 32

static const short packetTypes[] = {
  0x0305,  // Start A
  0x0307,  // Start B
  0x0301,  // Invalidate reference frames
  0x0201,  // Loss Stats
  0x0204,  // Frame Stats (unused)
  0x0206,  // Input data
  0x010b,  // Rumble data
  0x0109,  // Termination
  0x0200,  // Periodic Ping
  0x0302,  // IDR frame
  0x0001,  // fully encrypted
  0x010e,  // HDR mode
  0x5500,  // Rumble triggers (Helios protocol extension)
  0x5501,  // Set motion event (Helios protocol extension)
  0x5502,  // Set RGB LED (Helios protocol extension)
  0x3000,  // Execute Server Command (Helios protocol extension)
  0x3001,  // Set Clipboard (Helios protocol extension)
  0x3002,  // File transfer nonce request (Helios protocol extension)
  0x5503,  // Set Adaptive triggers (Helios protocol extension)
  0x6000,  // Feature advertisement (Moonlight OS protocol extension)
  0x6001,  // Clipboard offer (Moonlight OS protocol extension)
  0x6002,  // Clipboard request (Moonlight OS protocol extension)
  0x6003,  // Clipboard data (Moonlight OS protocol extension)
  0x6004,  // Keyboard layout (Moonlight OS protocol extension)
  0x6005,  // USB device sync (Moonlight OS protocol extension)
  0x6006,  // USB tunnel open (Moonlight OS protocol extension)
  0x6007,  // USB tunnel data (Moonlight OS protocol extension)
  0x6008,  // USB tunnel close (Moonlight OS protocol extension)
  0x6009,  // Display topology (Moonlight OS protocol extension)
  0x600a,  // Read-only system disk offer (Moonlight OS protocol extension)
  0x600b,  // System disk tunnel open (Moonlight OS protocol extension)
  0x600c,  // System disk tunnel data (Moonlight OS protocol extension)
  0x600d,  // System disk tunnel close (Moonlight OS protocol extension)
};

namespace asio = boost::asio;
namespace sys = boost::system;

using asio::ip::tcp;
using asio::ip::udp;

using namespace std::literals;

namespace stream {

  constexpr std::uint32_t microphone_packet_magic = 0x4D4C4D43u;
  constexpr std::size_t microphone_packet_header_size = 36;
  constexpr std::size_t microphone_max_opus_size = 1200;
  constexpr std::uint32_t camera_packet_magic = 0x4D4C4341u;
  constexpr std::size_t camera_packet_header_size = 36;
  constexpr std::size_t camera_fragment_header_size = 26;
  constexpr std::size_t camera_fragment_data_size = 1050;
  constexpr std::size_t camera_max_frame_size = 4 * 1024 * 1024;
  constexpr std::size_t display_topology_header_size = 8;
  constexpr std::size_t display_topology_entry_size = 32;
  constexpr std::size_t display_topology_max_displays = 16;

  static std::uint16_t read_be16(const std::uint8_t *bytes) {
    return (std::uint16_t) ((bytes[0] << 8) | bytes[1]);
  }

  static std::uint32_t read_be32(const std::uint8_t *bytes) {
    return ((std::uint32_t) bytes[0] << 24) | ((std::uint32_t) bytes[1] << 16) |
           ((std::uint32_t) bytes[2] << 8) | bytes[3];
  }

  static std::uint64_t read_be64(const std::uint8_t *bytes) {
    return ((std::uint64_t) read_be32(bytes) << 32) | read_be32(bytes + 4);
  }

  static std::uint16_t read_le16(const std::uint8_t *bytes) {
    return (std::uint16_t) (bytes[0] | ((std::uint16_t) bytes[1] << 8));
  }

  static std::uint32_t read_le32(const std::uint8_t *bytes) {
    return (std::uint32_t) bytes[0] | ((std::uint32_t) bytes[1] << 8) |
           ((std::uint32_t) bytes[2] << 16) | ((std::uint32_t) bytes[3] << 24);
  }

  static std::uint64_t read_le64(const std::uint8_t *bytes) {
    return (std::uint64_t) read_le32(bytes) | ((std::uint64_t) read_le32(bytes + 4) << 32);
  }

  bool parse_display_topology(std::string_view payload,
                              std::uint32_t &generation,
                              std::vector<display_desc_t> &displays) {
    if (payload.size() < display_topology_header_size) return false;
    auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
    if (bytes[0] != 1 || bytes[1] != 0) return false;
    std::uint16_t count = read_le16(bytes + 2);
    if (count == 0 || count > display_topology_max_displays ||
        payload.size() != display_topology_header_size + count * display_topology_entry_size) {
      return false;
    }
    std::vector<display_desc_t> parsed;
    parsed.reserve(count);
    std::size_t primary_count = 0;
    for (std::size_t i = 0; i < count; ++i) {
      auto p = bytes + display_topology_header_size + i * display_topology_entry_size;
      display_desc_t display;
      display.x = (std::int32_t) read_le32(p);
      display.y = (std::int32_t) read_le32(p + 4);
      display.width = read_le32(p + 8);
      display.height = read_le32(p + 12);
      display.refresh_millihz = read_le32(p + 16);
      display.scale_milli = read_le32(p + 20);
      display.physical_width_mm = read_le16(p + 24);
      display.physical_height_mm = read_le16(p + 26);
      display.flags = read_le16(p + 28);
      auto reserved = read_le16(p + 30);
      if (display.width == 0 || display.height == 0 ||
          display.x < -131072 || display.x > 131072 ||
          display.y < -131072 || display.y > 131072 ||
          display.width > 16384 || display.height > 16384 ||
          display.refresh_millihz < 1000 || display.refresh_millihz > 1000000 ||
          display.scale_milli < 250 || display.scale_milli > 8000 ||
          (display.flags & ~std::uint16_t {0x0003}) != 0 || reserved != 0) {
        return false;
      }
      if (display.flags & 0x0001) ++primary_count;
      parsed.push_back(display);
    }
    if (primary_count != 1) return false;
    generation = read_le32(bytes + 4);
    displays = std::move(parsed);
    return true;
  }

  bool parse_system_disk_offer(std::string_view payload,
                               system_disk_offer_t &offer) {
    constexpr std::size_t header_size = 20;
    constexpr std::size_t max_iqn_size = 223;
    if (payload.size() < header_size) return false;

    auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
    auto flags = bytes[1];
    auto iqn_size = read_le16(bytes + 2);
    if (bytes[0] != 1 || iqn_size > max_iqn_size ||
        payload.size() != header_size + iqn_size) {
      return false;
    }

    system_disk_offer_t parsed;
    parsed.generation = read_le32(bytes + 4);
    parsed.size = read_le64(bytes + 8);
    parsed.sector_size = read_le32(bytes + 16);

    if (iqn_size == 0) {
      if (flags != 0 || parsed.size != 0 || parsed.sector_size != 0) return false;
    } else {
      if (flags != 0x01 || parsed.size == 0 ||
          (parsed.sector_size != 512 && parsed.sector_size != 4096) ||
          parsed.size % parsed.sector_size != 0) {
        return false;
      }
      parsed.target_iqn.assign(payload.data() + header_size, iqn_size);
      if (!parsed.target_iqn.starts_with("iqn.") ||
          !std::all_of(parsed.target_iqn.begin(), parsed.target_iqn.end(), [](unsigned char ch) {
            return (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') ||
                   ch == '.' || ch == '-' || ch == ':';
          })) {
        return false;
      }
    }

    offer = std::move(parsed);
    return true;
  }

  std::optional<std::string> select_display_output(
    const std::vector<std::string> &output_names,
    std::uint16_t display_index) {
    if (display_index >= output_names.size() || output_names[display_index].empty()) {
      return std::nullopt;
    }
    return output_names[display_index];
  }

  bool parse_feature_advertisement(
    std::string_view payload,
    std::map<std::uint16_t, std::uint16_t> &features) {
    constexpr std::size_t header_size = 4;
    constexpr std::size_t entry_size = 4;
    constexpr std::size_t max_entries = 64;
    if (payload.size() < header_size) return false;
    auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
    auto count = (std::uint16_t) (bytes[2] | ((std::uint16_t) bytes[3] << 8));
    if (bytes[0] != 1 || bytes[1] != 0 || count > max_entries ||
        payload.size() != header_size + count * entry_size) {
      return false;
    }
    std::map<std::uint16_t, std::uint16_t> parsed;
    for (std::size_t i = 0; i < count; ++i) {
      auto off = header_size + i * entry_size;
      auto id = (std::uint16_t) (bytes[off] | ((std::uint16_t) bytes[off + 1] << 8));
      auto version = (std::uint16_t) (bytes[off + 2] | ((std::uint16_t) bytes[off + 3] << 8));
      if (id == 0 || version == 0 || !parsed.emplace(id, version).second) return false;
    }
    features = std::move(parsed);
    return true;
  }

  std::map<std::uint16_t, std::uint16_t> negotiate_features(
    const std::map<std::uint16_t, std::uint16_t> &advertised,
    const std::map<std::uint16_t, std::uint16_t> &supported) {
    std::map<std::uint16_t, std::uint16_t> negotiated;
    for (const auto &[id, version] : advertised) {
      auto local = supported.find(id);
      if (local != supported.end() && local->second == version) {
        negotiated.emplace(id, version);
      }
    }
    return negotiated;
  }

  std::map<std::uint16_t, std::uint16_t> host_supported_features(
    bool virtual_camera_available,
    bool virtual_display_topology_available) {
    std::map<std::uint16_t, std::uint16_t> features {
      {ML_FEATURE_CLIPBOARD, 1},
      {ML_FEATURE_KEYBOARD_LAYOUT, 1},
      {ML_FEATURE_USB_PASSTHROUGH, 1},
      {ML_FEATURE_MICROPHONE, 1},
      {ML_FEATURE_SYSTEM_DISK, 1},
    };
    if (virtual_camera_available) {
      features.emplace(ML_FEATURE_CAMERA, 1);
    }
    if (virtual_display_topology_available) {
      features.emplace(ML_FEATURE_DISPLAY_TOPOLOGY, 1);
    }
    return features;
  }

  bool decode_microphone_packet(std::string_view payload,
                                crypto::cipher::gcm_t &cipher,
                                microphone_packet_t &packet) {
    if (payload.size() < microphone_packet_header_size + 8 ||
        payload.size() > microphone_packet_header_size + 8 + microphone_max_opus_size) {
      return false;
    }
    auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
    if (read_be32(bytes) != microphone_packet_magic || bytes[4] != 1 || bytes[5] != 0 ||
        read_be16(bytes + 6) != payload.size()) {
      return false;
    }

    microphone_packet_t decoded;
    decoded.connect_data = read_be32(bytes + 8);
    decoded.sequence = read_be64(bytes + 12);
    crypto::aes_t iv(12, 0);
    for (int i = 0; i < 8; ++i) {
      iv[i] = bytes[12 + i];
    }
    iv[10] = 'M';
    iv[11] = 'C';

    std::vector<std::uint8_t> plaintext;
    if (cipher.decrypt(payload.substr(20), plaintext, &iv) < 0 ||
        plaintext.size() < 9 || plaintext.size() > 8 + microphone_max_opus_size) {
      return false;
    }
    decoded.timestamp = read_be32(plaintext.data());
    decoded.samples = read_be16(plaintext.data() + 4);
    decoded.channels = plaintext[6];
    if (plaintext[7] != 0 || decoded.samples < 120 || decoded.samples > 5760 ||
        (decoded.channels != 1 && decoded.channels != 2)) {
      return false;
    }
    decoded.opus.assign(plaintext.begin() + 8, plaintext.end());
    packet = std::move(decoded);
    return true;
  }

  bool decode_camera_fragment(std::string_view payload,
                              crypto::cipher::gcm_t &cipher,
                              camera_fragment_t &fragment) {
    if (payload.size() < camera_packet_header_size + camera_fragment_header_size + 1 ||
        payload.size() > camera_packet_header_size + camera_fragment_header_size +
                         camera_fragment_data_size) {
      return false;
    }
    auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
    if (read_be32(bytes) != camera_packet_magic || bytes[4] != 1 || bytes[5] != 0 ||
        read_be16(bytes + 6) != payload.size()) {
      return false;
    }

    camera_fragment_t decoded;
    decoded.connect_data = read_be32(bytes + 8);
    decoded.sequence = read_be64(bytes + 12);
    crypto::aes_t iv(12, 0);
    for (int i = 0; i < 8; ++i) {
      iv[i] = bytes[12 + i];
    }
    iv[10] = 'C';
    iv[11] = 'A';

    std::vector<std::uint8_t> plaintext;
    if (cipher.decrypt(payload.substr(20), plaintext, &iv) < 0 ||
        plaintext.size() < camera_fragment_header_size + 1 ||
        plaintext.size() > camera_fragment_header_size + camera_fragment_data_size) {
      return false;
    }

    decoded.frame_id = read_be32(plaintext.data());
    decoded.timestamp_ms = read_be32(plaintext.data() + 4);
    decoded.width = read_be16(plaintext.data() + 8);
    decoded.height = read_be16(plaintext.data() + 10);
    decoded.format = plaintext[12];
    decoded.fragment_index = read_be16(plaintext.data() + 14);
    decoded.fragment_count = read_be16(plaintext.data() + 16);
    decoded.frame_length = read_be32(plaintext.data() + 18);
    decoded.offset = read_be32(plaintext.data() + 22);
    decoded.data.assign(plaintext.begin() + camera_fragment_header_size, plaintext.end());

    if (plaintext[13] != 0 || decoded.format != 1 || decoded.width == 0 ||
        decoded.height == 0 || decoded.fragment_count == 0 ||
        decoded.fragment_index >= decoded.fragment_count || decoded.frame_length == 0 ||
        decoded.frame_length > camera_max_frame_size || decoded.offset >= decoded.frame_length ||
        decoded.data.empty() || decoded.data.size() > camera_fragment_data_size ||
        decoded.offset + decoded.data.size() > decoded.frame_length) {
      return false;
    }

    const auto expected_fragment_count =
      (decoded.frame_length + camera_fragment_data_size - 1) / camera_fragment_data_size;
    const auto expected_offset =
      static_cast<std::uint32_t>(decoded.fragment_index) * camera_fragment_data_size;
    const auto expected_size = std::min<std::size_t>(
      camera_fragment_data_size, decoded.frame_length - expected_offset);
    if (decoded.fragment_count != expected_fragment_count || decoded.offset != expected_offset ||
        decoded.data.size() != expected_size) return false;

    fragment = std::move(decoded);
    return true;
  }

  std::optional<camera_frame_t> camera_frame_assembler_t::accept(
    const camera_fragment_t &fragment, std::uint64_t arrival_ms) {
    if (fragment.fragment_count == 0 || fragment.fragment_index >= fragment.fragment_count ||
        fragment.frame_length == 0 || fragment.frame_length > camera_max_frame_size ||
        fragment.offset >= fragment.frame_length || fragment.data.empty() ||
        fragment.offset + fragment.data.size() > fragment.frame_length) return std::nullopt;
    const bool newer_frame = has_frame_ &&
                             static_cast<std::int32_t>(fragment.frame_id - frame_id_) > 0;
    if (has_frame_ && fragment.frame_id != frame_id_ && !newer_frame) return std::nullopt;

    if (!has_frame_ || newer_frame) {
      has_frame_ = true;
      frame_id_ = fragment.frame_id;
      timestamp_ms_ = fragment.timestamp_ms;
      width_ = fragment.width;
      height_ = fragment.height;
      fragment_count_ = fragment.fragment_count;
      frame_length_ = fragment.frame_length;
      bytes_.assign(fragment.frame_length, 0);
      received_.assign(fragment.fragment_count, false);
      received_count_ = 0;
      sequences_.clear();
      deadline_ms_ = arrival_ms + 500;
    } else if (arrival_ms > deadline_ms_ || fragment.timestamp_ms != timestamp_ms_ ||
               fragment.width != width_ || fragment.height != height_ ||
               fragment.fragment_count != fragment_count_ ||
               fragment.frame_length != frame_length_) {
      return std::nullopt;
    }

    if (!sequences_.insert(fragment.sequence).second || received_[fragment.fragment_index]) {
      return std::nullopt;
    }
    std::copy(fragment.data.begin(), fragment.data.end(), bytes_.begin() + fragment.offset);
    received_[fragment.fragment_index] = true;
    ++received_count_;
    if (received_count_ != received_.size()) return std::nullopt;

    camera_frame_t frame;
    frame.frame_id = frame_id_;
    frame.timestamp_ms = timestamp_ms_;
    frame.width = width_;
    frame.height = height_;
    frame.bytes = bytes_;
    return frame;
  }

  enum class socket_e : int {
    video,  ///< Video
    audio  ///< Audio
  };

#pragma pack(push, 1)

  struct video_short_frame_header_t {
    uint8_t *payload() {
      return (uint8_t *) (this + 1);
    }

    std::uint8_t headerType;  // Always 0x01 for short headers

    // Helios extension
    // Frame processing latency, in 1/10 ms units
    //     zero when the frame is repeated or there is no backend implementation
    boost::endian::little_uint16_at frame_processing_latency;

    // Currently known values:
    // 1 = Normal P-frame
    // 2 = IDR-frame
    // 4 = P-frame with intra-refresh blocks
    // 5 = P-frame after reference frame invalidation
    std::uint8_t frameType;

    // Length of the final packet payload for codecs that cannot handle
    // zero padding, such as AV1 (Helios extension).
    boost::endian::little_uint16_at lastPayloadLen;

    std::uint8_t unknown[2];
  };

  static_assert(
    sizeof(video_short_frame_header_t) == 8,
    "Short frame header must be 8 bytes"
  );

  struct video_packet_raw_t {
    uint8_t *payload() {
      return (uint8_t *) (this + 1);
    }

    RTP_PACKET rtp;
    char reserved[4];

    NV_VIDEO_PACKET packet;
  };

  struct video_packet_enc_prefix_t {
    std::uint8_t iv[12];  // 12-byte IV is ideal for AES-GCM
    std::uint32_t frameNumber;
    std::uint8_t tag[16];
  };

  struct audio_packet_t {
    RTP_PACKET rtp;
  };

  struct control_header_v2 {
    std::uint16_t type;
    std::uint16_t payloadLength;

    uint8_t *payload() {
      return (uint8_t *) (this + 1);
    }
  };

  struct control_terminate_t {
    control_header_v2 header;

    std::uint32_t ec;
  };

  struct control_rumble_t {
    control_header_v2 header;

    std::uint32_t useless;

    std::uint16_t id;
    std::uint16_t lowfreq;
    std::uint16_t highfreq;
  };

  struct control_rumble_triggers_t {
    control_header_v2 header;

    std::uint16_t id;
    std::uint16_t left;
    std::uint16_t right;
  };

  struct control_set_motion_event_t {
    control_header_v2 header;

    std::uint16_t id;
    std::uint16_t reportrate;
    std::uint8_t type;
  };

  struct control_set_rgb_led_t {
    control_header_v2 header;

    std::uint16_t id;
    std::uint8_t r;
    std::uint8_t g;
    std::uint8_t b;
  };

  struct control_adaptive_triggers_t {
    control_header_v2 header;

    std::uint16_t id;
    /**
     * 0x04 - Right trigger
     * 0x08 - Left trigger
     */
    std::uint8_t event_flags;
    std::uint8_t type_left;
    std::uint8_t type_right;
    std::uint8_t left[DS_EFFECT_PAYLOAD_SIZE];
    std::uint8_t right[DS_EFFECT_PAYLOAD_SIZE];
  };

  struct control_hdr_mode_t {
    control_header_v2 header;

    std::uint8_t enabled;

    // Helios protocol extension
    SS_HDR_METADATA metadata;
  };

  typedef struct control_encrypted_t {
    std::uint16_t encryptedHeaderType;  // Always LE 0x0001
    std::uint16_t length;  // sizeof(seq) + 16 byte tag + secondary header and data

    // seq is accepted as an arbitrary value in Moonlight
    std::uint32_t seq;  // Monotonically increasing sequence number (used as IV for AES-GCM)

    uint8_t *payload() {
      return (uint8_t *) (this + 1);
    }

    // encrypted control_header_v2 and payload data follow
  } *control_encrypted_p;

  struct audio_fec_packet_t {
    RTP_PACKET rtp;
    AUDIO_FEC_HEADER fecHeader;
  };

#pragma pack(pop)

  constexpr std::size_t round_to_pkcs7_padded(std::size_t size) {
    return ((size + 15) / 16) * 16;
  }

  constexpr std::size_t MAX_AUDIO_PACKET_SIZE = 1400;

  using audio_aes_t = std::array<char, round_to_pkcs7_padded(MAX_AUDIO_PACKET_SIZE)>;

  using av_session_id_t = std::variant<asio::ip::address, std::string>;  // IP address or SS-Ping-Payload from RTSP handshake
  using message_queue_t = std::shared_ptr<safe::queue_t<std::pair<udp::endpoint, std::string>>>;
  using message_queue_queue_t = std::shared_ptr<safe::queue_t<std::tuple<socket_e, av_session_id_t, message_queue_t>>>;

  // return bytes written on success
  // return -1 on error
  static inline int encode_audio(bool encrypted, const audio::buffer_t &plaintext, uint8_t *destination, crypto::aes_t &iv, crypto::cipher::cbc_t &cbc) {
    // If encryption isn't enabled
    if (!encrypted) {
      std::copy(std::begin(plaintext), std::end(plaintext), destination);
      return plaintext.size();
    }

    return cbc.encrypt(std::string_view {(char *) std::begin(plaintext), plaintext.size()}, destination, &iv);
  }

  static inline void while_starting_do_nothing(std::atomic<session::state_e> &state) {
    while (state.load(std::memory_order_acquire) == session::state_e::STARTING) {
      std::this_thread::sleep_for(1ms);
    }
  }

  class control_server_t {
  public:
    int bind(net::af_e address_family, std::uint16_t port) {
      _host = net::host_create(address_family, _addr, port);

      return !(bool) _host;
    }

    // Get session associated with address.
    // If none are found, try to find a session not yet claimed. (It will be marked by a port of value 0
    // If none of those are found, return nullptr
    session_t *get_session(const net::peer_t peer, uint32_t connect_data);

    // Circular dependency:
    //   iterate refers to session
    //   session refers to broadcast_ctx_t
    //   broadcast_ctx_t refers to control_server_t
    // Therefore, iterate is implemented further down the source file
    void iterate(std::chrono::milliseconds timeout);

    /**
     * @brief Call the handler for a given control stream message.
     * @param type The message type.
     * @param session The session the message was received on.
     * @param payload The payload of the message.
     * @param reinjected `true` if this message is being reprocessed after decryption.
     */
    void call(std::uint16_t type, session_t *session, const std::string_view &payload, bool reinjected);

    void map(uint16_t type, std::function<void(session_t *, const std::string_view &)> cb) {
      _map_type_cb.emplace(type, std::move(cb));
    }

    int send(const std::string_view &payload, net::peer_t peer, std::uint8_t channel = CTRL_CHANNEL_GENERIC) {
      std::lock_guard<std::mutex> lock(_enet_mutex);
      auto packet = enet_packet_create(payload.data(), payload.size(), ENET_PACKET_FLAG_RELIABLE);
      if (enet_peer_send(peer, channel, packet)) {
        enet_packet_destroy(packet);

        return -1;
      }

      return 0;
    }

    void flush() {
      std::lock_guard<std::mutex> lock(_enet_mutex);
      enet_host_flush(_host.get());
    }

    // Callbacks
    std::unordered_map<std::uint16_t, std::function<void(session_t *, const std::string_view &)>> _map_type_cb;

    // All active sessions (including those still waiting for a peer to connect)
    sync_util::sync_t<std::vector<session_t *>> _sessions;

    // ENet peer to session mapping for sessions with a peer connected
    sync_util::sync_t<std::map<net::peer_t, session_t *>> _peer_to_session;

    ENetAddress _addr;
    net::host_t _host;
    std::mutex _enet_mutex;
  };

  struct broadcast_ctx_t {
    message_queue_queue_t message_queue_queue;

    std::thread recv_thread;
    std::thread video_thread;
    std::thread audio_thread;
    std::thread control_thread;

    asio::io_context io_context;

    udp::socket video_sock {io_context};
    udp::socket audio_sock {io_context};
    udp::socket microphone_sock {io_context};
    udp::socket camera_sock {io_context};

    control_server_t control_server;
  };

  struct display_topology_state_t {
    std::unique_ptr<platf::virtual_display_topology_t> provider;
    std::vector<std::string> output_names;
    std::mutex mutex;
    std::condition_variable ready_cv;
    bool ready = false;
  };

  static std::mutex display_topology_registry_mutex;
  static std::map<std::string, std::weak_ptr<display_topology_state_t>> display_topology_registry;

  static std::shared_ptr<display_topology_state_t> display_topology_for_device(
    const std::string &device_uuid) {
    std::lock_guard registry_lock {display_topology_registry_mutex};
    auto &entry = display_topology_registry[device_uuid];
    auto state = entry.lock();
    if (!state) {
      state = std::make_shared<display_topology_state_t>();
      entry = state;
    }
    return state;
  }

  struct session_t {
    config_t config;

    safe::mail_t mail;

    std::shared_ptr<input::input_t> input;

    std::thread audioThread;
    std::thread videoThread;

    std::chrono::steady_clock::time_point pingTimeout;

    safe::shared_t<broadcast_ctx_t>::ptr_t broadcast_ref;

    boost::asio::ip::address localAddress;

    // What this client said it supports, keyed by feature id and holding the
    // version it advertised. Empty until its advertisement arrives, and empty
    // forever for a client that predates feature negotiation -- which reads
    // the same way and is the correct answer for both.
    std::map<std::uint16_t, std::uint16_t> peer_features;

    // The clipboard offer this host has asked for and is still waiting on.
    // Data arriving for any other sequence belongs to an offer that has since
    // been replaced, and applying it would let a slow transfer overwrite a
    // newer copy.
    std::uint32_t clipboard_pending_seq = 0;

    // The XKB layout the client says it types on, e.g. "fr"/"azerty". Empty
    // until it says so, and empty forever for a client that does not send it.
    std::string keyboard_layout;
    std::string keyboard_variant;

    std::uint32_t display_topology_generation = 0;
    std::vector<display_desc_t> displays;
    std::shared_ptr<display_topology_state_t> display_topology;

    // The complete USB set most recently offered by this session. This is
    // declarative state: when a later generation omits a device, the USB
    // backend must detach it. Keeping it on the session is also what gives
    // disconnect cleanup an unambiguous owner.
    std::uint32_t usb_offer_generation = 0;
    std::vector<usb_device_t> usb_devices;
    std::unique_ptr<struct usb_tunnel_server_t> usb_tunnel;
    std::unique_ptr<usb_backend_t> usb_backend;

    std::uint32_t system_disk_offer_generation = 0;
    system_disk_offer_t system_disk_offer;
    std::unique_ptr<struct usb_tunnel_server_t> system_disk_tunnel;
    std::unique_ptr<system_disk_backend_t> system_disk_backend;

    struct {
      std::optional<crypto::cipher::gcm_t> cipher;
      OpusDecoder *decoder = nullptr;
      std::unique_ptr<platf::virtual_microphone_t> sink;
      std::uint64_t last_sequence = 0;
      bool has_sequence = false;
      bool first_frame_logged = false;
    } microphone;

    struct {
      std::optional<crypto::cipher::gcm_t> cipher;
      std::unique_ptr<platf::virtual_camera_t> sink;
      camera_frame_assembler_t assembler;
      bool first_frame_logged = false;
    } camera;

    ~session_t();

    struct {
      std::string ping_payload;

      int lowseq;
      udp::endpoint peer;

      std::optional<crypto::cipher::gcm_t> cipher;
      std::uint64_t gcm_iv_counter;

      safe::mail_raw_t::event_t<bool> idr_events;
      safe::mail_raw_t::event_t<std::pair<int64_t, int64_t>> invalidate_ref_frames_events;

      std::unique_ptr<platf::deinit_t> qos;
    } video;

    struct {
      crypto::cipher::cbc_t cipher;
      std::string ping_payload;

      std::uint16_t sequenceNumber;
      // avRiKeyId == util::endian::big(First (sizeof(avRiKeyId)) bytes of launch_session->iv)
      std::uint32_t avRiKeyId;
      std::uint32_t timestamp;
      udp::endpoint peer;

      util::buffer_t<char> shards;
      util::buffer_t<uint8_t *> shards_p;

      audio_fec_packet_t fec_packet;
      std::unique_ptr<platf::deinit_t> qos;
    } audio;

    struct {
      crypto::cipher::gcm_t cipher;
      crypto::aes_t legacy_input_enc_iv;  // Only used when the client doesn't support full control stream encryption
      crypto::aes_t incoming_iv;
      crypto::aes_t outgoing_iv;

      std::uint32_t connect_data;  // Used for new clients with ML_FF_SESSION_ID_V1
      std::string expected_peer_address;  // Only used for legacy clients without ML_FF_SESSION_ID_V1

      net::peer_t peer;
      std::uint32_t seq;
      std::mutex send_mutex;

      platf::feedback_queue_t feedback_queue;
      safe::mail_raw_t::event_t<video::hdr_info_t> hdr_queue;
    } control;

    std::uint32_t launch_session_id;
    std::string device_name;
    std::string device_uuid;
    std::weak_ptr<session_t> self;
    crypto::PERM permission;

    std::list<crypto::command_entry_t> do_cmds;
    std::list<crypto::command_entry_t> undo_cmds;

    safe::mail_raw_t::event_t<bool> shutdown_event;
    safe::signal_t controlEnd;

    std::atomic<session::state_e> state;
  };

  /**
   * First part of cipher must be struct of type control_encrypted_t
   *
   * returns empty string_view on failure
   * returns string_view pointing to payload data
   */
  template<std::size_t max_payload_size>
  static inline std::string_view encode_control(session_t *session, const std::string_view &plaintext, std::array<std::uint8_t, max_payload_size> &tagged_cipher) {
    static_assert(
      max_payload_size >= sizeof(control_encrypted_t) + sizeof(crypto::cipher::tag_size),
      "max_payload_size >= sizeof(control_encrypted_t) + sizeof(crypto::cipher::tag_size)"
    );

    if (session->config.controlProtocolType != 13) {
      return plaintext;
    }

    // USB tunnel readers send from worker threads while clipboard/HDR/control
    // messages can be emitted by the main stream thread. The sequence and GCM
    // IV are a single ordered stream and must be advanced atomically.
    std::lock_guard<std::mutex> send_lock(session->control.send_mutex);
    auto seq = session->control.seq++;

    auto &iv = session->control.outgoing_iv;
    if (session->config.encryptionFlagsEnabled & SS_ENC_CONTROL_V2) {
      // We use the deterministic IV construction algorithm specified in NIST SP 800-38D
      // Section 8.2.1. The sequence number is our "invocation" field and the 'CH' in the
      // high bytes is the "fixed" field. Because each client provides their own unique
      // key, our values in the fixed field need only uniquely identify each independent
      // use of the client's key with AES-GCM in our code.
      //
      // The sequence number is 32 bits long which allows for 2^32 control stream messages
      // to be sent to each client before the IV repeats.
      iv.resize(12);
      std::copy_n((uint8_t *) &seq, sizeof(seq), std::begin(iv));
      iv[10] = 'H';  // Host originated
      iv[11] = 'C';  // Control stream
    } else {
      // Nvidia's old style encryption uses a 16-byte IV
      iv.resize(16);

      iv[0] = (std::uint8_t) seq;
    }

    auto packet = (control_encrypted_p) tagged_cipher.data();

    auto bytes = session->control.cipher.encrypt(plaintext, packet->payload(), &iv);
    if (bytes <= 0) {
      BOOST_LOG(error) << "Couldn't encrypt control data"sv;
      return {};
    }

    std::uint16_t packet_length = bytes + crypto::cipher::tag_size + sizeof(control_encrypted_t::seq);

    packet->encryptedHeaderType = util::endian::little(0x0001);
    packet->length = util::endian::little(packet_length);
    packet->seq = util::endian::little(seq);

    return std::string_view {(char *) tagged_cipher.data(), packet_length + sizeof(control_encrypted_t) - sizeof(control_encrypted_t::seq)};
  }

  constexpr std::size_t usb_tunnel_chunk_size = 16384;
  constexpr std::size_t usb_tunnel_queue_limit = 1024 * 1024;
  constexpr std::uint16_t usb_close_normal = 0;
  constexpr std::uint16_t usb_close_io_error = 2;
  constexpr std::uint16_t usb_close_protocol_error = 3;

  static bool send_usb_tunnel_packet(control_server_t *server, session_t *session,
                                     std::uint16_t type, const void *body, std::size_t body_size) {
    constexpr std::size_t plaintext_capacity = sizeof(control_header_v2) + 8 + usb_tunnel_chunk_size;
    if (!session->control.peer || body_size > plaintext_capacity - sizeof(control_header_v2)) {
      return false;
    }

    std::array<std::uint8_t, plaintext_capacity> plaintext {};
    auto header = reinterpret_cast<control_header_v2 *>(plaintext.data());
    header->type = type;
    header->payloadLength = (std::uint16_t) body_size;
    std::memcpy(plaintext.data() + sizeof(control_header_v2), body, body_size);

    std::array<std::uint8_t,
      sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(plaintext_capacity) + crypto::cipher::tag_size>
      encrypted_payload;
    auto encoded = encode_control(session,
      std::string_view {(const char *) plaintext.data(), sizeof(control_header_v2) + body_size},
      encrypted_payload);
    return !encoded.empty() && server->send(encoded, session->control.peer, CTRL_CHANNEL_USB) == 0;
  }

  static bool send_tunnel_open(control_server_t *server, session_t *session,
                               std::uint16_t type, std::uint32_t id) {
    std::array<std::uint8_t, 8> body {};
    body[0] = (std::uint8_t) id;
    body[1] = (std::uint8_t) (id >> 8);
    body[2] = (std::uint8_t) (id >> 16);
    body[3] = (std::uint8_t) (id >> 24);
    return send_usb_tunnel_packet(server, session, type, body.data(), body.size());
  }

  static bool send_tunnel_data(control_server_t *server, session_t *session,
                               std::uint16_t type, std::uint32_t id,
                               const void *data, std::uint16_t length) {
    if (data == nullptr || length == 0 || length > usb_tunnel_chunk_size) {
      return false;
    }
    std::array<std::uint8_t, 8 + usb_tunnel_chunk_size> body {};
    body[0] = (std::uint8_t) id;
    body[1] = (std::uint8_t) (id >> 8);
    body[2] = (std::uint8_t) (id >> 16);
    body[3] = (std::uint8_t) (id >> 24);
    body[4] = (std::uint8_t) length;
    body[5] = (std::uint8_t) (length >> 8);
    std::memcpy(body.data() + 8, data, length);
    return send_usb_tunnel_packet(server, session, type, body.data(), 8 + length);
  }

  static bool send_tunnel_close(control_server_t *server, session_t *session,
                                std::uint16_t type, std::uint32_t id,
                                std::uint16_t reason) {
    std::array<std::uint8_t, 8> body {};
    body[0] = (std::uint8_t) id;
    body[1] = (std::uint8_t) (id >> 8);
    body[2] = (std::uint8_t) (id >> 16);
    body[3] = (std::uint8_t) (id >> 24);
    body[4] = (std::uint8_t) reason;
    body[5] = (std::uint8_t) (reason >> 8);
    return send_usb_tunnel_packet(server, session, type, body.data(), body.size());
  }

  struct usb_tunnel_server_t {
    struct tunnel_t {
      std::uint32_t id;
      std::shared_ptr<tcp::socket> socket;
      std::mutex mutex;
      std::condition_variable wake;
      std::deque<std::string> pending;
      std::size_t queued_bytes = 0;
      std::atomic<bool> closed {false};
      std::thread reader;
      std::thread writer;
    };

    control_server_t *server;
    session_t *session;
    asio::io_context io;
    tcp::acceptor acceptor;
    std::atomic<bool> stopping {false};
    std::atomic<std::uint32_t> next_id {1};
    std::mutex mutex;
    std::map<std::uint32_t, std::shared_ptr<tunnel_t>> tunnels;
    std::thread accept_thread;
    std::uint16_t open_type;
    std::uint16_t data_type;
    std::uint16_t close_type;
    std::string label;

    usb_tunnel_server_t(control_server_t *server_, session_t *session_,
                        std::uint16_t open_type_ = packetTypes[IDX_USB_TUNNEL_OPEN],
                        std::uint16_t data_type_ = packetTypes[IDX_USB_TUNNEL_DATA],
                        std::uint16_t close_type_ = packetTypes[IDX_USB_TUNNEL_CLOSE],
                        std::string label_ = "USB")
      : server(server_), session(session_), acceptor(io, tcp::endpoint(asio::ip::address_v4::loopback(), 0)),
        open_type(open_type_), data_type(data_type_), close_type(close_type_), label(std::move(label_)) {
      sys::error_code ec;
      acceptor.non_blocking(true, ec);
      if (ec) {
        throw sys::system_error(ec);
      }
      accept_thread = std::thread([this] { accept_loop(); });
    }

    ~usb_tunnel_server_t() {
      stop();
    }

    std::uint16_t port() const {
      sys::error_code ec;
      auto endpoint = acceptor.local_endpoint(ec);
      return ec ? 0 : endpoint.port();
    }

    void finish(const std::shared_ptr<tunnel_t> &tunnel, std::uint16_t reason, bool notify) {
      if (tunnel->closed.exchange(true)) {
        return;
      }
      sys::error_code ec;
      tunnel->socket->shutdown(tcp::socket::shutdown_both, ec);
      tunnel->socket->close(ec);
      tunnel->wake.notify_all();
      if (notify && !stopping) {
        send_tunnel_close(server, session, close_type, tunnel->id, reason);
      }
    }

    void accept_loop() {
      while (!stopping) {
        auto socket = std::make_shared<tcp::socket>(io);
        sys::error_code ec;
        acceptor.accept(*socket, ec);
        if (ec) {
          if (ec == asio::error::would_block || ec == asio::error::try_again) {
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
            continue;
          }
          if (!stopping) {
            BOOST_LOG(warning) << label << " tunnel accept failed: "sv << ec.message();
          }
          continue;
        }
        if (stopping) {
          socket->close(ec);
          break;
        }

        auto tunnel = std::make_shared<tunnel_t>();
        tunnel->id = next_id.fetch_add(1);
        tunnel->socket = std::move(socket);
        std::vector<std::shared_ptr<tunnel_t>> finished;
        bool rejected = false;
        {
          std::lock_guard<std::mutex> lock(mutex);
          for (auto it = tunnels.begin(); it != tunnels.end();) {
            if (it->second->closed) {
              finished.push_back(it->second);
              it = tunnels.erase(it);
            } else {
              ++it;
            }
          }
          if (tunnels.size() >= 16 || tunnel->id == 0) {
            rejected = true;
          } else {
            tunnels.emplace(tunnel->id, tunnel);
          }
        }
        for (const auto &old : finished) {
          if (old->reader.joinable()) old->reader.join();
          if (old->writer.joinable()) old->writer.join();
        }
        if (rejected) {
          finish(tunnel, usb_close_protocol_error, false);
          continue;
        }

        if (!send_tunnel_open(server, session, open_type, tunnel->id)) {
          finish(tunnel, usb_close_io_error, false);
          continue;
        }

        tunnel->reader = std::thread([this, tunnel] {
          std::array<char, usb_tunnel_chunk_size> buffer;
          while (!tunnel->closed) {
            sys::error_code ec;
            auto count = tunnel->socket->read_some(asio::buffer(buffer), ec);
            if (ec || count == 0 || !send_tunnel_data(server, session, data_type, tunnel->id,
                                                       buffer.data(), (std::uint16_t) count)) {
              finish(tunnel, ec == asio::error::eof ? usb_close_normal : usb_close_io_error, true);
              break;
            }
          }
        });

        tunnel->writer = std::thread([this, tunnel] {
          for (;;) {
            std::string chunk;
            {
              std::unique_lock<std::mutex> lock(tunnel->mutex);
              tunnel->wake.wait(lock, [&] { return tunnel->closed || !tunnel->pending.empty(); });
              if (tunnel->closed && tunnel->pending.empty()) {
                break;
              }
              chunk = std::move(tunnel->pending.front());
              tunnel->queued_bytes -= chunk.size();
              tunnel->pending.pop_front();
            }
            sys::error_code ec;
            asio::write(*tunnel->socket, asio::buffer(chunk), ec);
            if (ec) {
              finish(tunnel, usb_close_io_error, true);
              break;
            }
          }
        });
      }
    }

    void write(std::uint32_t id, std::string_view data) {
      std::shared_ptr<tunnel_t> tunnel;
      {
        std::lock_guard<std::mutex> lock(mutex);
        auto it = tunnels.find(id);
        if (it == tunnels.end()) {
          send_tunnel_close(server, session, close_type, id, usb_close_protocol_error);
          return;
        }
        tunnel = it->second;
      }
      std::lock_guard<std::mutex> lock(tunnel->mutex);
      if (tunnel->closed) {
        return;
      }
      if (data.empty() || data.size() > usb_tunnel_chunk_size ||
          tunnel->queued_bytes + data.size() > usb_tunnel_queue_limit) {
        finish(tunnel, usb_close_protocol_error, true);
        return;
      }
      tunnel->pending.emplace_back(data);
      tunnel->queued_bytes += data.size();
      tunnel->wake.notify_one();
    }

    void close(std::uint32_t id) {
      std::shared_ptr<tunnel_t> tunnel;
      {
        std::lock_guard<std::mutex> lock(mutex);
        auto it = tunnels.find(id);
        if (it == tunnels.end()) {
          return;
        }
        tunnel = it->second;
      }
      finish(tunnel, usb_close_normal, false);
    }

    void stop() {
      auto wake_port = port();
      if (stopping.exchange(true)) {
        return;
      }
      sys::error_code ec;
      if (wake_port != 0 && acceptor.is_open()) {
        asio::io_context wake_io;
        tcp::socket wake_socket(wake_io);
        wake_socket.connect(tcp::endpoint(asio::ip::address_v4::loopback(), wake_port), ec);
      }
      if (accept_thread.joinable()) {
        accept_thread.join();
      }
      acceptor.close(ec);
      std::vector<std::shared_ptr<tunnel_t>> all;
      {
        std::lock_guard<std::mutex> lock(mutex);
        for (const auto &item : tunnels) {
          all.push_back(item.second);
        }
      }
      for (const auto &tunnel : all) {
        finish(tunnel, usb_close_normal, false);
      }
      for (const auto &tunnel : all) {
        if (tunnel->reader.joinable()) tunnel->reader.join();
        if (tunnel->writer.joinable()) tunnel->writer.join();
      }
    }
  };

  session_t::~session_t() {
    // Stop workers while the control cipher, peer, and server session are
    // still alive; member destruction order alone would tear those down first.
    // Reconciliation receives an empty final set and finishes its detach pass
    // before the loopback tunnel is taken away.
    system_disk_backend.reset();
    system_disk_tunnel.reset();
    usb_backend.reset();
    usb_tunnel.reset();
    microphone.sink.reset();
    display_topology.reset();
    if (microphone.decoder) {
      opus_decoder_destroy(microphone.decoder);
      microphone.decoder = nullptr;
    }
  }

  bool parse_usb_tunnel_data(const std::string_view &payload,
                             std::uint32_t &id,
                             std::string_view &data) {
    if (payload.size() < 8) {
      return false;
    }
    auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
    auto length = (std::uint16_t) (bytes[4] | ((std::uint16_t) bytes[5] << 8));
    auto reserved = (std::uint16_t) (bytes[6] | ((std::uint16_t) bytes[7] << 8));
    if (length == 0 || length > usb_tunnel_chunk_size || reserved != 0 || payload.size() != 8 + length) {
      return false;
    }
    id = bytes[0] | ((std::uint32_t) bytes[1] << 8) |
         ((std::uint32_t) bytes[2] << 16) | ((std::uint32_t) bytes[3] << 24);
    if (id == 0) {
      return false;
    }
    data = payload.substr(8, length);
    return true;
  }

  bool parse_usb_tunnel_close(const std::string_view &payload,
                              std::uint32_t &id,
                              std::uint16_t &reason) {
    if (payload.size() != 8) {
      return false;
    }
    auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
    auto reserved = (std::uint16_t) (bytes[6] | ((std::uint16_t) bytes[7] << 8));
    auto parsed_id = bytes[0] | ((std::uint32_t) bytes[1] << 8) |
                     ((std::uint32_t) bytes[2] << 16) | ((std::uint32_t) bytes[3] << 24);
    if (parsed_id == 0 || reserved != 0) {
      return false;
    }
    id = parsed_id;
    reason = bytes[4] | ((std::uint16_t) bytes[5] << 8);
    return true;
  }

  int start_broadcast(broadcast_ctx_t &ctx);
  void end_broadcast(broadcast_ctx_t &ctx);

  static auto broadcast = safe::make_shared<broadcast_ctx_t>(start_broadcast, end_broadcast);

  session_t *control_server_t::get_session(const net::peer_t peer, uint32_t connect_data) {
    {
      // Fast path - look up existing session by peer
      auto lg = _peer_to_session.lock();
      auto it = _peer_to_session->find(peer);
      if (it != _peer_to_session->end()) {
        return it->second;
      }
    }

    // Slow path - process new session
    TUPLE_2D(peer_port, peer_addr, platf::from_sockaddr_ex((sockaddr *) &peer->address.address));
    auto lg = _sessions.lock();
    for (auto pos = std::begin(*_sessions); pos != std::end(*_sessions); ++pos) {
      auto session_p = *pos;

      // Skip sessions that are already established
      if (session_p->control.peer) {
        continue;
      }

      // Identify the connection by the unique connect data if the client supports it.
      // Only fall back to IP address matching for clients without session ID support.
      if (session_p->config.mlFeatureFlags & ML_FF_SESSION_ID_V1) {
        if (session_p->control.connect_data != connect_data) {
          continue;
        } else {
          BOOST_LOG(debug) << "Initialized new control stream session by connect data match [v2]"sv;
        }
      } else {
        if (session_p->control.expected_peer_address != peer_addr) {
          continue;
        } else {
          BOOST_LOG(debug) << "Initialized new control stream session by IP address match [v1]"sv;
        }
      }

      // Once the control stream connection is established, RTSP session state can be torn down
      rtsp_stream::launch_session_clear(session_p->launch_session_id);

      session_p->control.peer = peer;

      // Use the local address from the control connection as the source address
      // for other communications to the client. This is necessary to ensure
      // proper routing on multi-homed hosts.
      auto local_address = platf::from_sockaddr((sockaddr *) &peer->localAddress.address);
      session_p->localAddress = boost::asio::ip::make_address(local_address);

      BOOST_LOG(debug) << "Control local address ["sv << local_address << ']';
      BOOST_LOG(debug) << "Control peer address ["sv << peer_addr << ':' << peer_port << ']';

      // Insert this into the map for O(1) lookups in the future
      auto ptslg = _peer_to_session.lock();
      _peer_to_session->emplace(peer, session_p);
      return session_p;
    }

    return nullptr;
  }

  /**
   * @brief Call the handler for a given control stream message.
   * @param type The message type.
   * @param session The session the message was received on.
   * @param payload The payload of the message.
   * @param reinjected `true` if this message is being reprocessed after decryption.
   */
  void control_server_t::call(std::uint16_t type, session_t *session, const std::string_view &payload, bool reinjected) {
    // If we are using the encrypted control stream protocol, drop any messages that come off the wire unencrypted
    if (session->config.controlProtocolType == 13 && !reinjected && type != packetTypes[IDX_ENCRYPTED]) {
      BOOST_LOG(error) << "Dropping unencrypted message on encrypted control stream: "sv << util::hex(type).to_string_view();
      return;
    }

    auto cb = _map_type_cb.find(type);
    if (cb == std::end(_map_type_cb)) {
      BOOST_LOG(debug)
        << "type [Unknown] { "sv << util::hex(type).to_string_view() << " }"sv << std::endl
        << "---data---"sv << std::endl
        << util::hex_vec(payload) << std::endl
        << "---end data---"sv;
    } else {
      cb->second(session, payload);
    }
  }

  void control_server_t::iterate(std::chrono::milliseconds timeout) {
    ENetEvent event;
    int res;
    {
      std::lock_guard<std::mutex> lock(_enet_mutex);
      res = enet_host_service(_host.get(), &event, timeout.count());
    }

    if (res > 0) {
      auto session = get_session(event.peer, event.data);
      if (!session) {
        BOOST_LOG(warning) << "Rejected connection from ["sv << platf::from_sockaddr((sockaddr *) &event.peer->address.address) << "]: it's not properly set up"sv;
        enet_peer_disconnect_now(event.peer, 0);

        return;
      }

      session->pingTimeout = std::chrono::steady_clock::now() + config::stream.ping_timeout;

      switch (event.type) {
        case ENET_EVENT_TYPE_RECEIVE:
          {
            net::packet_t packet {event.packet};

            auto type = *(std::uint16_t *) packet->data;
            std::string_view payload {(char *) packet->data + sizeof(type), packet->dataLength - sizeof(type)};

            call(type, session, payload, false);
          }
          break;
        case ENET_EVENT_TYPE_CONNECT:
          BOOST_LOG(info) << "CLIENT CONNECTED"sv;
          break;
        case ENET_EVENT_TYPE_DISCONNECT:
          BOOST_LOG(info) << "CLIENT DISCONNECTED"sv;
          // No more clients to send video data to ^_^
          if (session->state == session::state_e::RUNNING) {
            session::stop(*session);
          }
          break;
        case ENET_EVENT_TYPE_NONE:
          break;
      }
    }
  }

  namespace fec {
    using rs_t = util::safe_ptr<reed_solomon, [](reed_solomon *rs) {
      reed_solomon_release(rs);
    }>;

    struct fec_t {
      size_t data_shards;
      size_t nr_shards;
      size_t percentage;

      size_t blocksize;
      size_t prefixsize;
      util::buffer_t<char> shards;
      util::buffer_t<char> headers;
      util::buffer_t<uint8_t *> shards_p;

      std::vector<platf::buffer_descriptor_t> payload_buffers;

      char *data(size_t el) {
        return (char *) shards_p[el];
      }

      char *prefix(size_t el) {
        return prefixsize ? &headers[el * prefixsize] : nullptr;
      }

      size_t size() const {
        return nr_shards;
      }
    };

    static fec_t encode(const std::string_view &payload, size_t blocksize, size_t fecpercentage, size_t minparityshards, size_t prefixsize) {
      auto payload_size = payload.size();

      auto pad = payload_size % blocksize != 0;

      auto aligned_data_shards = payload_size / blocksize;
      auto data_shards = aligned_data_shards + (pad ? 1 : 0);
      auto parity_shards = (data_shards * fecpercentage + 99) / 100;

      // increase the FEC percentage for this frame if the parity shard minimum is not met
      if (parity_shards < minparityshards && fecpercentage != 0) {
        parity_shards = minparityshards;
        fecpercentage = (100 * parity_shards) / data_shards;

        BOOST_LOG(verbose) << "Increasing FEC percentage to "sv << fecpercentage << " to meet parity shard minimum"sv << std::endl;
      }

      auto nr_shards = data_shards + parity_shards;

      // If we need to store a zero-padded data shard, allocate that first to
      // to keep the shards in order and reduce buffer fragmentation
      auto parity_shard_offset = pad ? 1 : 0;
      util::buffer_t<char> shards {(parity_shard_offset + parity_shards) * blocksize};
      util::buffer_t<uint8_t *> shards_p {nr_shards};
      std::vector<platf::buffer_descriptor_t> payload_buffers;
      payload_buffers.reserve(2);

      // Point into the payload buffer for all except the final padded data shard
      auto next = std::begin(payload);
      for (auto x = 0; x < aligned_data_shards; ++x) {
        shards_p[x] = (uint8_t *) next;
        next += blocksize;
      }
      payload_buffers.emplace_back(std::begin(payload), aligned_data_shards * blocksize);

      // If the last data shard needs to be zero-padded, we must use the shards buffer
      if (pad) {
        shards_p[aligned_data_shards] = (uint8_t *) &shards[0];

        // GCC doesn't figure out that std::copy_n() can be replaced with memcpy() here
        // and ends up compiling a horribly slow element-by-element copy loop, so we
        // help it by using memcpy()/memset() directly.
        auto copy_len = std::min<size_t>(blocksize, std::end(payload) - next);
        std::memcpy(shards_p[aligned_data_shards], next, copy_len);
        if (copy_len < blocksize) {
          // Zero any additional space after the end of the payload
          std::memset(shards_p[aligned_data_shards] + copy_len, 0, blocksize - copy_len);
        }
      }

      // Add a payload buffer describing the shard buffer
      payload_buffers.emplace_back(std::begin(shards), shards.size());

      if (fecpercentage != 0) {
        // Point into our allocated buffer for the parity shards
        for (auto x = 0; x < parity_shards; ++x) {
          shards_p[data_shards + x] = (uint8_t *) &shards[(parity_shard_offset + x) * blocksize];
        }

        // packets = parity_shards + data_shards
        rs_t rs {reed_solomon_new(data_shards, parity_shards)};

        reed_solomon_encode(rs.get(), shards_p.begin(), nr_shards, blocksize);
      }

      return {
        data_shards,
        nr_shards,
        fecpercentage,
        blocksize,
        prefixsize,
        std::move(shards),
        util::buffer_t<char> {nr_shards * prefixsize},
        std::move(shards_p),
        std::move(payload_buffers),
      };
    }
  }  // namespace fec

  bool parse_usb_device_offer(const std::string_view &payload,
                              std::uint32_t &generation,
                              std::vector<usb_device_t> &devices) {
    constexpr std::size_t header_size = 8;
    constexpr std::size_t entry_header_size = 8;
    constexpr std::uint16_t max_devices = 64;
    constexpr std::uint16_t max_busid = 32;
    constexpr std::uint16_t max_hwid = 16;
    constexpr std::uint16_t max_label = 128;

    if (payload.size() < header_size) {
      return false;
    }

    auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
    if (bytes[0] != 1 || bytes[1] != 0) {
      return false;
    }

    auto read16 = [bytes](std::size_t at) -> std::uint16_t {
      return bytes[at] | ((std::uint16_t) bytes[at + 1] << 8);
    };
    auto read32 = [bytes](std::size_t at) -> std::uint32_t {
      return bytes[at] | ((std::uint32_t) bytes[at + 1] << 8) |
             ((std::uint32_t) bytes[at + 2] << 16) | ((std::uint32_t) bytes[at + 3] << 24);
    };

    std::uint16_t count = read16(2);
    if (count > max_devices) {
      return false;
    }

    std::vector<usb_device_t> parsed;
    parsed.reserve(count);
    std::size_t at = header_size;
    for (std::uint16_t i = 0; i < count; ++i) {
      if (at > payload.size() || payload.size() - at < entry_header_size) {
        return false;
      }

      std::uint16_t busid_len = read16(at);
      std::uint16_t hwid_len = read16(at + 2);
      std::uint16_t label_len = read16(at + 4);
      // The final uint16 is reserved and must remain zero until a newer
      // message version assigns it semantics.
      if (read16(at + 6) != 0) {
        return false;
      }
      at += entry_header_size;

      std::size_t strings_len = (std::size_t) busid_len + hwid_len + label_len;
      if (busid_len == 0 || busid_len > max_busid || hwid_len > max_hwid ||
          label_len > max_label || strings_len > payload.size() - at) {
        return false;
      }

      usb_device_t device;
      device.busid.assign(payload.data() + at, busid_len);
      at += busid_len;
      device.hwid.assign(payload.data() + at, hwid_len);
      at += hwid_len;
      device.label.assign(payload.data() + at, label_len);
      at += label_len;

      bool valid_busid = device.busid.find_first_not_of("0123456789-.") == std::string::npos &&
                         device.busid.front() != '.' && device.busid.back() != '.';
      bool duplicate = std::any_of(parsed.begin(), parsed.end(), [&device](const auto &other) {
        return other.busid == device.busid;
      });
      if (!valid_busid || duplicate) {
        return false;
      }
      parsed.emplace_back(std::move(device));
    }

    // Version 1 has no trailer. Rejecting one catches corrupted lengths and
    // keeps future additions behind a version bump rather than accidental
    // interpretation by an old host.
    if (at != payload.size()) {
      return false;
    }

    generation = read32(4);
    devices = std::move(parsed);
    return true;
  }

  std::vector<usb_sync_action_t> plan_usb_device_sync(
    const std::vector<usb_attachment_t> &current,
    const std::vector<usb_device_t> &offered) {
    std::vector<usb_sync_action_t> actions;
    actions.reserve(current.size() + offered.size());

    // Attach the missing desired set first. Both inputs are bounded by the
    // USB/IP table/protocol, so straightforward scans keep ordering explicit
    // and avoid letting a map silently discard a malformed duplicate.
    for (const auto &device : offered) {
      auto present = std::any_of(current.begin(), current.end(), [&](const auto &attachment) {
        return attachment.busid == device.busid;
      });
      if (!present) {
        actions.push_back({usb_sync_action_e::attach, device, -1});
      }
    }

    // Then remove every stale imported port. Detach is port-based because the
    // USB/IP client assigns a local vhci port that is distinct from the remote
    // bus id, and re-reading that table before execution remains mandatory.
    for (const auto &attachment : current) {
      auto wanted = std::any_of(offered.begin(), offered.end(), [&](const auto &device) {
        return device.busid == attachment.busid;
      });
      if (!wanted) {
        actions.push_back({usb_sync_action_e::detach,
                           {attachment.busid, {}, {}},
                           attachment.port});
      }
    }

    return actions;
  }

  /**
   * @brief Combines two buffers and inserts new buffers at each slice boundary of the result.
   * @param insert_size The number of bytes to insert.
   * @param slice_size The number of bytes between insertions.
   * @param data1 The first data buffer.
   * @param data2 The second data buffer.
   */
  std::vector<uint8_t> concat_and_insert(uint64_t insert_size, uint64_t slice_size, const std::string_view &data1, const std::string_view &data2) {
    auto data_size = data1.size() + data2.size();
    auto pad = data_size % slice_size != 0;
    auto elements = data_size / slice_size + (pad ? 1 : 0);

    std::vector<uint8_t> result;
    result.resize(elements * insert_size + data_size);

    auto next = std::begin(data1);
    auto end = std::end(data1);
    for (auto x = 0; x < elements; ++x) {
      void *p = &result[x * (insert_size + slice_size)];

      // For the last iteration, only copy to the end of the data
      if (x == elements - 1) {
        slice_size = data_size - (x * slice_size);
      }

      // Test if this slice will extend into the next buffer
      if (next + slice_size > end) {
        // Copy the first portion from the first buffer
        auto copy_len = end - next;
        std::copy(next, end, (char *) p + insert_size);

        // Copy the remaining portion from the second buffer
        next = std::begin(data2);
        end = std::end(data2);
        std::copy(next, next + (slice_size - copy_len), (char *) p + copy_len + insert_size);
        next += slice_size - copy_len;
      } else {
        std::copy(next, next + slice_size, (char *) p + insert_size);
        next += slice_size;
      }
    }

    return result;
  }

  std::vector<uint8_t> replace(const std::string_view &original, const std::string_view &old, const std::string_view &_new) {
    std::vector<uint8_t> replaced;
    replaced.reserve(original.size() + _new.size() - old.size());

    auto begin = std::begin(original);
    auto end = std::end(original);
    auto next = std::search(begin, end, std::begin(old), std::end(old));

    std::copy(begin, next, std::back_inserter(replaced));
    if (next != end) {
      std::copy(std::begin(_new), std::end(_new), std::back_inserter(replaced));
      std::copy(next + old.size(), end, std::back_inserter(replaced));
    }

    return replaced;
  }

  /**
   * @brief Pass gamepad feedback data back to the client.
   * @param session The session object.
   * @param msg The message to pass.
   * @return 0 on success.
   */
  int send_feedback_msg(session_t *session, platf::gamepad_feedback_msg_t &msg) {
    if (!session->control.peer) {
      BOOST_LOG(warning) << "Couldn't send gamepad feedback data, still waiting for PING from Moonlight"sv;
      // Still waiting for PING from Moonlight
      return -1;
    }

    std::string payload;
    if (msg.type == platf::gamepad_feedback_e::rumble) {
      control_rumble_t plaintext;
      plaintext.header.type = packetTypes[IDX_RUMBLE_DATA];
      plaintext.header.payloadLength = sizeof(plaintext) - sizeof(control_header_v2);

      auto &data = msg.data.rumble;

      plaintext.useless = 0xC0FFEE;
      plaintext.id = util::endian::little(msg.id);
      plaintext.lowfreq = util::endian::little(data.lowfreq);
      plaintext.highfreq = util::endian::little(data.highfreq);

      BOOST_LOG(verbose) << "Rumble: "sv << msg.id << " :: "sv << util::hex(data.lowfreq).to_string_view() << " :: "sv << util::hex(data.highfreq).to_string_view();
      std::array<std::uint8_t, sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(sizeof(plaintext)) + crypto::cipher::tag_size>
        encrypted_payload;

      payload = encode_control(session, util::view(plaintext), encrypted_payload);
    } else if (msg.type == platf::gamepad_feedback_e::rumble_triggers) {
      control_rumble_triggers_t plaintext;
      plaintext.header.type = packetTypes[IDX_RUMBLE_TRIGGER_DATA];
      plaintext.header.payloadLength = sizeof(plaintext) - sizeof(control_header_v2);

      auto &data = msg.data.rumble_triggers;

      plaintext.id = util::endian::little(msg.id);
      plaintext.left = util::endian::little(data.left_trigger);
      plaintext.right = util::endian::little(data.right_trigger);

      BOOST_LOG(verbose) << "Rumble triggers: "sv << msg.id << " :: "sv << util::hex(data.left_trigger).to_string_view() << " :: "sv << util::hex(data.right_trigger).to_string_view();
      std::array<std::uint8_t, sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(sizeof(plaintext)) + crypto::cipher::tag_size>
        encrypted_payload;

      payload = encode_control(session, util::view(plaintext), encrypted_payload);
    } else if (msg.type == platf::gamepad_feedback_e::set_motion_event_state) {
      control_set_motion_event_t plaintext;
      plaintext.header.type = packetTypes[IDX_SET_MOTION_EVENT];
      plaintext.header.payloadLength = sizeof(plaintext) - sizeof(control_header_v2);

      auto &data = msg.data.motion_event_state;

      plaintext.id = util::endian::little(msg.id);
      plaintext.reportrate = util::endian::little(data.report_rate);
      plaintext.type = data.motion_type;

      BOOST_LOG(verbose) << "Motion event state: "sv << msg.id << " :: "sv << util::hex(data.report_rate).to_string_view() << " :: "sv << util::hex(data.motion_type).to_string_view();
      std::array<std::uint8_t, sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(sizeof(plaintext)) + crypto::cipher::tag_size>
        encrypted_payload;

      payload = encode_control(session, util::view(plaintext), encrypted_payload);
    } else if (msg.type == platf::gamepad_feedback_e::set_rgb_led) {
      control_set_rgb_led_t plaintext;
      plaintext.header.type = packetTypes[IDX_SET_RGB_LED];
      plaintext.header.payloadLength = sizeof(plaintext) - sizeof(control_header_v2);

      auto &data = msg.data.rgb_led;

      plaintext.id = util::endian::little(msg.id);
      plaintext.r = data.r;
      plaintext.g = data.g;
      plaintext.b = data.b;

      BOOST_LOG(verbose) << "RGB: "sv << msg.id << " :: "sv << util::hex(data.r).to_string_view() << util::hex(data.g).to_string_view() << util::hex(data.b).to_string_view();
      std::array<std::uint8_t, sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(sizeof(plaintext)) + crypto::cipher::tag_size>
        encrypted_payload;

      payload = encode_control(session, util::view(plaintext), encrypted_payload);
    } else if (msg.type == platf::gamepad_feedback_e::set_adaptive_triggers) {
      control_adaptive_triggers_t plaintext;
      plaintext.header.type = packetTypes[IDX_SET_ADAPTIVE_TRIGGERS];
      plaintext.header.payloadLength = sizeof(plaintext) - sizeof(control_header_v2);

      plaintext.id = util::endian::little(msg.id);
      plaintext.event_flags = msg.data.adaptive_triggers.event_flags;
      plaintext.type_left = msg.data.adaptive_triggers.type_left;
      std::ranges::copy(msg.data.adaptive_triggers.left, plaintext.left);
      plaintext.type_right = msg.data.adaptive_triggers.type_right;
      std::ranges::copy(msg.data.adaptive_triggers.right, plaintext.right);

      std::array<std::uint8_t, sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(sizeof(plaintext)) + crypto::cipher::tag_size>
        encrypted_payload;

      payload = encode_control(session, util::view(plaintext), encrypted_payload);
    } else {
      BOOST_LOG(error) << "Unknown gamepad feedback message type"sv;
      return -1;
    }

    if (session->broadcast_ref->control_server.send(payload, session->control.peer)) {
      TUPLE_2D(port, addr, platf::from_sockaddr_ex((sockaddr *) &session->control.peer->address.address));
      BOOST_LOG(warning) << "Couldn't send gamepad feedback to ["sv << addr << ':' << port << ']';

      return -1;
    }

    return 0;
  }

  int send_hdr_mode(session_t *session, video::hdr_info_t hdr_info) {
    if (!session->control.peer) {
      BOOST_LOG(warning) << "Couldn't send HDR mode, still waiting for PING from Moonlight"sv;
      // Still waiting for PING from Moonlight
      return -1;
    }

    control_hdr_mode_t plaintext {};
    plaintext.header.type = packetTypes[IDX_HDR_MODE];
    plaintext.header.payloadLength = sizeof(control_hdr_mode_t) - sizeof(control_header_v2);

    plaintext.enabled = hdr_info->enabled;
    plaintext.metadata = hdr_info->metadata;

    std::array<std::uint8_t, sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(sizeof(plaintext)) + crypto::cipher::tag_size>
      encrypted_payload;

    auto payload = encode_control(session, util::view(plaintext), encrypted_payload);
    if (session->broadcast_ref->control_server.send(payload, session->control.peer)) {
      TUPLE_2D(port, addr, platf::from_sockaddr_ex((sockaddr *) &session->control.peer->address.address));
      BOOST_LOG(warning) << "Couldn't send HDR mode to ["sv << addr << ':' << port << ']';

      return -1;
    }

    BOOST_LOG(debug) << "Sent HDR mode: " << hdr_info->enabled;
    return 0;
  }

  /**
   * @brief Ask the client for the contents of a clipboard offer it made.
   */
  void send_clipboard_request(control_server_t *server, session_t *session, std::uint32_t seq, std::uint16_t format) {
    if (!session->control.peer) {
      return;
    }

    constexpr std::size_t body_size = 8;
    std::array<std::uint8_t, sizeof(control_header_v2) + body_size> plaintext {};

    auto header = reinterpret_cast<control_header_v2 *>(plaintext.data());
    header->type = packetTypes[IDX_CLIPBOARD_REQUEST];
    header->payloadLength = body_size;

    auto body = plaintext.data() + sizeof(control_header_v2);
    body[0] = (std::uint8_t) (seq & 0xFF);
    body[1] = (std::uint8_t) ((seq >> 8) & 0xFF);
    body[2] = (std::uint8_t) ((seq >> 16) & 0xFF);
    body[3] = (std::uint8_t) ((seq >> 24) & 0xFF);
    body[4] = (std::uint8_t) (format & 0xFF);
    body[5] = (std::uint8_t) (format >> 8);

    std::array<std::uint8_t, sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(plaintext.size()) + crypto::cipher::tag_size>
      encrypted_payload;
    auto encoded = encode_control(session, std::string_view {(const char *) plaintext.data(), plaintext.size()}, encrypted_payload);

    if (server->send(encoded, session->control.peer)) {
      BOOST_LOG(warning) << "Couldn't request the clipboard from ["sv << session->device_name << ']';
    }
  }

  /**
   * @brief Answer a client's clipboard request.
   *
   * The buffers here are heap allocated, unlike every other control message in
   * this file: a clipboard can legitimately be megabytes, and encode_control is
   * a template over std::array, so the alternative would be putting the
   * protocol's whole maximum on the stack for every send.
   */
  void send_clipboard_data(control_server_t *server, session_t *session, std::uint32_t seq, std::uint16_t format, const std::string &content) {
    if (!session->control.peer) {
      return;
    }

    constexpr std::size_t max_content = 4 * 1024 * 1024;  // ML_CLIPBOARD_MAX_BYTES
    constexpr std::size_t header_size = 12;

    if (content.size() > max_content) {
      BOOST_LOG(warning) << "Refusing to send a "sv << content.size() << " byte clipboard"sv;
      return;
    }

    auto plaintext_size = sizeof(control_header_v2) + header_size + content.size();
    auto plaintext = std::make_unique<std::uint8_t[]>(plaintext_size);

    auto header = reinterpret_cast<control_header_v2 *>(plaintext.get());
    header->type = packetTypes[IDX_CLIPBOARD_DATA];
    header->payloadLength = (std::uint16_t) (header_size + content.size());

    auto body = plaintext.get() + sizeof(control_header_v2);
    auto put32 = [](std::uint8_t *at, std::uint32_t v) {
      at[0] = (std::uint8_t) (v & 0xFF);
      at[1] = (std::uint8_t) ((v >> 8) & 0xFF);
      at[2] = (std::uint8_t) ((v >> 16) & 0xFF);
      at[3] = (std::uint8_t) ((v >> 24) & 0xFF);
    };

    put32(body, seq);
    body[4] = (std::uint8_t) (format & 0xFF);
    body[5] = (std::uint8_t) (format >> 8);
    body[6] = 0;
    body[7] = 0;
    put32(body + 8, (std::uint32_t) content.size());
    std::memcpy(body + header_size, content.data(), content.size());

    using clipboard_buffer_t = std::array<std::uint8_t,
                                          sizeof(control_encrypted_t) +
                                            crypto::cipher::round_to_pkcs7_padded(sizeof(control_header_v2) + header_size + max_content) +
                                            crypto::cipher::tag_size>;
    auto encrypted_payload = std::make_unique<clipboard_buffer_t>();
    auto encoded = encode_control(session, std::string_view {(const char *) plaintext.get(), plaintext_size}, *encrypted_payload);

    if (server->send(encoded, session->control.peer)) {
      BOOST_LOG(warning) << "Couldn't send the clipboard to ["sv << session->device_name << ']';
    }
    else {
      BOOST_LOG(info) << "Sent "sv << content.size() << " clipboard bytes to ["sv << session->device_name << ']';
    }
  }

  /**
   * @brief The host clipboard as we last saw it, and the sequence to label the next offer with.
   *
   * Host-wide rather than per session, because the clipboard is: two clients
   * watching the same desktop are looking at one selection.
   *
   * This is also half of the loop prevention. When a client's text is applied
   * here, it is recorded as already seen, so the watcher below does not notice
   * it as a fresh local copy and offer it straight back to the client it came
   * from. The client keeps the matching guard on its own side.
   */
  std::string last_seen_clipboard;
  std::uint32_t clipboard_offer_seq = 0;

  /**
   * @brief Tell a client that the host clipboard changed, without sending it.
   */
  void send_clipboard_offer(control_server_t *server, session_t *session, std::uint32_t seq, std::uint32_t size_hint) {
    if (!session->control.peer) {
      return;
    }

    constexpr std::size_t body_size = 8 + 6;  // header + one format entry
    std::array<std::uint8_t, sizeof(control_header_v2) + body_size> plaintext {};

    auto header = reinterpret_cast<control_header_v2 *>(plaintext.data());
    header->type = packetTypes[IDX_CLIPBOARD_OFFER];
    header->payloadLength = body_size;

    auto body = plaintext.data() + sizeof(control_header_v2);
    auto put32 = [](std::uint8_t *at, std::uint32_t v) {
      at[0] = (std::uint8_t) (v & 0xFF);
      at[1] = (std::uint8_t) ((v >> 8) & 0xFF);
      at[2] = (std::uint8_t) ((v >> 16) & 0xFF);
      at[3] = (std::uint8_t) ((v >> 24) & 0xFF);
    };

    put32(body, seq);
    body[4] = 1;  // one format
    body[5] = 0;
    body[6] = 0;
    body[7] = 0;
    body[8] = (std::uint8_t) (ML_CLIPBOARD_FORMAT_TEXT_UTF8 & 0xFF);
    body[9] = (std::uint8_t) (ML_CLIPBOARD_FORMAT_TEXT_UTF8 >> 8);
    put32(body + 10, size_hint);

    std::array<std::uint8_t, sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(plaintext.size()) + crypto::cipher::tag_size>
      encrypted_payload;
    auto encoded = encode_control(session, std::string_view {(const char *) plaintext.data(), plaintext.size()}, encrypted_payload);

    if (server->send(encoded, session->control.peer)) {
      BOOST_LOG(warning) << "Couldn't offer the clipboard to ["sv << session->device_name << ']';
    }
  }

  /**
   * @brief Notice a copy made on the host and offer it to every client that can take it.
   *
   * Polled, because there is no portable way to be told: reading the selection
   * means asking the compositor, and wl-paste has no "notify me" that survives
   * not being a session client. One second is chosen to keep that round trip
   * off the 150ms control tick -- a clipboard is not latency sensitive.
   */
  void poll_host_clipboard(control_server_t *server) {
    static auto last_poll = std::chrono::steady_clock::now();

    auto now = std::chrono::steady_clock::now();
    if (now - last_poll < std::chrono::seconds(1)) {
      return;
    }
    last_poll = now;

    // Only pay for the read if somebody is listening for the answer.
    bool anyone_wants_it = false;
    for (auto pos = std::begin(*server->_sessions); pos != std::end(*server->_sessions); ++pos) {
      auto session = *pos;
      if (session->control.peer &&
          session->peer_features.count(ML_FEATURE_CLIPBOARD) &&
          !!(session->permission & crypto::PERM::clipboard_read)) {
        anyone_wants_it = true;
        break;
      }
    }

    if (!anyone_wants_it) {
      return;
    }

    auto content = platf::get_clipboard();
    if (content.empty() || content == last_seen_clipboard) {
      return;
    }

    last_seen_clipboard = content;
    ++clipboard_offer_seq;

    for (auto pos = std::begin(*server->_sessions); pos != std::end(*server->_sessions); ++pos) {
      auto session = *pos;
      if (session->control.peer &&
          session->peer_features.count(ML_FEATURE_CLIPBOARD) &&
          !!(session->permission & crypto::PERM::clipboard_read)) {
        send_clipboard_offer(server, session, clipboard_offer_seq, (std::uint32_t) content.size());
      }
    }
  }

  void controlBroadcastThread(control_server_t *server) {
    server->map(packetTypes[IDX_PERIODIC_PING], [](session_t *session, const std::string_view &payload) {
      BOOST_LOG(verbose) << "type [IDX_PERIODIC_PING]"sv;
    });

    server->map(packetTypes[IDX_START_A], [&](session_t *session, const std::string_view &payload) {
      BOOST_LOG(debug) << "type [IDX_START_A]"sv;
    });

    server->map(packetTypes[IDX_START_B], [&](session_t *session, const std::string_view &payload) {
      BOOST_LOG(debug) << "type [IDX_START_B]"sv;
    });

    server->map(packetTypes[IDX_LOSS_STATS], [&](session_t *session, const std::string_view &payload) {
      int32_t *stats = (int32_t *) payload.data();
      auto count = stats[0];
      std::chrono::milliseconds t {stats[1]};

      auto lastGoodFrame = stats[3];

      BOOST_LOG(verbose)
        << "type [IDX_LOSS_STATS]"sv << std::endl
        << "---begin stats---" << std::endl
        << "loss count since last report [" << count << ']' << std::endl
        << "time in milli since last report [" << t.count() << ']' << std::endl
        << "last good frame [" << lastGoodFrame << ']' << std::endl
        << "---end stats---";
    });

    server->map(packetTypes[IDX_REQUEST_IDR_FRAME], [&](session_t *session, const std::string_view &payload) {
      BOOST_LOG(debug) << "type [IDX_REQUEST_IDR_FRAME]"sv;

      session->video.idr_events->raise(true);
    });

    server->map(packetTypes[IDX_INVALIDATE_REF_FRAMES], [&](session_t *session, const std::string_view &payload) {
      auto frames = (std::int64_t *) payload.data();
      auto firstFrame = frames[0];
      auto lastFrame = frames[1];

      BOOST_LOG(debug)
        << "type [IDX_INVALIDATE_REF_FRAMES]"sv << std::endl
        << "firstFrame [" << firstFrame << ']' << std::endl
        << "lastFrame [" << lastFrame << ']';

      session->video.invalidate_ref_frames_events->raise(std::make_pair(firstFrame, lastFrame));
    });

    server->map(packetTypes[IDX_INPUT_DATA], [&](session_t *session, const std::string_view &payload) {
      BOOST_LOG(debug) << "type [IDX_INPUT_DATA]"sv;

      auto tagged_cipher_length = util::endian::big(*(int32_t *) payload.data());
      std::string_view tagged_cipher {payload.data() + sizeof(tagged_cipher_length), (size_t) tagged_cipher_length};

      std::vector<uint8_t> plaintext;

      auto &cipher = session->control.cipher;
      auto &iv = session->control.legacy_input_enc_iv;
      if (cipher.decrypt(tagged_cipher, plaintext, &iv)) {
        // something went wrong :(

        BOOST_LOG(error) << "Failed to verify tag"sv;

        session::stop(*session);
        return;
      }

      if (tagged_cipher_length >= 16 + iv.size()) {
        std::copy(payload.end() - 16, payload.end(), std::begin(iv));
      }

      input::passthrough(session->input, std::move(plaintext), session->permission);
    });

    server->map(packetTypes[IDX_EXEC_SERVER_CMD], [server](session_t *session, const std::string_view &payload) {
      BOOST_LOG(debug) << "type [IDX_EXEC_SERVER_CMD]"sv;

      if (!(session->permission & crypto::PERM::server_cmd)) {
        BOOST_LOG(debug) << "Permission Exec Server Cmd deined for [" << session->device_name << "]";
        return;
      }

      uint8_t cmdIndex = *(uint8_t*)payload.data();

      if (cmdIndex < config::helios.server_cmds.size()) {
        const auto& cmd = config::helios.server_cmds[cmdIndex];
        BOOST_LOG(info) << "Executing server command: " << cmd.cmd_name;

        auto exec_thread = std::thread([&cmd]{
          std::error_code ec;
          auto env = proc::proc.get_env();
          boost::filesystem::path working_dir = proc::find_working_directory(cmd.cmd_val, env);
          auto child = platf::run_command(cmd.elevated, true, cmd.cmd_val, working_dir, env, nullptr, ec, nullptr);

          if (ec) {
            BOOST_LOG(error) << "Failed to execute server command: " << ec.message();
          } else {
            child.detach();
          }
        });

        exec_thread.detach();
      } else {
        BOOST_LOG(error) << "Invalid server command index: " << (int)cmdIndex;
      }
    });

    // Feature negotiation. Both ends send the same message, so this handler
    // records what the client can do and answers with what Helios can do.
    //
    // Wire format, little-endian:
    //   uint8 format version (1) | uint8 reserved | uint16 count
    //   count x { uint16 featureId; uint16 featureVersion }
    server->map(packetTypes[IDX_FEATURE_ADVERTISE], [server](session_t *session, const std::string_view &payload) {
      auto local_features = host_supported_features(
        platf::virtual_camera_available(),
        platf::virtual_display_topology_available());
      constexpr std::uint8_t format_version = 1;
      constexpr std::size_t header_size = 4;
      constexpr std::size_t entry_size = 4;
      std::map<std::uint16_t, std::uint16_t> features;
      if (!parse_feature_advertisement(payload, features)) {
        BOOST_LOG(warning) << "Ignoring malformed feature advertisement from ["sv
                           << session->device_name << ']';
        return;
      }
      session->peer_features = negotiate_features(features, local_features);

      BOOST_LOG(info) << "Client ["sv << session->device_name << "] advertised "sv
                      << session->peer_features.size() << " feature(s)"sv;

      // Answer with the exact feature versions this build implements.
      // Fixed capacity rather than a vector: encode_control is a template over
      // std::array, so the buffer size has to be a constant. Sized for the
      // most features Helios could advertise, and only the used prefix is sent.
      constexpr std::size_t max_local_features = 16;
      constexpr std::size_t plaintext_capacity =
        sizeof(control_header_v2) + header_size + max_local_features * entry_size;

      if (local_features.size() > max_local_features) {
        BOOST_LOG(error) << "More local features than the advertisement buffer holds"sv;
        return;
      }

      std::array<std::uint8_t, plaintext_capacity> plaintext {};
      std::size_t plaintext_used = sizeof(control_header_v2) + header_size + local_features.size() * entry_size;

      auto header = reinterpret_cast<control_header_v2 *>(plaintext.data());
      header->type = packetTypes[IDX_FEATURE_ADVERTISE];
      header->payloadLength = (std::uint16_t) (plaintext_used - sizeof(control_header_v2));

      auto body = plaintext.data() + sizeof(control_header_v2);
      body[0] = format_version;
      body[1] = 0;
      body[2] = (std::uint8_t) (local_features.size() & 0xFF);
      body[3] = (std::uint8_t) (local_features.size() >> 8);

      for (std::size_t i = 0; i < local_features.size(); ++i) {
        auto off = header_size + i * entry_size;
        auto feature = std::next(local_features.begin(), i);
        body[off] = (std::uint8_t) (feature->first & 0xFF);
        body[off + 1] = (std::uint8_t) (feature->first >> 8);
        body[off + 2] = (std::uint8_t) (feature->second & 0xFF);
        body[off + 3] = (std::uint8_t) (feature->second >> 8);
      }

      if (!session->control.peer) {
        return;
      }

      std::array<std::uint8_t,
                 sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(plaintext_capacity) + crypto::cipher::tag_size>
        encrypted_payload;
      auto encoded = encode_control(session,
                                    std::string_view {(const char *) plaintext.data(), plaintext_used},
                                    encrypted_payload);

      if (server->send(encoded, session->control.peer)) {
        BOOST_LOG(warning) << "Couldn't send the feature advertisement to ["sv << session->device_name << ']';
      }
    });

    // Clipboard, advertise-then-fetch. The client says what it has; nothing
    // crosses until something here actually pastes.
    server->map(packetTypes[IDX_CLIPBOARD_OFFER], [server](session_t *session, const std::string_view &payload) {
      if (!session->peer_features.count(ML_FEATURE_CLIPBOARD)) {
        BOOST_LOG(debug) << "Ignoring an unnegotiated clipboard offer from ["sv
                         << session->device_name << ']';
        return;
      }

      if (!(session->permission & crypto::PERM::clipboard_set)) {
        BOOST_LOG(debug) << "Permission Clipboard Set denied for ["sv << session->device_name << ']';
        return;
      }

      if (payload.size() < 8) {
        BOOST_LOG(warning) << "Clipboard offer from ["sv << session->device_name << "] is too short"sv;
        return;
      }

      auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
      std::uint32_t seq = bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | ((std::uint32_t) bytes[3] << 24);
      std::uint16_t count = bytes[4] | (bytes[5] << 8);

      bool has_text = false;
      std::size_t entries = std::min<std::size_t>(count, (payload.size() - 8) / 6);
      for (std::size_t i = 0; i < entries; ++i) {
        auto off = 8 + i * 6;
        std::uint16_t format = bytes[off] | (bytes[off + 1] << 8);
        if (format == ML_CLIPBOARD_FORMAT_TEXT_UTF8) {
          has_text = true;
        }
      }

      if (!has_text) {
        // Only text is implemented, and an offer without it is not an error --
        // the client copied an image and this host cannot take it yet.
        BOOST_LOG(debug) << "Clipboard offer "sv << seq << " has no format we take"sv;
        return;
      }

      // Fetch immediately rather than on a real paste. This is the honest
      // shape of it: X11 and Wayland want an owner that can answer at any
      // moment, and Helios is not a session client that can hold a selection,
      // so it has to have the bytes in hand before it can put them anywhere.
      // The laziness that matters is still preserved -- the client sends
      // nothing until asked, which is where the privacy cost lives.
      session->clipboard_pending_seq = seq;
      send_clipboard_request(server, session, seq, ML_CLIPBOARD_FORMAT_TEXT_UTF8);
    });

    server->map(packetTypes[IDX_CLIPBOARD_DATA], [server](session_t *session, const std::string_view &payload) {
      if (!session->peer_features.count(ML_FEATURE_CLIPBOARD)) {
        BOOST_LOG(debug) << "Ignoring unnegotiated clipboard data from ["sv
                         << session->device_name << ']';
        return;
      }

      if (!(session->permission & crypto::PERM::clipboard_set)) {
        BOOST_LOG(debug) << "Permission Clipboard Set denied for ["sv << session->device_name << ']';
        return;
      }

      if (payload.size() < 12) {
        BOOST_LOG(warning) << "Clipboard data from ["sv << session->device_name << "] is too short"sv;
        return;
      }

      auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
      std::uint32_t seq = bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | ((std::uint32_t) bytes[3] << 24);
      std::uint16_t format = bytes[4] | (bytes[5] << 8);
      std::uint32_t length = bytes[8] | (bytes[9] << 8) | (bytes[10] << 16) | ((std::uint32_t) bytes[11] << 24);

      if (length > payload.size() - 12) {
        BOOST_LOG(warning) << "Clipboard data claimed "sv << length << " bytes but carried "sv << (payload.size() - 12);
        return;
      }

      // A reply to an offer we have already replaced. Dropping it is what
      // stops an older, slower transfer from overwriting a newer copy.
      if (seq != session->clipboard_pending_seq) {
        BOOST_LOG(debug) << "Ignoring clipboard data for superseded offer "sv << seq;
        return;
      }

      if (format != ML_CLIPBOARD_FORMAT_TEXT_UTF8) {
        return;
      }

      auto content = std::string {payload.data() + 12, length};
      if (platf::set_clipboard(content)) {
        // Mark it as already seen, or the watcher notices the host clipboard
        // change one second later and offers the client its own text back.
        last_seen_clipboard = content;
        BOOST_LOG(info) << "Clipboard updated from ["sv << session->device_name << "], "sv << length << " bytes"sv;
      }
    });

    server->map(packetTypes[IDX_CLIPBOARD_REQUEST], [server](session_t *session, const std::string_view &payload) {
      if (!session->peer_features.count(ML_FEATURE_CLIPBOARD)) {
        BOOST_LOG(debug) << "Ignoring an unnegotiated clipboard request from ["sv
                         << session->device_name << ']';
        return;
      }

      if (!(session->permission & crypto::PERM::clipboard_read)) {
        BOOST_LOG(debug) << "Permission Clipboard Read denied for ["sv << session->device_name << ']';
        return;
      }

      if (payload.size() < 8) {
        return;
      }

      auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
      std::uint32_t seq = bytes[0] | (bytes[1] << 8) | (bytes[2] << 16) | ((std::uint32_t) bytes[3] << 24);
      std::uint16_t format = bytes[4] | (bytes[5] << 8);

      if (format != ML_CLIPBOARD_FORMAT_TEXT_UTF8) {
        return;
      }

      auto content = platf::get_clipboard();
      if (content.empty()) {
        return;
      }

      send_clipboard_data(server, session, seq, format, content);
    });

    server->map(packetTypes[IDX_KEYBOARD_LAYOUT], [server](session_t *session, const std::string_view &payload) {
      if (!session->peer_features.count(ML_FEATURE_KEYBOARD_LAYOUT)) {
        BOOST_LOG(debug) << "Ignoring an unnegotiated keyboard layout from ["sv
                         << session->device_name << ']';
        return;
      }

      if (payload.size() < 6) {
        return;
      }

      auto bytes = reinterpret_cast<const std::uint8_t *>(payload.data());
      if (bytes[0] != 1) {
        BOOST_LOG(info) << "Ignoring keyboard layout in unknown format "sv << (int) bytes[0];
        return;
      }

      std::size_t layout_len = bytes[2] | (bytes[3] << 8);
      std::size_t variant_len = bytes[4] | (bytes[5] << 8);

      // Lengths are the sender's claim until checked against what arrived.
      if (6 + layout_len + variant_len > payload.size()) {
        BOOST_LOG(warning) << "Keyboard layout message is shorter than it claims"sv;
        return;
      }

      session->keyboard_layout.assign(payload.data() + 6, layout_len);
      session->keyboard_variant.assign(payload.data() + 6 + layout_len, variant_len);

      BOOST_LOG(info) << "Client ["sv << session->device_name << "] types on layout ["sv
                      << session->keyboard_layout
                      << (session->keyboard_variant.empty() ? "" : "/")
                      << session->keyboard_variant << ']';

      // Recorded, not applied. Switching the host's keyboard layout changes it
      // for whoever is sitting at that machine too, and there is no portable
      // way to do it per-device across compositors -- so what to do with this
      // is a policy decision rather than something to assume.
    });

    // Declarative USB device set. The actual USB/IP attachment backend is
    // deliberately downstream of this parser: the wire never contains a
    // command line or a host path, only the complete set this authenticated
    // streaming session offers.
    server->map(packetTypes[IDX_USB_DEVICE_SYNC], [server](session_t *session, const std::string_view &payload) {
      if (!session->peer_features.count(ML_FEATURE_USB_PASSTHROUGH)) {
        BOOST_LOG(debug) << "Ignoring an unnegotiated USB device offer from ["sv
                         << session->device_name << ']';
        return;
      }

      std::uint32_t generation;
      std::vector<usb_device_t> offered;
      if (!parse_usb_device_offer(payload, generation, offered)) {
        BOOST_LOG(warning) << "Ignoring a malformed USB device offer from ["sv
                           << session->device_name << ']';
        return;
      }

      if (session->usb_offer_generation != 0 &&
          static_cast<std::int32_t>(generation - session->usb_offer_generation) <= 0) {
        BOOST_LOG(debug) << "Ignoring stale USB device generation "sv << generation;
        return;
      }

      session->usb_offer_generation = generation;
      session->usb_devices = std::move(offered);
      BOOST_LOG(info) << "Client ["sv << session->device_name << "] offered "sv
                      << session->usb_devices.size() << " USB device(s), generation "sv << generation;

      if (!session->usb_devices.empty() && !session->usb_tunnel) {
        try {
          session->usb_tunnel = std::make_unique<usb_tunnel_server_t>(server, session);
          BOOST_LOG(info) << "USB tunnel proxy for ["sv << session->device_name
                          << "] is listening on loopback port "sv << session->usb_tunnel->port();
        } catch (const std::exception &e) {
          BOOST_LOG(error) << "Unable to start the USB tunnel proxy for ["sv
                           << session->device_name << "]: "sv << e.what();
          session->usb_tunnel.reset();
        }
      }
      if (session->usb_tunnel && !session->usb_backend) {
        session->usb_backend = std::make_unique<usb_backend_t>(session->usb_tunnel->port());
      }
      if (session->usb_backend) {
        session->usb_backend->sync(generation, session->usb_devices);
      }
    });

    server->map(packetTypes[IDX_DISPLAY_TOPOLOGY], [](session_t *session, const std::string_view &payload) {
      if (!session->peer_features.count(ML_FEATURE_DISPLAY_TOPOLOGY)) {
        BOOST_LOG(debug) << "Ignoring unnegotiated display topology from ["sv
                         << session->device_name << ']';
        return;
      }
      std::uint32_t generation = 0;
      std::vector<display_desc_t> displays;
      if (!parse_display_topology(payload, generation, displays)) {
        BOOST_LOG(warning) << "Ignoring malformed display topology from ["sv
                           << session->device_name << ']';
        return;
      }
      if (session->display_topology_generation != 0 &&
          (std::int32_t) (generation - session->display_topology_generation) <= 0) {
        BOOST_LOG(debug) << "Ignoring stale display topology generation "sv << generation;
        return;
      }
      session->display_topology_generation = generation;
      session->displays = std::move(displays);
      BOOST_LOG(info) << "Client ["sv << session->device_name << "] has "sv
                      << session->displays.size() << " display(s), topology generation "sv
                      << generation;
      if (!session->display_topology) {
        session->display_topology = display_topology_for_device(session->device_uuid);
      }
      auto topology = session->display_topology;
      std::lock_guard topology_lock {topology->mutex};
      if (!topology->provider) {
        topology->provider = platf::virtual_display_topology();
      }
      if (topology->provider) {
        std::vector<platf::client_display_t> platform_displays;
        platform_displays.reserve(session->displays.size());
        for (const auto &display : session->displays) {
          platform_displays.push_back({
            display.x, display.y, display.width, display.height,
            display.refresh_millihz, display.scale_milli,
            (display.flags & 0x0001) != 0, (display.flags & 0x0002) != 0,
          });
        }
        if (!topology->provider->apply(platform_displays)) {
          BOOST_LOG(warning) << "Could not materialise client display topology on this host"sv;
        } else {
          topology->output_names = topology->provider->display_names();
          topology->ready = true;
          topology->ready_cv.notify_all();
        }
      } else {
        BOOST_LOG(info) << "No virtual display topology provider is available on this host"sv;
        topology->ready = true;
        topology->ready_cv.notify_all();
      }
    });

    server->map(packetTypes[IDX_SYSTEM_DISK_OFFER], [server](session_t *session,
                                                             const std::string_view &payload) {
      if (!session->peer_features.count(ML_FEATURE_SYSTEM_DISK)) {
        BOOST_LOG(debug) << "Ignoring an unnegotiated system disk offer from ["sv
                         << session->device_name << ']';
        return;
      }

      system_disk_offer_t offer;
      if (!parse_system_disk_offer(payload, offer)) {
        BOOST_LOG(warning) << "Ignoring a malformed system disk offer from ["sv
                           << session->device_name << ']';
        return;
      }
      if (session->system_disk_offer_generation != 0 &&
          (std::int32_t) (offer.generation - session->system_disk_offer_generation) <= 0) {
        BOOST_LOG(debug) << "Ignoring stale system disk generation "sv << offer.generation;
        return;
      }

      const auto previous_offer = session->system_disk_offer;
      session->system_disk_offer_generation = offer.generation;
      if (!offer.present()) {
        session->system_disk_offer = offer;
        session::detach_slow_cleanup(session->self.lock());
        BOOST_LOG(info) << "Client ["sv << session->device_name << "] withdrew its system disk"sv;
        return;
      }


      if (session->system_disk_backend) {
        if (previous_offer.target_iqn == offer.target_iqn) {
          session->system_disk_offer = offer;
          BOOST_LOG(debug) << "Keeping the existing system disk attachment for generation "sv
                           << offer.generation;
        } else {
          BOOST_LOG(warning) << "Ignoring an in-place system disk target change; withdraw the old "sv
                                "target before offering a new one"sv;
        }
        return;
      }
      session->system_disk_offer = offer;

      if (!session->system_disk_tunnel) {
        try {
          session->system_disk_tunnel = std::make_unique<usb_tunnel_server_t>(
            server, session,
            packetTypes[IDX_DISK_TUNNEL_OPEN], packetTypes[IDX_DISK_TUNNEL_DATA],
            packetTypes[IDX_DISK_TUNNEL_CLOSE], "system disk");
        } catch (const std::exception &e) {
          BOOST_LOG(error) << "Unable to start the system disk tunnel for ["sv
                           << session->device_name << "]: "sv << e.what();
          session->system_disk_tunnel.reset();
          return;
        }
      }
      session->system_disk_backend = std::make_unique<system_disk_backend_t>(
        session->system_disk_tunnel->port(), offer.target_iqn);
      BOOST_LOG(info) << "Client ["sv << session->device_name << "] offered read-only disk ["sv
                      << offer.target_iqn << "], "sv << offer.size << " bytes; loopback proxy port "sv
                      << session->system_disk_tunnel->port();
    });

    // The client is the only side allowed to initiate a tunnel. Helios accepts
    // a loopback USB/IP connection and emits OPEN; receiving OPEN here would
    // invert that trust boundary, so there is intentionally no OPEN handler.
    server->map(packetTypes[IDX_USB_TUNNEL_DATA], [](session_t *session, const std::string_view &payload) {
      std::uint32_t id = 0;
      std::string_view data;
      if (!session->peer_features.count(ML_FEATURE_USB_PASSTHROUGH) ||
          !session->usb_tunnel || !parse_usb_tunnel_data(payload, id, data)) {
        BOOST_LOG(warning) << "Ignoring malformed or unnegotiated USB tunnel data from ["sv
                           << session->device_name << ']';
        return;
      }
      session->usb_tunnel->write(id, data);
    });

    server->map(packetTypes[IDX_USB_TUNNEL_CLOSE], [](session_t *session, const std::string_view &payload) {
      std::uint32_t id = 0;
      std::uint16_t reason = 0;
      if (!session->peer_features.count(ML_FEATURE_USB_PASSTHROUGH) ||
          !session->usb_tunnel || !parse_usb_tunnel_close(payload, id, reason)) {
        BOOST_LOG(warning) << "Ignoring malformed or unnegotiated USB tunnel close from ["sv
                           << session->device_name << ']';
        return;
      }
      BOOST_LOG(debug) << "Client closed USB tunnel "sv << id << " with reason "sv << reason;
      session->usb_tunnel->close(id);
    });

    server->map(packetTypes[IDX_DISK_TUNNEL_DATA], [](session_t *session, const std::string_view &payload) {
      std::uint32_t id = 0;
      std::string_view data;
      if (!session->peer_features.count(ML_FEATURE_SYSTEM_DISK) ||
          !session->system_disk_tunnel || !parse_usb_tunnel_data(payload, id, data)) {
        BOOST_LOG(warning) << "Ignoring malformed or unnegotiated system disk tunnel data from ["sv
                           << session->device_name << ']';
        return;
      }
      session->system_disk_tunnel->write(id, data);
    });

    server->map(packetTypes[IDX_DISK_TUNNEL_CLOSE], [](session_t *session, const std::string_view &payload) {
      std::uint32_t id = 0;
      std::uint16_t reason = 0;
      if (!session->peer_features.count(ML_FEATURE_SYSTEM_DISK) ||
          !session->system_disk_tunnel || !parse_usb_tunnel_close(payload, id, reason)) {
        BOOST_LOG(warning) << "Ignoring malformed or unnegotiated system disk tunnel close from ["sv
                           << session->device_name << ']';
        return;
      }
      BOOST_LOG(debug) << "Client closed system disk tunnel "sv << id << " with reason "sv << reason;
      session->system_disk_tunnel->close(id);
    });

    server->map(packetTypes[IDX_SET_CLIPBOARD], [server](session_t *session, const std::string_view &payload) {
      BOOST_LOG(info) << "type [IDX_SET_CLIPBOARD]: "sv << payload << " size: " << payload.size();

      if (!(session->permission & crypto::PERM::clipboard_set)) {
        BOOST_LOG(debug) << "Permission Clipboard Set deined for [" << session->device_name << "]";
        return;
      }
    });

    server->map(packetTypes[IDX_FILE_TRANSFER_NONCE_REQUEST], [server](session_t *session, const std::string_view &payload) {
      BOOST_LOG(info) << "type [IDX_FILE_TRANSFER_NONCE_REQUEST]: "sv << payload << " size: " << payload.size();

      if (!(session->permission & crypto::PERM::file_upload)) {
        BOOST_LOG(debug) << "Permission File Upload deined for [" << session->device_name << "]";
        return;
      }
    });

    server->map(packetTypes[IDX_ENCRYPTED], [server](session_t *session, const std::string_view &payload) {
      BOOST_LOG(verbose) << "type [IDX_ENCRYPTED]"sv;

      auto header = (control_encrypted_p) (payload.data() - 2);

      auto length = util::endian::little(header->length);
      auto seq = util::endian::little(header->seq);

      if (length < (16 + 4 + 4)) {
        BOOST_LOG(warning) << "Control: Runt packet"sv;
        return;
      }

      auto tagged_cipher_length = length - 4;
      std::string_view tagged_cipher {(char *) header->payload(), (size_t) tagged_cipher_length};

      auto &cipher = session->control.cipher;
      auto &iv = session->control.incoming_iv;
      if (session->config.encryptionFlagsEnabled & SS_ENC_CONTROL_V2) {
        // We use the deterministic IV construction algorithm specified in NIST SP 800-38D
        // Section 8.2.1. The sequence number is our "invocation" field and the 'CC' in the
        // high bytes is the "fixed" field. Because each client provides their own unique
        // key, our values in the fixed field need only uniquely identify each independent
        // use of the client's key with AES-GCM in our code.
        //
        // The sequence number is 32 bits long which allows for 2^32 control stream messages
        // to be received from each client before the IV repeats.
        iv.resize(12);
        std::copy_n((uint8_t *) &seq, sizeof(seq), std::begin(iv));
        iv[10] = 'C';  // Client originated
        iv[11] = 'C';  // Control stream
      } else {
        // Nvidia's old style encryption uses a 16-byte IV
        iv.resize(16);

        iv[0] = (std::uint8_t) seq;
      }

      std::vector<uint8_t> plaintext;
      if (cipher.decrypt(tagged_cipher, plaintext, &iv)) {
        // something went wrong :(

        BOOST_LOG(error) << "Failed to verify tag"sv;

        session::stop(*session);
        return;
      }

      auto type = *(std::uint16_t *) plaintext.data();
      std::string_view next_payload {(char *) plaintext.data() + 4, plaintext.size() - 4};

      if (type == packetTypes[IDX_ENCRYPTED]) {
        BOOST_LOG(error) << "Bad packet type [IDX_ENCRYPTED] found"sv;
        session::stop(*session);
        return;
      }

      // IDX_INPUT_DATA callback will attempt to decrypt unencrypted data, therefore we need pass it directly
      if (type == packetTypes[IDX_INPUT_DATA]) {
        plaintext.erase(std::begin(plaintext), std::begin(plaintext) + 4);
        input::passthrough(session->input, std::move(plaintext), session->permission);
      } else {
        server->call(type, session, next_payload, true);
      }
    });

    // This thread handles latency-sensitive control messages
    platf::adjust_thread_priority(platf::thread_priority_e::critical);

    // Check for both the full shutdown event and the shutdown event for this
    // broadcast to ensure we can inform connected clients of our graceful
    // termination when we shut down.
    auto shutdown_event = mail::man->event<bool>(mail::shutdown);
    auto broadcast_shutdown_event = mail::man->event<bool>(mail::broadcast_shutdown);
    while (!shutdown_event->peek() && !broadcast_shutdown_event->peek()) {
      bool has_session_awaiting_peer = false;

      {
        auto lg = server->_sessions.lock();

        auto now = std::chrono::steady_clock::now();

        // Under the same lock as the session walk below, since it reads the
        // session list and sends on their peers.
        poll_host_clipboard(server);

        KITTY_WHILE_LOOP(auto pos = std::begin(*server->_sessions), pos != std::end(*server->_sessions), {
          // Don't perform additional session processing if we're shutting down
          if (shutdown_event->peek() || broadcast_shutdown_event->peek()) {
            break;
          }

          auto session = *pos;

          if (now > session->pingTimeout) {
            auto address = session->control.peer ? platf::from_sockaddr((sockaddr *) &session->control.peer->address.address) : session->control.expected_peer_address;
            BOOST_LOG(info) << address << ": Ping Timeout"sv;
            session::stop(*session);
          }

          if (session->state.load(std::memory_order_acquire) == session::state_e::STOPPING) {
            BOOST_LOG(info) << "Removing stopped session from control server"sv;
            pos = server->_sessions->erase(pos);

            if (session->control.peer) {
              BOOST_LOG(info) << "Removing stopped session control peer mapping"sv;
              {
                auto ptslg = server->_peer_to_session.lock();
                server->_peer_to_session->erase(session->control.peer);
              }

              BOOST_LOG(info) << "Disconnecting stopped session ENet peer"sv;
              enet_peer_disconnect_now(session->control.peer, 0);
            }

            BOOST_LOG(info) << "Signalling stopped session control completion"sv;
            session->controlEnd.raise(true);
            continue;
          }

          // Remember if we have a session that's waiting for a peer to connect to the
          // control stream. This ensures the clients are properly notified even when
          // the app terminates before they finish connecting.
          if (!session->control.peer) {
            has_session_awaiting_peer = true;
          } else {
            auto &feedback_queue = session->control.feedback_queue;
            while (feedback_queue->peek()) {
              auto feedback_msg = feedback_queue->pop();

              send_feedback_msg(session, *feedback_msg);
            }

            auto &hdr_queue = session->control.hdr_queue;
            while (session->control.peer && hdr_queue->peek()) {
              auto hdr_info = hdr_queue->pop();

              send_hdr_mode(session, std::move(hdr_info));
            }
          }

          ++pos;
        })
      }

      // Don't break until any pending sessions either expire or connect
      if (proc::proc.running() == 0 && !has_session_awaiting_peer) {
        BOOST_LOG(info) << "Process terminated"sv;
        break;
      }

      server->iterate(150ms);
    }

    // Let all remaining connections know the server is shutting down
    // reason: graceful termination
    std::uint32_t reason = 0x80030023;

    control_terminate_t plaintext;
    plaintext.header.type = packetTypes[IDX_TERMINATION];
    plaintext.header.payloadLength = sizeof(plaintext.ec);
    plaintext.ec = util::endian::big<uint32_t>(reason);

    std::array<std::uint8_t, sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(sizeof(plaintext)) + crypto::cipher::tag_size>
      encrypted_payload;

    auto lg = server->_sessions.lock();
    for (auto pos = std::begin(*server->_sessions); pos != std::end(*server->_sessions); ++pos) {
      auto session = *pos;

      // We may not have gotten far enough to have an ENet connection yet
      if (session->control.peer) {
        auto payload = encode_control(session, util::view(plaintext), encrypted_payload);

        if (server->send(payload, session->control.peer)) {
          TUPLE_2D(port, addr, platf::from_sockaddr_ex((sockaddr *) &session->control.peer->address.address));
          BOOST_LOG(warning) << "Couldn't send termination code to ["sv << addr << ':' << port << ']';
        }
      }

      session->shutdown_event->raise(true);
      session->controlEnd.raise(true);
    }

    server->flush();
  }

  void recvThread(broadcast_ctx_t &ctx) {
    std::map<av_session_id_t, message_queue_t> peer_to_video_session;
    std::map<av_session_id_t, message_queue_t> peer_to_audio_session;

    auto &video_sock = ctx.video_sock;
    auto &audio_sock = ctx.audio_sock;
    auto &microphone_sock = ctx.microphone_sock;
    auto &camera_sock = ctx.camera_sock;

    auto &message_queue_queue = ctx.message_queue_queue;
    auto broadcast_shutdown_event = mail::man->event<bool>(mail::broadcast_shutdown);

    auto &io = ctx.io_context;

    udp::endpoint peer;

    std::array<char, 2048> buf[2];
    std::function<void(const boost::system::error_code, size_t)> recv_func[2];

    udp::endpoint microphone_peer;
    std::array<char, microphone_packet_header_size + 8 + microphone_max_opus_size> microphone_buf;
    std::function<void(const boost::system::error_code, size_t)> microphone_recv_func;

    udp::endpoint camera_peer;
    std::array<char, camera_packet_header_size + camera_fragment_header_size + camera_fragment_data_size> camera_buf;
    std::function<void(const boost::system::error_code, size_t)> camera_recv_func;

    auto populate_peer_to_session = [&]() {
      while (message_queue_queue->peek()) {
        auto message_queue_opt = message_queue_queue->pop();
        TUPLE_3D_REF(socket_type, session_id, message_queue, *message_queue_opt);

        switch (socket_type) {
          case socket_e::video:
            if (message_queue) {
              peer_to_video_session.emplace(session_id, message_queue);
            } else {
              peer_to_video_session.erase(session_id);
            }
            break;
          case socket_e::audio:
            if (message_queue) {
              peer_to_audio_session.emplace(session_id, message_queue);
            } else {
              peer_to_audio_session.erase(session_id);
            }
            break;
        }
      }
    };

    auto recv_func_init = [&](udp::socket &sock, int buf_elem, std::map<av_session_id_t, message_queue_t> &peer_to_session) {
      recv_func[buf_elem] = [&, buf_elem](const boost::system::error_code &ec, size_t bytes) {
        auto fg = util::fail_guard([&]() {
          sock.async_receive_from(asio::buffer(buf[buf_elem]), peer, 0, recv_func[buf_elem]);
        });

        auto type_str = buf_elem ? "AUDIO"sv : "VIDEO"sv;
        BOOST_LOG(verbose) << "Recv: "sv << peer.address().to_string() << ':' << peer.port() << " :: " << type_str;

        populate_peer_to_session();

        // No data, yet no error
        if (ec == boost::system::errc::connection_refused || ec == boost::system::errc::connection_reset) {
          return;
        }

        if (ec || !bytes) {
          BOOST_LOG(error) << "Couldn't receive data from udp socket: "sv << ec.message();
          return;
        }

        if (bytes == 4) {
          // For legacy PING packets, find the matching session by address.
          auto it = peer_to_session.find(peer.address());
          if (it != std::end(peer_to_session)) {
            BOOST_LOG(debug) << "RAISE: "sv << peer.address().to_string() << ':' << peer.port() << " :: " << type_str;
            it->second->raise(peer, std::string {buf[buf_elem].data(), bytes});
          }
        } else if (bytes >= sizeof(SS_PING)) {
          auto ping = (PSS_PING) buf[buf_elem].data();

          // For new PING packets that include a client identifier, search by payload.
          auto it = peer_to_session.find(std::string {ping->payload, sizeof(ping->payload)});
          if (it != std::end(peer_to_session)) {
            BOOST_LOG(debug) << "RAISE: "sv << peer.address().to_string() << ':' << peer.port() << " :: " << type_str;
            it->second->raise(peer, std::string {buf[buf_elem].data(), bytes});
          }
        }
      };
    };

    recv_func_init(video_sock, 0, peer_to_video_session);
    recv_func_init(audio_sock, 1, peer_to_audio_session);

    microphone_recv_func = [&](const boost::system::error_code &ec, size_t bytes) {
      auto fg = util::fail_guard([&]() {
        microphone_sock.async_receive_from(asio::buffer(microphone_buf), microphone_peer, 0, microphone_recv_func);
      });

      if (ec == boost::system::errc::connection_refused || ec == boost::system::errc::connection_reset) {
        return;
      }
      if (ec || !bytes) {
        BOOST_LOG(error) << "Couldn't receive data from microphone UDP socket: "sv << ec.message();
        return;
      }
      if (bytes < microphone_packet_header_size) {
        return;
      }

      auto raw = reinterpret_cast<const std::uint8_t *>(microphone_buf.data());
      if (read_be32(raw) != microphone_packet_magic || read_be16(raw + 6) != bytes) {
        return;
      }
      auto connect_data = read_be32(raw + 8);

      // Hold the session-list lock throughout processing so the control thread
      // cannot retire this raw session pointer while a datagram is decoded.
      auto sessions_lock = ctx.control_server._sessions.lock();
      auto it = std::find_if(ctx.control_server._sessions->begin(), ctx.control_server._sessions->end(),
                             [&](session_t *session) {
                               return session->control.connect_data == connect_data &&
                                      session->video.peer.address() == microphone_peer.address() &&
                                      session->state.load(std::memory_order_acquire) == session::state_e::RUNNING;
                             });
      if (it == ctx.control_server._sessions->end()) {
        return;
      }

      auto *session = *it;
      if (!session->peer_features.count(ML_FEATURE_MICROPHONE) || !session->microphone.cipher) {
        return;
      }

      microphone_packet_t packet;
      if (!decode_microphone_packet(std::string_view {microphone_buf.data(), bytes},
                                    *session->microphone.cipher, packet)) {
        BOOST_LOG(warning) << "Rejected unauthenticated or malformed microphone packet from ["sv
                           << session->device_name << ']';
        return;
      }
      if (packet.channels != 1 || packet.samples != 960 ||
          (session->microphone.has_sequence && packet.sequence <= session->microphone.last_sequence)) {
        return;
      }
      auto recover_previous = session->microphone.has_sequence &&
                              packet.sequence == session->microphone.last_sequence + 2;
      session->microphone.last_sequence = packet.sequence;
      session->microphone.has_sequence = true;

      if (!session->microphone.decoder) {
        int opus_error;
        session->microphone.decoder = opus_decoder_create(48000, 1, &opus_error);
        if (!session->microphone.decoder || opus_error != OPUS_OK) {
          BOOST_LOG(error) << "Couldn't create microphone Opus decoder: "sv << opus_strerror(opus_error);
          return;
        }
      }
      if (!session->microphone.sink) {
        session->microphone.sink = platf::virtual_microphone();
        if (!session->microphone.sink) {
          BOOST_LOG(error) << "No host virtual microphone is available for ["sv << session->device_name << ']';
          return;
        }
      }

      std::array<float, 960> pcm;
      if (recover_previous) {
        auto recovered = opus_decode_float(session->microphone.decoder, packet.opus.data(),
                                           static_cast<opus_int32>(packet.opus.size()),
                                           pcm.data(), pcm.size(), 1);
        if (recovered > 0 && !session->microphone.sink->write(pcm.data(), recovered)) {
          session->microphone.sink.reset();
          return;
        }
      }
      auto decoded = opus_decode_float(session->microphone.decoder, packet.opus.data(),
                                       static_cast<opus_int32>(packet.opus.size()),
                                       pcm.data(), pcm.size(), 0);
      if (decoded != static_cast<int>(packet.samples)) {
        BOOST_LOG(warning) << "Couldn't decode microphone Opus frame from ["sv << session->device_name
                           << "]: decoder returned " << decoded << " samples, expected " << packet.samples;
        return;
      }
      if (!session->microphone.sink->write(pcm.data(), decoded)) {
        session->microphone.sink.reset();
        return;
      }
      if (!session->microphone.first_frame_logged) {
        BOOST_LOG(info) << "Receiving microphone audio from ["sv << session->device_name << ']';
        session->microphone.first_frame_logged = true;
      }
    };

    camera_recv_func = [&](const boost::system::error_code &ec, size_t bytes) {
      auto fg = util::fail_guard([&]() {
        camera_sock.async_receive_from(asio::buffer(camera_buf), camera_peer, 0, camera_recv_func);
      });

      if (ec == boost::system::errc::connection_refused || ec == boost::system::errc::connection_reset) return;
      if (ec || bytes < camera_packet_header_size) {
        if (ec) BOOST_LOG(error) << "Couldn't receive data from camera UDP socket: "sv << ec.message();
        return;
      }

      auto raw = reinterpret_cast<const std::uint8_t *>(camera_buf.data());
      if (read_be32(raw) != camera_packet_magic || read_be16(raw + 6) != bytes) return;
      auto connect_data = read_be32(raw + 8);

      auto sessions_lock = ctx.control_server._sessions.lock();
      auto it = std::find_if(ctx.control_server._sessions->begin(), ctx.control_server._sessions->end(),
                             [&](session_t *session) {
                               return session->control.connect_data == connect_data &&
                                      session->video.peer.address() == camera_peer.address() &&
                                      session->state.load(std::memory_order_acquire) == session::state_e::RUNNING;
                             });
      if (it == ctx.control_server._sessions->end()) return;

      auto *session = *it;
      if (!session->peer_features.count(ML_FEATURE_CAMERA) || !session->camera.cipher) return;

      camera_fragment_t fragment;
      if (!decode_camera_fragment(std::string_view {camera_buf.data(), bytes},
                                  *session->camera.cipher, fragment)) {
        BOOST_LOG(warning) << "Rejected unauthenticated or malformed camera fragment from ["sv
                           << session->device_name << ']';
        return;
      }

      auto &camera = session->camera;
      auto arrival_ms = static_cast<std::uint64_t>(std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::steady_clock::now().time_since_epoch()).count());
      auto frame = camera.assembler.accept(fragment, arrival_ms);
      if (!frame) return;

      if (!camera.sink) camera.sink = platf::virtual_camera();
      if (!camera.sink) {
        BOOST_LOG(error) << "No host virtual camera is available for ["sv << session->device_name << ']';
        return;
      }
      if (!camera.sink->write_mjpeg(frame->bytes.data(), frame->bytes.size(), frame->width,
                                    frame->height, frame->timestamp_ms)) {
        camera.sink.reset();
        return;
      }
      if (!camera.first_frame_logged) {
        BOOST_LOG(info) << "Receiving camera video from ["sv << session->device_name << ']';
        camera.first_frame_logged = true;
      }
    };

    video_sock.async_receive_from(asio::buffer(buf[0]), peer, 0, recv_func[0]);
    audio_sock.async_receive_from(asio::buffer(buf[1]), peer, 0, recv_func[1]);
    microphone_sock.async_receive_from(asio::buffer(microphone_buf), microphone_peer, 0, microphone_recv_func);
    camera_sock.async_receive_from(asio::buffer(camera_buf), camera_peer, 0, camera_recv_func);

    while (!broadcast_shutdown_event->peek()) {
      io.run();
    }
  }

  void videoBroadcastThread(udp::socket &sock) {
    auto shutdown_event = mail::man->event<bool>(mail::broadcast_shutdown);
    auto packets = mail::man->queue<video::packet_t>(mail::video_packets);
    auto video_epoch = std::chrono::steady_clock::now();

    // Video traffic is sent on this thread
    platf::adjust_thread_priority(platf::thread_priority_e::high);

    logging::min_max_avg_periodic_logger<double> frame_processing_latency_logger(debug, "Frame processing latency", "ms");

    logging::time_delta_periodic_logger frame_send_batch_latency_logger(debug, "Network: each send_batch() latency");
    logging::time_delta_periodic_logger frame_fec_latency_logger(debug, "Network: each FEC block latency");
    logging::time_delta_periodic_logger frame_network_latency_logger(debug, "Network: frame's overall network latency");

    crypto::aes_t iv(12);

    auto timer = platf::create_high_precision_timer();
    if (!timer || !*timer) {
      BOOST_LOG(error) << "Failed to create timer, aborting video broadcast thread";
      return;
    }

    auto ratecontrol_next_frame_start = std::chrono::steady_clock::now();

    while (auto packet = packets->pop()) {
      if (shutdown_event->peek()) {
        break;
      }

      frame_network_latency_logger.first_point_now();

      auto session = (session_t *) packet->channel_data;
      auto lowseq = session->video.lowseq;

      std::string_view payload {(char *) packet->data(), packet->data_size()};
      std::vector<uint8_t> payload_with_replacements;

      // Apply replacements on the packet payload before performing any other operations.
      // We need to know the final frame size to calculate the last packet size, and we
      // must avoid matching replacements against the frame header or any other non-video
      // part of the payload.
      if (packet->is_idr() && packet->replacements) {
        for (auto &replacement : *packet->replacements) {
          auto frame_old = replacement.old;
          auto frame_new = replacement._new;

          payload_with_replacements = replace(payload, frame_old, frame_new);
          payload = {(char *) payload_with_replacements.data(), payload_with_replacements.size()};
        }
      }

      video_short_frame_header_t frame_header = {};
      frame_header.headerType = 0x01;  // Short header type
      frame_header.frameType = packet->is_idr()                     ? 2 :
                               packet->after_ref_frame_invalidation ? 5 :
                                                                      1;
      frame_header.lastPayloadLen = (payload.size() + sizeof(frame_header)) % (session->config.packetsize - sizeof(NV_VIDEO_PACKET));
      if (frame_header.lastPayloadLen == 0) {
        frame_header.lastPayloadLen = session->config.packetsize - sizeof(NV_VIDEO_PACKET);
      }

      if (packet->frame_timestamp) {
        auto duration_to_latency = [](const std::chrono::steady_clock::duration &duration) {
          const auto duration_us = std::chrono::duration_cast<std::chrono::microseconds>(duration).count();
          return (uint16_t) std::clamp<decltype(duration_us)>((duration_us + 50) / 100, 0, std::numeric_limits<uint16_t>::max());
        };

        uint16_t latency = duration_to_latency(std::chrono::steady_clock::now() - *packet->frame_timestamp);
        frame_header.frame_processing_latency = latency;
        frame_processing_latency_logger.collect_and_log(latency / 10.);
      } else {
        frame_header.frame_processing_latency = 0;
      }

      auto fecPercentage = config::stream.fec_percentage;

      // Insert space for packet headers
      auto blocksize = session->config.packetsize + MAX_RTP_HEADER_SIZE;
      auto payload_blocksize = blocksize - sizeof(video_packet_raw_t);
      auto payload_new = concat_and_insert(sizeof(video_packet_raw_t), payload_blocksize, std::string_view {(char *) &frame_header, sizeof(frame_header)}, payload);

      payload = std::string_view {(char *) payload_new.data(), payload_new.size()};

      // There are 2 bits for FEC block count for a maximum of 4 FEC blocks
      constexpr auto MAX_FEC_BLOCKS = 4;

      // The max number of data shards per block is found by solving this system of equations for D:
      // D = 255 - P
      // P = D * F
      // which results in the solution:
      // D = 255 / (1 + F)
      // multiplied by 100 since F is the percentage as an integer:
      // D = (255 * 100) / (100 + F)
      auto max_data_shards_per_fec_block = (DATA_SHARDS_MAX * 100) / (100 + fecPercentage);

      // Compute the number of FEC blocks needed for this frame using the block size and max shards
      auto max_data_per_fec_block = max_data_shards_per_fec_block * blocksize;
      auto fec_blocks_needed = (payload.size() + (max_data_per_fec_block - 1)) / max_data_per_fec_block;

      // If the number of FEC blocks needed exceeds the protocol limit, turn off FEC for this frame.
      // For normal FEC percentages, this should only happen for enormous frames (over 800 packets at 20%).
      if (fec_blocks_needed > MAX_FEC_BLOCKS) {
        BOOST_LOG(warning) << "Skipping FEC for abnormally large encoded frame (needed "sv << fec_blocks_needed << " FEC blocks)"sv;
        fecPercentage = 0;
        fec_blocks_needed = MAX_FEC_BLOCKS;
      }

      std::array<std::string_view, MAX_FEC_BLOCKS> fec_blocks;
      decltype(fec_blocks)::iterator
        fec_blocks_begin = std::begin(fec_blocks),
        fec_blocks_end = std::begin(fec_blocks) + fec_blocks_needed;

      BOOST_LOG(verbose) << "Generating "sv << fec_blocks_needed << " FEC blocks"sv;

      // Align individual FEC blocks to blocksize
      auto unaligned_size = payload.size() / fec_blocks_needed;
      auto aligned_size = ((unaligned_size + (blocksize - 1)) / blocksize) * blocksize;

      // If we exceed the 10-bit FEC packet index (which means our frame exceeded 4096 packets),
      // the frame will be unrecoverable. Log an error for this case.
      if (aligned_size / blocksize >= 1024) {
        BOOST_LOG(error) << "Encoder produced a frame too large to send! Is the encoder broken? (needed "sv << (aligned_size / blocksize) << " packets)"sv;
      }

      // Split the data into aligned FEC blocks
      for (int x = 0; x < fec_blocks_needed; ++x) {
        if (x == fec_blocks_needed - 1) {
          // The last block must extend to the end of the payload
          fec_blocks[x] = payload.substr(x * aligned_size);
        } else {
          // Earlier blocks just extend to the next block offset
          fec_blocks[x] = payload.substr(x * aligned_size, aligned_size);
        }
      }

      try {
        // Use around 80% of 1Gbps          1Gbps            percent    ms     packet      byte
        size_t ratecontrol_packets_in_1ms = std::giga::num * 80 / 100 / 1000 / blocksize / 8;

        // Send less than 64K in a single batch.
        // On Windows, batches above 64K seem to bypass SO_SNDBUF regardless of its size,
        // appear in "Other I/O" and begin waiting for interrupts.
        // This gives inconsistent performance so we'd rather avoid it.
        size_t send_batch_size = 64 * 1024 / blocksize;
        // Also don't exceed 64 packets, which can happen when Moonlight requests
        // unusually small packet size.
        // Generic Segmentation Offload on Linux can't do more than 64.
        send_batch_size = std::min<size_t>(64, send_batch_size);

        // Don't ignore the last ratecontrol group of the previous frame
        auto ratecontrol_frame_start = std::max(ratecontrol_next_frame_start, std::chrono::steady_clock::now());

        size_t ratecontrol_frame_packets_sent = 0;
        size_t ratecontrol_group_packets_sent = 0;

        auto blockIndex = 0;
        std::for_each(fec_blocks_begin, fec_blocks_end, [&](std::string_view &current_payload) {
          auto packets = (current_payload.size() + (blocksize - 1)) / blocksize;

          for (int x = 0; x < packets; ++x) {
            auto *inspect = (video_packet_raw_t *) &current_payload[x * blocksize];

            inspect->packet.frameIndex = packet->frame_index();
            inspect->packet.streamPacketIndex = ((uint32_t) lowseq + x) << 8;

            // Match multiFecFlags with Moonlight
            inspect->packet.multiFecFlags = 0x10;
            inspect->packet.multiFecBlocks = (blockIndex << 4) | ((fec_blocks_needed - 1) << 6);

            inspect->packet.flags = FLAG_CONTAINS_PIC_DATA;
            if (x == 0) {
              inspect->packet.flags |= FLAG_SOF;
            }
            if (x == packets - 1) {
              inspect->packet.flags |= FLAG_EOF;
            }
          }

          frame_fec_latency_logger.first_point_now();
          // If video encryption is enabled, we allocate space for the encryption header before each shard
          auto shards = fec::encode(current_payload, blocksize, fecPercentage, session->config.minRequiredFecPackets, session->video.cipher ? sizeof(video_packet_enc_prefix_t) : 0);
          frame_fec_latency_logger.second_point_now_and_log();

          auto peer_address = session->video.peer.address();
          auto batch_info = platf::batched_send_info_t {
            shards.headers.begin(),
            shards.prefixsize,
            shards.payload_buffers,
            shards.blocksize,
            0,
            0,
            (uintptr_t) sock.native_handle(),
            peer_address,
            session->video.peer.port(),
            session->localAddress,
          };

          size_t next_shard_to_send = 0;

          // RTP video timestamps use a 90 KHz clock and the frame_timestamp from when the frame was captured
          // When a timestamp isn't available (duplicate frames), the timestamp from rate control is used instead.
          bool frame_is_dupe = false;
          if (!packet->frame_timestamp) {
            packet->frame_timestamp = ratecontrol_next_frame_start;
            frame_is_dupe = true;
          }
          using rtp_tick = std::chrono::duration<uint32_t, std::ratio<1, 90000>>;
          uint32_t timestamp = std::chrono::round<rtp_tick>(*packet->frame_timestamp - video_epoch).count();

          // set FEC info now that we know for sure what our percentage will be for this frame
          for (auto x = 0; x < shards.size(); ++x) {
            auto *inspect = (video_packet_raw_t *) shards.data(x);

            inspect->packet.fecInfo =
              (x << 12 |
               shards.data_shards << 22 |
               shards.percentage << 4);

            inspect->rtp.header = 0x80 | FLAG_EXTENSION;
            inspect->rtp.sequenceNumber = util::endian::big<uint16_t>(lowseq + x);
            inspect->rtp.timestamp = util::endian::big<uint32_t>(timestamp);

            inspect->packet.multiFecBlocks = (blockIndex << 4) | ((fec_blocks_needed - 1) << 6);
            inspect->packet.frameIndex = packet->frame_index();

            // Encrypt this shard if video encryption is enabled
            if (session->video.cipher) {
              // We use the deterministic IV construction algorithm specified in NIST SP 800-38D
              // Section 8.2.1. The sequence number is our "invocation" field and the 'V' in the
              // high bytes is the "fixed" field. Because each client provides their own unique
              // key, our values in the fixed field need only uniquely identify each independent
              // use of the client's key with AES-GCM in our code.
              //
              // The IV counter is 64 bits long which allows for 2^64 encrypted video packets
              // to be sent to each client before the IV repeats.
              std::copy_n((uint8_t *) &session->video.gcm_iv_counter, sizeof(session->video.gcm_iv_counter), std::begin(iv));
              iv[11] = 'V';  // Video stream
              session->video.gcm_iv_counter++;

              // Encrypt the target buffer in place
              auto *prefix = (video_packet_enc_prefix_t *) shards.prefix(x);
              prefix->frameNumber = packet->frame_index();
              std::copy(std::begin(iv), std::end(iv), prefix->iv);
              session->video.cipher->encrypt(std::string_view {(char *) inspect, (size_t) blocksize}, prefix->tag, (uint8_t *) inspect, &iv);
            }

            if (x - next_shard_to_send + 1 >= send_batch_size ||
                x + 1 == shards.size()) {
              // Do pacing within the frame.
              // Also trigger pacing before the first send_batch() of the frame
              // to account for the last send_batch() of the previous frame.
              if (ratecontrol_group_packets_sent >= ratecontrol_packets_in_1ms ||
                  ratecontrol_frame_packets_sent == 0) {
                auto due = ratecontrol_frame_start +
                           std::chrono::duration_cast<std::chrono::nanoseconds>(1ms) *
                             ratecontrol_frame_packets_sent / ratecontrol_packets_in_1ms;

                auto now = std::chrono::steady_clock::now();
                if (now < due) {
                  timer->sleep_for(due - now);
                }

                ratecontrol_group_packets_sent = 0;
              }

              size_t current_batch_size = x - next_shard_to_send + 1;
              batch_info.block_offset = next_shard_to_send;
              batch_info.block_count = current_batch_size;

              frame_send_batch_latency_logger.first_point_now();
              // Use a batched send if it's supported on this platform
              if (!platf::send_batch(batch_info)) {
                // Batched send is not available, so send each packet individually
                BOOST_LOG(verbose) << "Falling back to unbatched send"sv;
                for (auto y = 0; y < current_batch_size; y++) {
                  auto send_info = platf::send_info_t {
                    shards.prefix(next_shard_to_send + y),
                    shards.prefixsize,
                    shards.data(next_shard_to_send + y),
                    shards.blocksize,
                    (uintptr_t) sock.native_handle(),
                    peer_address,
                    session->video.peer.port(),
                    session->localAddress,
                  };

                  platf::send(send_info);
                }
              }
              frame_send_batch_latency_logger.second_point_now_and_log();

              ratecontrol_group_packets_sent += current_batch_size;
              ratecontrol_frame_packets_sent += current_batch_size;
              next_shard_to_send = x + 1;
            }
          }

          // remember this in case the next frame comes immediately
          ratecontrol_next_frame_start = ratecontrol_frame_start +
                                         std::chrono::duration_cast<std::chrono::nanoseconds>(1ms) *
                                           ratecontrol_frame_packets_sent / ratecontrol_packets_in_1ms;

          frame_network_latency_logger.second_point_now_and_log();

          BOOST_LOG(verbose) << "Sent Frame seq ["sv << packet->frame_index() << "] pts ["sv << timestamp
                             << "] shards ["sv << shards.size() << "/"sv << shards.percentage << "%]"sv
                             << (frame_is_dupe ? " Dupe" : "")
                             << (packet->is_idr() ? " Key" : "")
                             << (packet->after_ref_frame_invalidation ? " RFI" : "");

          ++blockIndex;
          lowseq += shards.size();
        });

        session->video.lowseq = lowseq;
      } catch (const std::exception &e) {
        BOOST_LOG(error) << "Broadcast video failed "sv << e.what();
        std::this_thread::sleep_for(100ms);
      }
    }

    shutdown_event->raise(true);
  }

  void audioBroadcastThread(udp::socket &sock) {
    auto shutdown_event = mail::man->event<bool>(mail::broadcast_shutdown);
    auto packets = mail::man->queue<audio::packet_t>(mail::audio_packets);

    audio_packet_t audio_packet;
    fec::rs_t rs {reed_solomon_new(RTPA_DATA_SHARDS, RTPA_FEC_SHARDS)};
    crypto::aes_t iv(16);

    // For unknown reasons, the RS parity matrix computed by our RS implementation
    // doesn't match the one Nvidia uses for audio data. I'm not exactly sure why,
    // but we can simply replace it with the matrix generated by OpenFEC which
    // works correctly. This is possible because the data and FEC shard count is
    // constant and known in advance.
    const unsigned char parity[] = {0x77, 0x40, 0x38, 0x0e, 0xc7, 0xa7, 0x0d, 0x6c};
    memcpy(rs.get()->p, parity, sizeof(parity));

    audio_packet.rtp.header = 0x80;
    audio_packet.rtp.packetType = 97;
    audio_packet.rtp.ssrc = 0;

    // Audio traffic is sent on this thread
    platf::adjust_thread_priority(platf::thread_priority_e::high);

    while (auto packet = packets->pop()) {
      if (shutdown_event->peek()) {
        break;
      }

      TUPLE_2D_REF(channel_data, packet_data, *packet);
      auto session = (session_t *) channel_data;

      auto sequenceNumber = session->audio.sequenceNumber;
      auto timestamp = session->audio.timestamp;

      *(std::uint32_t *) iv.data() = util::endian::big<std::uint32_t>(session->audio.avRiKeyId + sequenceNumber);

      auto &shards_p = session->audio.shards_p;

      auto bytes = encode_audio(session->config.encryptionFlagsEnabled & SS_ENC_AUDIO, packet_data, shards_p[sequenceNumber % RTPA_DATA_SHARDS], iv, session->audio.cipher);
      if (bytes < 0) {
        BOOST_LOG(error) << "Couldn't encode audio packet"sv;
        break;
      }

      BOOST_LOG(verbose) << "Audio [seq "sv << sequenceNumber << ", pts "sv << timestamp << "] ::  send..."sv;

      audio_packet.rtp.sequenceNumber = util::endian::big(sequenceNumber);
      audio_packet.rtp.timestamp = util::endian::big(timestamp);

      session->audio.sequenceNumber++;
      session->audio.timestamp += session->config.audio.packetDuration;

      auto peer_address = session->audio.peer.address();
      try {
        auto send_info = platf::send_info_t {
          (const char *) &audio_packet,
          sizeof(audio_packet),
          (const char *) shards_p[sequenceNumber % RTPA_DATA_SHARDS],
          (size_t) bytes,
          (uintptr_t) sock.native_handle(),
          peer_address,
          session->audio.peer.port(),
          session->localAddress,
        };
        platf::send(send_info);

        auto &fec_packet = session->audio.fec_packet;
        // initialize the FEC header at the beginning of the FEC block
        if (sequenceNumber % RTPA_DATA_SHARDS == 0) {
          fec_packet.fecHeader.baseSequenceNumber = util::endian::big(sequenceNumber);
          fec_packet.fecHeader.baseTimestamp = util::endian::big(timestamp);
        }

        // generate parity shards at the end of the FEC block
        if ((sequenceNumber + 1) % RTPA_DATA_SHARDS == 0) {
          reed_solomon_encode(rs.get(), shards_p.begin(), RTPA_TOTAL_SHARDS, bytes);

          for (auto x = 0; x < RTPA_FEC_SHARDS; ++x) {
            fec_packet.rtp.sequenceNumber = util::endian::big<std::uint16_t>(sequenceNumber + x + 1);
            fec_packet.fecHeader.fecShardIndex = x;

            auto send_info = platf::send_info_t {
              (const char *) &fec_packet,
              sizeof(fec_packet),
              (const char *) shards_p[RTPA_DATA_SHARDS + x],
              (size_t) bytes,
              (uintptr_t) sock.native_handle(),
              peer_address,
              session->audio.peer.port(),
              session->localAddress,
            };
            platf::send(send_info);
            BOOST_LOG(verbose) << "Audio FEC ["sv << (sequenceNumber & ~(RTPA_DATA_SHARDS - 1)) << ' ' << x << "] ::  send..."sv;
          }
        }
      } catch (const std::exception &e) {
        BOOST_LOG(error) << "Broadcast audio failed "sv << e.what();
        std::this_thread::sleep_for(100ms);
      }
    }

    shutdown_event->raise(true);
  }

  int start_broadcast(broadcast_ctx_t &ctx) {
    auto address_family = net::af_from_enum_string(config::helios.address_family);
    auto protocol = address_family == net::IPV4 ? udp::v4() : udp::v6();
    auto control_port = net::map_port(CONTROL_PORT);
    auto video_port = net::map_port(VIDEO_STREAM_PORT);
    auto audio_port = net::map_port(AUDIO_STREAM_PORT);
    auto microphone_port = net::map_port(MICROPHONE_STREAM_PORT);
    auto camera_port = net::map_port(CAMERA_STREAM_PORT);

    if (ctx.control_server.bind(address_family, control_port)) {
      BOOST_LOG(error) << "Couldn't bind Control server to port ["sv << control_port << "], likely another process already bound to the port"sv;

      return -1;
    }

    boost::system::error_code ec;
    ctx.video_sock.open(protocol, ec);
    if (ec) {
      BOOST_LOG(fatal) << "Couldn't open socket for Video server: "sv << ec.message();

      return -1;
    }

    // Set video socket send buffer size (SO_SENDBUF) to 1MB
    try {
      ctx.video_sock.set_option(boost::asio::socket_base::send_buffer_size(1024 * 1024));
    } catch (...) {
      BOOST_LOG(error) << "Failed to set video socket send buffer size (SO_SENDBUF)";
    }

    ctx.video_sock.bind(udp::endpoint(protocol, video_port), ec);
    if (ec) {
      BOOST_LOG(fatal) << "Couldn't bind Video server to port ["sv << video_port << "]: "sv << ec.message();

      return -1;
    }

    ctx.audio_sock.open(protocol, ec);
    if (ec) {
      BOOST_LOG(fatal) << "Couldn't open socket for Audio server: "sv << ec.message();

      return -1;
    }

    ctx.audio_sock.bind(udp::endpoint(protocol, audio_port), ec);
    if (ec) {
      BOOST_LOG(fatal) << "Couldn't bind Audio server to port ["sv << audio_port << "]: "sv << ec.message();

      return -1;
    }

    ctx.microphone_sock.open(protocol, ec);
    if (ec) {
      BOOST_LOG(fatal) << "Couldn't open socket for Microphone server: "sv << ec.message();
      return -1;
    }
    ctx.microphone_sock.bind(udp::endpoint(protocol, microphone_port), ec);
    if (ec) {
      BOOST_LOG(fatal) << "Couldn't bind Microphone server to port ["sv << microphone_port << "]: "sv << ec.message();
      return -1;
    }

    ctx.camera_sock.open(protocol, ec);
    if (ec) {
      BOOST_LOG(fatal) << "Couldn't open socket for Camera server: "sv << ec.message();
      return -1;
    }
    ctx.camera_sock.bind(udp::endpoint(protocol, camera_port), ec);
    if (ec) {
      BOOST_LOG(fatal) << "Couldn't bind Camera server to port ["sv << camera_port << "]: "sv << ec.message();
      return -1;
    }

    ctx.message_queue_queue = std::make_shared<message_queue_queue_t::element_type>(30);

    ctx.video_thread = std::thread {videoBroadcastThread, std::ref(ctx.video_sock)};
    ctx.audio_thread = std::thread {audioBroadcastThread, std::ref(ctx.audio_sock)};
    ctx.control_thread = std::thread {controlBroadcastThread, &ctx.control_server};

    ctx.recv_thread = std::thread {recvThread, std::ref(ctx)};

    return 0;
  }

  void end_broadcast(broadcast_ctx_t &ctx) {
    auto broadcast_shutdown_event = mail::man->event<bool>(mail::broadcast_shutdown);

    broadcast_shutdown_event->raise(true);

    auto video_packets = mail::man->queue<video::packet_t>(mail::video_packets);
    auto audio_packets = mail::man->queue<audio::packet_t>(mail::audio_packets);

    // Minimize delay stopping video/audio threads
    video_packets->stop();
    audio_packets->stop();

    ctx.message_queue_queue->stop();
    ctx.io_context.stop();

    ctx.video_sock.close();
    ctx.audio_sock.close();
    ctx.microphone_sock.close();
    ctx.camera_sock.close();

    video_packets.reset();
    audio_packets.reset();

    BOOST_LOG(debug) << "Waiting for main listening thread to end..."sv;
    ctx.recv_thread.join();
    BOOST_LOG(debug) << "Waiting for main video thread to end..."sv;
    ctx.video_thread.join();
    BOOST_LOG(debug) << "Waiting for main audio thread to end..."sv;
    ctx.audio_thread.join();
    BOOST_LOG(debug) << "Waiting for main control thread to end..."sv;
    ctx.control_thread.join();
    BOOST_LOG(debug) << "All broadcasting threads ended"sv;

    broadcast_shutdown_event->reset();
  }

  int recv_ping(session_t *session, decltype(broadcast)::ptr_t ref, socket_e type, std::string_view expected_payload, udp::endpoint &peer, std::chrono::milliseconds timeout) {
    auto messages = std::make_shared<message_queue_t::element_type>(30);
    av_session_id_t session_id = std::string {expected_payload};

    // Only allow matches on the peer address for legacy clients
    if (!(session->config.mlFeatureFlags & ML_FF_SESSION_ID_V1)) {
      ref->message_queue_queue->raise(type, peer.address(), messages);
    }
    ref->message_queue_queue->raise(type, session_id, messages);

    auto fg = util::fail_guard([&]() {
      messages->stop();

      // remove message queue from session
      if (!(session->config.mlFeatureFlags & ML_FF_SESSION_ID_V1)) {
        ref->message_queue_queue->raise(type, peer.address(), nullptr);
      }
      ref->message_queue_queue->raise(type, session_id, nullptr);
    });

    auto start_time = std::chrono::steady_clock::now();
    auto current_time = start_time;

    while (current_time - start_time < config::stream.ping_timeout) {
      auto delta_time = current_time - start_time;

      auto msg_opt = messages->pop(config::stream.ping_timeout - delta_time);
      if (!msg_opt) {
        break;
      }

      TUPLE_2D_REF(recv_peer, msg, *msg_opt);
      if (msg.find(expected_payload) != std::string::npos) {
        // Match the new PING payload format
        BOOST_LOG(debug) << "Received ping [v2] from "sv << recv_peer.address() << ':' << recv_peer.port() << " ["sv << util::hex_vec(msg) << ']';
      } else if (!(session->config.mlFeatureFlags & ML_FF_SESSION_ID_V1) && msg == "PING"sv) {
        // Match the legacy fixed PING payload only if the new type is not supported
        BOOST_LOG(debug) << "Received ping [v1] from "sv << recv_peer.address() << ':' << recv_peer.port() << " ["sv << util::hex_vec(msg) << ']';
      } else {
        BOOST_LOG(debug) << "Received non-ping from "sv << recv_peer.address() << ':' << recv_peer.port() << " ["sv << util::hex_vec(msg) << ']';
        current_time = std::chrono::steady_clock::now();
        continue;
      }

      // Update connection details.
      peer = recv_peer;
      return 0;
    }

    BOOST_LOG(error) << "Initial Ping Timeout"sv;
    return -1;
  }

  void videoThread(session_t *session) {
    auto fg = util::fail_guard([&]() {
      session::stop(*session);
    });

    while_starting_do_nothing(session->state);

    auto ref = broadcast.ref();
    auto ping_error = recv_ping(session, ref, socket_e::video, session->video.ping_payload, session->video.peer, config::stream.ping_timeout);
    if (ping_error < 0) {
      return;
    }

    // Enable local prioritization and QoS tagging on video traffic if requested by the client
    auto address = session->video.peer.address();
    session->video.qos = platf::enable_socket_qos(ref->video_sock.native_handle(), address, session->video.peer.port(), platf::qos_data_type_e::video, session->config.videoQosType != 0);

    if (session->config.indexed_display_topology) {
      auto topology = session->display_topology;
      std::unique_lock topology_lock {topology->mutex};
      topology->ready_cv.wait_for(topology_lock, 5s, [session, &topology] {
        return topology->ready ||
               session->state.load(std::memory_order_relaxed) != stream::session::state_e::RUNNING;
      });
      auto selected_output = select_display_output(topology->output_names,
                                                   session->config.display_index);
      if (!selected_output) {
        BOOST_LOG(error) << "Indexed display "sv << session->config.display_index
                         << " was not materialised; refusing to capture a different output"sv;
        return;
      }
      session->config.monitor.output_name = std::move(*selected_output);
      BOOST_LOG(info) << "Indexed video stream "sv << session->config.display_index
                      << " owns virtual output ["sv
                      << session->config.monitor.output_name << ']';
    }

    BOOST_LOG(debug) << "Start capturing Video"sv;
    video::capture(session->mail, session->config.monitor, session);
  }

  void audioThread(session_t *session) {
    auto fg = util::fail_guard([&]() {
      session::stop(*session);
    });

    while_starting_do_nothing(session->state);

    auto ref = broadcast.ref();
    auto error = recv_ping(session, ref, socket_e::audio, session->audio.ping_payload, session->audio.peer, config::stream.ping_timeout);
    if (error < 0) {
      return;
    }

    // Enable local prioritization and QoS tagging on audio traffic if requested by the client
    auto address = session->audio.peer.address();
    session->audio.qos = platf::enable_socket_qos(ref->audio_sock.native_handle(), address, session->audio.peer.port(), platf::qos_data_type_e::audio, session->config.audioQosType != 0);

    BOOST_LOG(debug) << "Start capturing Audio"sv;
    audio::capture(session->mail, session->config.audio, session);
  }

  namespace session {
    std::atomic_uint running_sessions;

    state_e state(session_t &session) {
      return session.state.load(std::memory_order_relaxed);
    }

    inline bool send(session_t& session, const std::string_view &payload) {
      return session.broadcast_ref->control_server.send(payload, session.control.peer);
    }

    void detach_slow_cleanup(const std::shared_ptr<session_t>& session) {
      if (!session || (!session->system_disk_backend && !session->system_disk_tunnel)) {
        return;
      }

      auto backend = std::move(session->system_disk_backend);
      auto tunnel = std::move(session->system_disk_tunnel);
      std::thread([keep_alive = session,
                   backend = std::move(backend),
                   tunnel = std::move(tunnel)]() mutable {
        // Windows iSCSI detach can legitimately take longer than the stream
        // watchdog. Keep both the tunnel and its session owner valid until the
        // bounded detach/verification pass completes, without blocking the
        // control or RTSP threads.
        backend.reset();
        tunnel.reset();
      }).detach();
    }

    std::uint32_t launch_id(const session_t& session) {
      return session.launch_session_id;
    }

    std::string uuid(const session_t& session) {
      return session.device_uuid;
    }

    bool uuid_match(const session_t &session, const std::string_view& uuid) {
      return session.device_uuid == uuid;
    }

    bool update_device_info(session_t& session, const std::string& name, const crypto::PERM& newPerm) {
      session.permission = newPerm;
      if (!(newPerm & crypto::PERM::_allow_view)) {
        BOOST_LOG(debug) << "Session: View permission revoked for [" << session.device_name << "], disconnecting...";
        graceful_stop(session);
        return true;
      }

      BOOST_LOG(debug) << "Session: Permission updated for [" << session.device_name << "]";

      if (session.device_name != name) {
        BOOST_LOG(debug) << "Session: Device name changed from [" << session.device_name << "] to [" << name << "]";
        session.device_name = name;
      }

      return false;
    }

    void stop(session_t &session) {
      while_starting_do_nothing(session.state);
      auto expected = state_e::RUNNING;
      auto already_stopping = !session.state.compare_exchange_strong(expected, state_e::STOPPING);
      if (already_stopping) {
        return;
      }

      session.shutdown_event->raise(true);
    }

    void graceful_stop(session_t& session) {
      while_starting_do_nothing(session.state);
      auto expected = state_e::RUNNING;
      auto already_stopping = !session.state.compare_exchange_strong(expected, state_e::STOPPING);
      if (already_stopping) {
        return;
      }

      // reason: graceful termination
      std::uint32_t reason = 0x80030023;

      control_terminate_t plaintext;
      plaintext.header.type = packetTypes[IDX_TERMINATION];
      plaintext.header.payloadLength = sizeof(plaintext.ec);
      plaintext.ec = util::endian::big<uint32_t>(reason);

      // We may not have gotten far enough to have an ENet connection yet
      if (session.control.peer) {
        std::array<std::uint8_t,
          sizeof(control_encrypted_t) + crypto::cipher::round_to_pkcs7_padded(sizeof(plaintext)) + crypto::cipher::tag_size>
          encrypted_payload;
        auto payload = stream::encode_control(&session, util::view(plaintext), encrypted_payload);

        if (send(session, payload)) {
          TUPLE_2D(port, addr, platf::from_sockaddr_ex((sockaddr *) &session.control.peer->address.address));
          BOOST_LOG(warning) << "Couldn't send termination code to ["sv << addr << ':' << port << ']';
        }
      }

      session.shutdown_event->raise(true);
      session.controlEnd.raise(true);
    }

    void join(session_t &session) {
      // Current Nvidia drivers have a bug where NVENC can deadlock the encoder thread with hardware-accelerated
      // GPU scheduling enabled. If this happens, we will terminate ourselves and the service can restart.
      // The alternative is that Helios can never start another session until it's manually restarted.
      auto task = []() {
        BOOST_LOG(fatal) << "Hang detected! Session failed to terminate in 10 seconds."sv;
        logging::log_flush();
        lifetime::debug_trap();
      };
      auto force_kill = task_pool.pushDelayed(task, 10s).task_id;
      auto fg = util::fail_guard([&force_kill]() {
        // Cancel the kill task if we manage to return from this function
        task_pool.cancel(force_kill);
      });

      BOOST_LOG(info) << "Waiting for video to end..."sv;
      session.videoThread.join();
      BOOST_LOG(info) << "Waiting for audio to end..."sv;
      session.audioThread.join();
      BOOST_LOG(info) << "Waiting for control to end..."sv;
      session.controlEnd.view();
      // Reset input on session stop to avoid stuck repeated keys
      BOOST_LOG(debug) << "Resetting Input..."sv;
      input::reset(session.input);

      if (!session.undo_cmds.empty()) {
        auto exec_thread = std::thread([cmd_list = session.undo_cmds]{
          for (auto &cmd : cmd_list) {
            std::error_code ec;
            auto env = proc::proc.get_env();
            boost::filesystem::path working_dir = proc::find_working_directory(cmd.cmd, env);
            auto child = platf::run_command(cmd.elevated, true, cmd.cmd, working_dir, env, nullptr, ec, nullptr);
            BOOST_LOG(info) << "Spawning client undo command ["sv << cmd.cmd << "] in ["sv << working_dir << ']';
            if (ec) {
              BOOST_LOG(warning) << "Couldn't spawn ["sv << cmd.cmd << "]: System: "sv << ec.message();
            } else {
              child.detach();
            }
          }
        });

        exec_thread.detach();
      }

      // If this is the last session, invoke the platform callbacks
      if (--running_sessions == 0) {
        bool revert_display_config {config::video.dd.config_revert_on_disconnect};
        if (proc::proc.running()) {
          proc::proc.pause();
        } else {
          // We have no app running and also no clients anymore.
          revert_display_config = true;
        }

        if (revert_display_config) {
          display_device::revert_configuration();
        }

        platf::streaming_will_stop();
      }

      BOOST_LOG(info) << "Session ended"sv;
    }

    int start(session_t &session, const std::string &addr_string) {
      session.input = input::alloc(session.mail);

      session.broadcast_ref = broadcast.ref();
      if (!session.broadcast_ref) {
        return -1;
      }

      session.control.expected_peer_address = addr_string;
      BOOST_LOG(debug) << "Expecting incoming session connections from "sv << addr_string;

      // Insert this session into the session list
      {
        auto lg = session.broadcast_ref->control_server._sessions.lock();
        session.broadcast_ref->control_server._sessions->push_back(&session);
      }

      auto addr = boost::asio::ip::make_address(addr_string);
      session.video.peer.address(addr);
      session.video.peer.port(0);

      session.audio.peer.address(addr);
      session.audio.peer.port(0);

      session.pingTimeout = std::chrono::steady_clock::now() + config::stream.ping_timeout;

      session.audioThread = std::thread {audioThread, &session};
      session.videoThread = std::thread {videoThread, &session};

      session.state.store(state_e::RUNNING, std::memory_order_relaxed);

      // If this is the first session, invoke the platform callbacks
      if (++running_sessions == 1) {
        platf::streaming_will_start();
        proc::proc.resume();
      }

      if (!session.do_cmds.empty()) {
        auto exec_thread = std::thread([cmd_list = session.do_cmds]{
          for (auto &cmd : cmd_list) {
            std::error_code ec;
            auto env = proc::proc.get_env();
            boost::filesystem::path working_dir = proc::find_working_directory(cmd.cmd, env);
            auto child = platf::run_command(cmd.elevated, true, cmd.cmd, working_dir, env, nullptr, ec, nullptr);
            BOOST_LOG(info) << "Spawning client do command ["sv << cmd.cmd << "] in ["sv << working_dir << ']';
            if (ec) {
              BOOST_LOG(warning) << "Couldn't spawn ["sv << cmd.cmd << "]: System: "sv << ec.message();
            } else {
              child.detach();
            }
          }
        });

        exec_thread.detach();
      }

      return 0;
    }

    std::shared_ptr<session_t> alloc(config_t &config, rtsp_stream::launch_session_t &launch_session) {
      auto session = std::make_shared<session_t>();
      session->self = session;

      auto mail = std::make_shared<safe::mail_raw_t>();

      session->shutdown_event = mail->event<bool>(mail::shutdown);
      session->launch_session_id = launch_session.id;
      session->device_name = launch_session.device_name;
      session->device_uuid = launch_session.unique_id;
      session->display_topology = display_topology_for_device(session->device_uuid);
      session->permission = launch_session.perm;

      session->do_cmds = std::move(launch_session.client_do_cmds);
      session->undo_cmds = std::move(launch_session.client_undo_cmds);

      session->config = config;

      session->control.connect_data = launch_session.control_connect_data;
      session->control.feedback_queue = mail->queue<platf::gamepad_feedback_msg_t>(mail::gamepad_feedback);
      session->control.hdr_queue = mail->event<video::hdr_info_t>(mail::hdr);
      session->control.legacy_input_enc_iv = launch_session.iv;
      session->control.cipher = crypto::cipher::gcm_t {
        launch_session.gcm_key,
        false
      };
      session->microphone.cipher = crypto::cipher::gcm_t {
        launch_session.gcm_key,
        false
      };
      session->camera.cipher = crypto::cipher::gcm_t {
        launch_session.gcm_key,
        false
      };

      session->video.idr_events = mail->event<bool>(mail::idr);
      session->video.invalidate_ref_frames_events = mail->event<std::pair<int64_t, int64_t>>(mail::invalidate_ref_frames);
      session->video.lowseq = 0;
      session->video.ping_payload = launch_session.av_ping_payload;
      if (config.encryptionFlagsEnabled & SS_ENC_VIDEO) {
        BOOST_LOG(info) << "Video encryption enabled"sv;
        session->video.cipher = crypto::cipher::gcm_t {
          launch_session.gcm_key,
          false
        };
        session->video.gcm_iv_counter = 0;
      }

      constexpr auto max_block_size = crypto::cipher::round_to_pkcs7_padded(2048);

      util::buffer_t<char> shards {RTPA_TOTAL_SHARDS * max_block_size};
      util::buffer_t<uint8_t *> shards_p {RTPA_TOTAL_SHARDS};

      for (auto x = 0; x < RTPA_TOTAL_SHARDS; ++x) {
        shards_p[x] = (uint8_t *) &shards[x * max_block_size];
      }

      // Audio FEC spans multiple audio packets,
      // therefore its session specific
      session->audio.shards = std::move(shards);
      session->audio.shards_p = std::move(shards_p);

      session->audio.fec_packet.rtp.header = 0x80;
      session->audio.fec_packet.rtp.packetType = 127;
      session->audio.fec_packet.rtp.timestamp = 0;
      session->audio.fec_packet.rtp.ssrc = 0;

      session->audio.fec_packet.fecHeader.payloadType = 97;
      session->audio.fec_packet.fecHeader.ssrc = 0;

      session->audio.cipher = crypto::cipher::cbc_t {
        launch_session.gcm_key,
        true
      };

      session->audio.ping_payload = launch_session.av_ping_payload;
      session->audio.avRiKeyId = util::endian::big(*(std::uint32_t *) launch_session.iv.data());
      session->audio.sequenceNumber = 0;
      session->audio.timestamp = 0;

      session->control.peer = nullptr;
      session->state.store(state_e::STOPPED, std::memory_order_relaxed);

      session->mail = std::move(mail);

      return session;
    }
  }  // namespace session
}  // namespace stream
