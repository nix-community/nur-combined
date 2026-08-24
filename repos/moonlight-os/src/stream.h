/**
 * @file src/stream.h
 * @brief Declarations for the streaming protocols.
 */
#pragma once

// standard includes
#include <cstdint>
#include <optional>
#include <map>
#include <set>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

// lib includes
#include <boost/asio.hpp>

// local includes
#include "audio.h"
#include "crypto.h"
#include "video.h"

namespace rtsp_stream {
  struct launch_session_t;
}

namespace stream {
  constexpr auto VIDEO_STREAM_PORT = 9;
  constexpr auto CONTROL_PORT = 10;
  constexpr auto AUDIO_STREAM_PORT = 11;
  constexpr auto MICROPHONE_STREAM_PORT = 12;
  constexpr auto CAMERA_STREAM_PORT = 13;

  struct session_t;

  struct usb_device_t {
    std::string busid;
    std::string hwid;
    std::string label;
  };

  struct usb_attachment_t {
    std::string busid;
    int port;
  };

  enum class usb_sync_action_e {
    attach,
    detach,
  };

  struct usb_sync_action_t {
    usb_sync_action_e action;
    usb_device_t device;
    int port;
  };

  struct microphone_packet_t {
    std::uint32_t connect_data = 0;
    std::uint64_t sequence = 0;
    std::uint32_t timestamp = 0;
    std::uint16_t samples = 0;
    std::uint8_t channels = 0;
    std::vector<std::uint8_t> opus;
  };

  struct camera_fragment_t {
    std::uint32_t connect_data = 0;
    std::uint64_t sequence = 0;
    std::uint32_t frame_id = 0;
    std::uint32_t timestamp_ms = 0;
    std::uint16_t width = 0;
    std::uint16_t height = 0;
    std::uint8_t format = 0;
    std::uint16_t fragment_index = 0;
    std::uint16_t fragment_count = 0;
    std::uint32_t frame_length = 0;
    std::uint32_t offset = 0;
    std::vector<std::uint8_t> data;
  };

  struct camera_frame_t {
    std::uint32_t frame_id = 0;
    std::uint32_t timestamp_ms = 0;
    std::uint16_t width = 0;
    std::uint16_t height = 0;
    std::vector<std::uint8_t> bytes;
  };

  struct display_desc_t {
    std::int32_t x = 0;
    std::int32_t y = 0;
    std::uint32_t width = 0;
    std::uint32_t height = 0;
    std::uint32_t refresh_millihz = 0;
    std::uint32_t scale_milli = 1000;
    std::uint16_t physical_width_mm = 0;
    std::uint16_t physical_height_mm = 0;
    std::uint16_t flags = 0;
  };

  bool parse_display_topology(std::string_view payload,
                              std::uint32_t &generation,
                              std::vector<display_desc_t> &displays);

  struct system_disk_offer_t {
    std::uint32_t generation = 0;
    std::uint64_t size = 0;
    std::uint32_t sector_size = 0;
    std::string target_iqn;

    bool present() const { return !target_iqn.empty(); }
  };

  // Parses a complete declarative snapshot. An empty IQN is a withdrawal;
  // a present disk must explicitly carry the kernel-enforced read-only flag.
  // Outputs are replaced only after the entire packet has validated.
  bool parse_system_disk_offer(std::string_view payload,
                               system_disk_offer_t &offer);

  std::optional<std::string> select_display_output(
    const std::vector<std::string> &output_names,
    std::uint16_t display_index);

  bool parse_feature_advertisement(
    std::string_view payload,
    std::map<std::uint16_t, std::uint16_t> &features);

  std::map<std::uint16_t, std::uint16_t> negotiate_features(
    const std::map<std::uint16_t, std::uint16_t> &advertised,
    const std::map<std::uint16_t, std::uint16_t> &supported);

