/**
 * @file src/quic_transport.h
 * @brief QUIC launch-ticket and transport negotiation primitives.
 */
#pragma once

#include <array>
#include <chrono>
#include <cstdint>
#include <mutex>
#include <optional>
#include <string>
#include <string_view>
#include <unordered_map>

#include "crypto.h"

namespace quic_transport {
  constexpr std::uint16_t PORT = 14;
  constexpr std::size_t TOKEN_SIZE = 32;

  using token_t = std::array<std::uint8_t, TOKEN_SIZE>;

  struct ticket_t {
    token_t token;
    crypto::sha256_t client_certificate_sha256;
    std::uint32_t launch_session_id = 0;
  };

  bool requested(std::string_view value);
  std::string token_hex(const token_t& token);
  std::optional<token_t> parse_token(std::string_view value);
  std::string session_url(std::string_view escaped_host, std::uint16_t port,
                          const token_t& token);
  std::optional<crypto::sha256_t> certificate_sha256(std::string_view pem_certificate);
  std::optional<ticket_t> issue_ticket(std::string_view pem_certificate,
                                       std::uint32_t launch_session_id);
  bool authorize(const ticket_t& ticket, const token_t& token,
                 const crypto::sha256_t& client_certificate_sha256);
#ifdef HAVE_MSQUIC
  bool may_claim_stream_channel(std::uint64_t ordinal, std::uint8_t channel,
                                bool auth_stream_claimed, bool authenticated);
#endif

  class ticket_registry_t {
  public:
    using clock_t = std::chrono::steady_clock;
    explicit ticket_registry_t(std::chrono::seconds lifetime = std::chrono::seconds(30));
    void insert(const ticket_t& ticket, clock_t::time_point now = clock_t::now());
    std::optional<ticket_t> consume(
      const token_t& token,
      const crypto::sha256_t& client_certificate_sha256,
      clock_t::time_point now = clock_t::now());
    std::size_t size(clock_t::time_point now = clock_t::now());

  private:
    struct entry_t {
      ticket_t ticket;
      clock_t::time_point expires;
    };
    void expire(clock_t::time_point now);
    std::chrono::seconds lifetime_;
    std::mutex mutex_;
    std::unordered_map<std::string, entry_t> entries_;
  };

  ticket_registry_t& ticket_registry();
  bool start_server(const std::string& certificate_file, const std::string& private_key_file,
                    std::uint16_t listen_port, std::uint16_t base_port);
  void stop_server();
  bool available();
}  // namespace quic_transport