  // Returns only protocol features that this build can actually terminate on
  // the current platform. Camera and display-topology support additionally
  // require published platform endpoints, so unavailable backends must not be
  // advertised and then accepted only halfway through a session.
  std::map<std::uint16_t, std::uint16_t> host_supported_features(
    bool virtual_camera_available,
    bool virtual_display_topology_available);

  class camera_frame_assembler_t {
  public:
    std::optional<camera_frame_t> accept(const camera_fragment_t &fragment,
                                         std::uint64_t arrival_ms);

  private:
    bool has_frame_ = false;
    std::uint32_t frame_id_ = 0;
    std::uint32_t timestamp_ms_ = 0;
    std::uint16_t width_ = 0;
    std::uint16_t height_ = 0;
    std::uint16_t fragment_count_ = 0;
    std::uint32_t frame_length_ = 0;
    std::uint64_t deadline_ms_ = 0;
    std::vector<std::uint8_t> bytes_;
    std::vector<bool> received_;
    std::size_t received_count_ = 0;
    std::set<std::uint64_t> sequences_;
  };

  // Decode and authenticate one bounded microphone datagram. The sequence is
  // used as a microphone-specific AES-GCM nonce; callers still enforce replay
  // policy because UDP packets may arrive out of order.
  bool decode_microphone_packet(std::string_view payload,
                                crypto::cipher::gcm_t &cipher,
                                microphone_packet_t &packet);

  // Decode and authenticate one bounded camera fragment. Frame assembly is a
  // separate step so malformed offsets/counts can be unit-tested and a lost
  // UDP fragment drops only its frame, never later frames.
  bool decode_camera_fragment(std::string_view payload,
                              crypto::cipher::gcm_t &cipher,
                              camera_fragment_t &fragment);

  // Parse the bounded, declarative USB device-set message used by the M2
  // extension. Exposed here so hostile/truncated packets can be unit-tested
  // without constructing a live control session.
  bool parse_usb_device_offer(const std::string_view &payload,
                              std::uint32_t &generation,
                              std::vector<usb_device_t> &devices);

  // Produce a deterministic declarative reconciliation plan. New devices are
  // attached before stale ones are detached so replacing a force-feedback
  // device never creates an avoidable ownership gap.
  std::vector<usb_sync_action_t> plan_usb_device_sync(
    const std::vector<usb_attachment_t> &current,
    const std::vector<usb_device_t> &offered);

  bool parse_usb_tunnel_data(const std::string_view &payload,
                             std::uint32_t &id,
                             std::string_view &data);
  bool parse_usb_tunnel_close(const std::string_view &payload,
                              std::uint32_t &id,
                              std::uint16_t &reason);

  struct config_t {
    audio::config_t audio;
    video::config_t monitor;

    int packetsize;
    int minRequiredFecPackets;
    int mlFeatureFlags;
    int controlProtocolType;
    int audioQosType;
    int videoQosType;

    uint32_t encryptionFlagsEnabled;

    bool indexed_display_topology = false;
    std::uint16_t display_index = 0;

    std::optional<int> gcmap;
  };

  namespace session {
    enum class state_e : int {
      STOPPED,  ///< The session is stopped
      STOPPING,  ///< The session is stopping
      STARTING,  ///< The session is starting
      RUNNING,  ///< The session is running
    };

    std::shared_ptr<session_t> alloc(config_t &config, rtsp_stream::launch_session_t &launch_session);
    void detach_slow_cleanup(const std::shared_ptr<session_t>& session);
    std::uint32_t launch_id(const session_t& session);
    std::string uuid(const session_t& session);
    bool uuid_match(const session_t& session, const std::string_view& uuid);
    bool update_device_info(session_t& session, const std::string& name, const crypto::PERM& newPerm);
    int start(session_t &session, const std::string &addr_string);
    void stop(session_t &session);
    void graceful_stop(session_t& session);
    void join(session_t &session);
    state_e state(session_t &session);
    inline bool send(session_t& session, const std::string_view &payload);
  }  // namespace session
}  // namespace stream
