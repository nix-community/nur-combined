/**
 * @file src/quic_transport.cpp
 * @brief QUIC launch-ticket and transport negotiation primitives.
 */

#include "quic_transport.h"

#include <algorithm>
#include <atomic>
#include <condition_variable>
#include <cstdio>
#include <cstring>
#include <format>
#include <memory>
#include <mutex>
#include <thread>
#include <unordered_set>
#include <vector>

#include <openssl/crypto.h>

#ifdef HAVE_MSQUIC
#include <boost/asio.hpp>
#include "MlosQuicWire.h"
#include "logging.h"
#include "msquic.h"
#include "rtsp.h"
#endif

using namespace std::literals;

namespace quic_transport {
  bool requested(std::string_view value) {
    return value == "1";
  }

  std::string token_hex(const token_t& token) {
    constexpr char hex[] = "0123456789abcdef";
    std::string result(TOKEN_SIZE * 2, '0');
    for (std::size_t i = 0; i < token.size(); ++i) {
      result[i * 2] = hex[token[i] >> 4];
      result[i * 2 + 1] = hex[token[i] & 0x0f];
    }
    return result;
  }

  std::optional<token_t> parse_token(std::string_view value) {
    if (value.size() != TOKEN_SIZE * 2) return std::nullopt;
    auto nibble = [](char c) -> int {
      if (c >= '0' && c <= '9') return c - '0';
      if (c >= 'a' && c <= 'f') return c - 'a' + 10;
      return -1;
    };
    token_t result {};
    for (std::size_t i = 0; i < result.size(); ++i) {
      const int high = nibble(value[i * 2]);
      const int low = nibble(value[i * 2 + 1]);
      if (high < 0 || low < 0) return std::nullopt;
      result[i] = static_cast<std::uint8_t>((high << 4) | low);
    }
    return result;
  }

  std::string session_url(std::string_view escaped_host, std::uint16_t port,
                          const token_t& token) {
    return std::format("quic://{}:{}/{}", escaped_host, port, token_hex(token));
  }

  std::optional<crypto::sha256_t> certificate_sha256(std::string_view pem_certificate) {
    auto certificate = crypto::x509(pem_certificate);
    if (!certificate) return std::nullopt;
    const int length = i2d_X509(certificate.get(), nullptr);
    if (length <= 0) return std::nullopt;
    std::vector<unsigned char> der(static_cast<std::size_t>(length));
    unsigned char* cursor = der.data();
    if (i2d_X509(certificate.get(), &cursor) != length) return std::nullopt;
    return crypto::hash(std::string_view {
      reinterpret_cast<const char*>(der.data()), der.size()
    });
  }

  std::optional<ticket_t> issue_ticket(std::string_view pem_certificate,
                                       std::uint32_t launch_session_id) {
    auto fingerprint = certificate_sha256(pem_certificate);
    if (!fingerprint) return std::nullopt;
    const auto random = crypto::rand(TOKEN_SIZE);
    ticket_t ticket {};
    std::copy(random.begin(), random.end(), ticket.token.begin());
    ticket.client_certificate_sha256 = *fingerprint;
    ticket.launch_session_id = launch_session_id;
    return ticket;
  }

  bool authorize(const ticket_t& ticket, const token_t& token,
                 const crypto::sha256_t& client_certificate_sha256) {
    return CRYPTO_memcmp(ticket.token.data(), token.data(), ticket.token.size()) == 0 &&
           CRYPTO_memcmp(ticket.client_certificate_sha256.data(),
                         client_certificate_sha256.data(),
                         ticket.client_certificate_sha256.size()) == 0;
  }

#ifdef HAVE_MSQUIC
  bool may_claim_stream_channel(std::uint64_t ordinal, std::uint8_t channel,
                                bool auth_stream_claimed, bool authenticated) {
    if (channel == MLOS_QUIC_STREAM_AUTH) {
      return ordinal == 0 && !auth_stream_claimed && !authenticated;
    }
    if (channel == MLOS_QUIC_STREAM_RTSP) {
      // Moonlight-common uses a new TCP connection for each RTSP request. The
      // QUIC bridge mirrors that with a new stream for every request, so only
      // authentication is singleton; sequential RTSP streams are expected.
      return ordinal > 0 && auth_stream_claimed && authenticated;
    }
    return false;
  }
#endif

  ticket_registry_t::ticket_registry_t(std::chrono::seconds lifetime): lifetime_(lifetime) {
  }

  void ticket_registry_t::expire(clock_t::time_point now) {
    for (auto it = entries_.begin(); it != entries_.end();) {
      if (it->second.expires <= now) it = entries_.erase(it);
      else ++it;
    }
  }

  void ticket_registry_t::insert(const ticket_t& ticket, clock_t::time_point now) {
    std::lock_guard lock(mutex_);
    expire(now);
    entries_.insert_or_assign(token_hex(ticket.token), entry_t {ticket, now + lifetime_});
  }

  std::optional<ticket_t> ticket_registry_t::consume(
    const token_t& token,
    const crypto::sha256_t& client_certificate_sha256,
    clock_t::time_point now) {
    std::lock_guard lock(mutex_);
    expire(now);
    const auto it = entries_.find(token_hex(token));
    if (it == entries_.end() ||
        !authorize(it->second.ticket, token, client_certificate_sha256)) return std::nullopt;
    auto ticket = it->second.ticket;
    entries_.erase(it);
    return ticket;
  }

  std::size_t ticket_registry_t::size(clock_t::time_point now) {
    std::lock_guard lock(mutex_);
    expire(now);
    return entries_.size();
  }

  ticket_registry_t& ticket_registry() {
    static ticket_registry_t registry;
    return registry;
  }

#ifdef HAVE_MSQUIC
  namespace {
    constexpr QUIC_UINT62 APP_ERROR_PROTOCOL = 0x100;
    constexpr QUIC_UINT62 APP_ERROR_AUTH = 0x101;
    constexpr std::size_t MAX_DATAGRAM = 1450;

    struct send_buffer_t {
      QUIC_BUFFER buffer;
      std::vector<std::uint8_t> bytes;
      explicit send_buffer_t(std::vector<std::uint8_t> data): bytes(std::move(data)) {
        buffer.Length = static_cast<std::uint32_t>(bytes.size());
        buffer.Buffer = bytes.data();
      }
    };

    struct server_t;
    struct connection_t;

    struct udp_bridge_t {
      connection_t* connection;
      std::uint8_t channel;
      boost::asio::io_context io;
      boost::asio::ip::udp::socket socket {io};
      std::thread reader;
      std::atomic_bool stopping {false};

      udp_bridge_t(connection_t* owner, std::uint8_t channel_, std::uint16_t target_port);
      ~udp_bridge_t();
      bool send_local(const std::uint8_t* data, std::size_t size);
      void stop();
    };

    struct stream_t {
      connection_t* connection;
      HQUIC handle;
      std::uint64_t ordinal;
      std::vector<std::uint8_t> prefix;
      std::uint8_t channel = 0xff;
      std::unique_ptr<boost::asio::io_context> tcp_io;
      std::unique_ptr<boost::asio::ip::tcp::socket> tcp_socket;
      std::thread tcp_reader;
      std::atomic_bool stopping {false};

      stream_t(connection_t* owner, HQUIC stream, std::uint64_t stream_ordinal):
          connection(owner), handle(stream), ordinal(stream_ordinal) {}
      ~stream_t();
      bool consume(const QUIC_BUFFER* buffers, std::uint32_t count);
      bool send_quic(const std::uint8_t* data, std::size_t size);
      bool start_rtsp();
      void stop();
    };

    struct connection_t {
      server_t* server;
      HQUIC handle;
      std::atomic_bool authenticated {false};
      std::atomic_bool peer_certificate_seen {false};
      std::atomic_bool stopping {false};
      std::atomic_uint64_t next_stream_ordinal {0};
      std::mutex stream_channels_mutex;
      bool auth_stream_claimed = false;
      crypto::sha256_t peer_certificate_sha256 {};
      std::uint32_t launch_session_id = 0;
      std::array<std::unique_ptr<udp_bridge_t>, MLOS_QUIC_DATAGRAM_CAMERA + 1> udp;

      connection_t(server_t* owner, HQUIC connection): server(owner), handle(connection) {}
      ~connection_t();
      void shutdown(QUIC_UINT62 error);
      bool send_datagram(std::uint8_t channel, const std::uint8_t* data, std::size_t size);
      bool authenticate(const std::uint8_t* data, std::size_t size);
      bool claim_stream_channel(std::uint64_t ordinal, std::uint8_t channel);
      void start_udp();
      void stop();
    };

    struct server_t {
      const QUIC_API_TABLE* api = nullptr;
      HQUIC registration = nullptr;
      HQUIC configuration = nullptr;
      HQUIC listener = nullptr;
      std::uint16_t base_port = 0;
      std::atomic_bool ready {false};
      std::mutex connections_mutex;
      std::condition_variable connections_changed;
      std::unordered_set<connection_t*> connections;

      ~server_t() { stop(); }
      bool start(const std::string& cert, const std::string& key,
                 std::uint16_t port, std::uint16_t base);
      void stop();
      void add(connection_t* connection);
      void remove(connection_t* connection);
    };

    std::mutex runtime_mutex;
    std::unique_ptr<server_t> runtime;

    void free_send_context(void* context) {
      delete static_cast<send_buffer_t*>(context);
    }

    bool api_succeeded(QUIC_STATUS status, const char* operation) {
      if (QUIC_SUCCEEDED(status)) return true;
      std::fprintf(stderr, "Moonlight OS QUIC: %s failed (0x%x)\n",
                   operation, static_cast<unsigned int>(status));
      return false;
    }

    QUIC_STATUS QUIC_API stream_callback(HQUIC stream, void* context, QUIC_STREAM_EVENT* event) {
      auto state = static_cast<stream_t*>(context);
      switch (event->Type) {
        case QUIC_STREAM_EVENT_RECEIVE:
          if (!state->consume(event->RECEIVE.Buffers, event->RECEIVE.BufferCount)) {
            state->connection->shutdown(APP_ERROR_PROTOCOL);
          }
          break;
        case QUIC_STREAM_EVENT_SEND_COMPLETE:
          free_send_context(event->SEND_COMPLETE.ClientContext);
          break;
        case QUIC_STREAM_EVENT_PEER_SEND_ABORTED:
        case QUIC_STREAM_EVENT_PEER_RECEIVE_ABORTED:
          state->stop();
          break;
        case QUIC_STREAM_EVENT_SHUTDOWN_COMPLETE:
          state->stop();
          if (!event->SHUTDOWN_COMPLETE.AppCloseInProgress) state->connection->server->api->StreamClose(stream);
          delete state;
          break;
        default:
          break;
      }
      return QUIC_STATUS_SUCCESS;
    }

    QUIC_STATUS QUIC_API connection_callback(HQUIC connection, void* context,
                                             QUIC_CONNECTION_EVENT* event) {
      auto state = static_cast<connection_t*>(context);
      switch (event->Type) {
        case QUIC_CONNECTION_EVENT_PEER_CERTIFICATE_RECEIVED: {
          auto certificate = reinterpret_cast<const QUIC_BUFFER*>(
            event->PEER_CERTIFICATE_RECEIVED.Certificate);
          if (certificate && certificate->Buffer && certificate->Length) {
            state->peer_certificate_sha256 = crypto::hash(std::string_view {
              reinterpret_cast<const char*>(certificate->Buffer), certificate->Length
            });
            state->peer_certificate_seen = true;
          }
          break;
        }
        case QUIC_CONNECTION_EVENT_CONNECTED:
          BOOST_LOG(::debug) << "Moonlight OS QUIC: client connected"sv;
          state->server->api->ConnectionSendResumptionTicket(
            connection, QUIC_SEND_RESUMPTION_FLAG_NONE, 0, nullptr);
          break;
        case QUIC_CONNECTION_EVENT_SHUTDOWN_INITIATED_BY_TRANSPORT:
          BOOST_LOG(::debug) << "Moonlight OS QUIC: transport shutdown [status: "sv
                             << event->SHUTDOWN_INITIATED_BY_TRANSPORT.Status
                             << ", error: "sv
                             << event->SHUTDOWN_INITIATED_BY_TRANSPORT.ErrorCode << ']';
          break;
        case QUIC_CONNECTION_EVENT_SHUTDOWN_INITIATED_BY_PEER:
          BOOST_LOG(::debug) << "Moonlight OS QUIC: peer shutdown [error: "sv
                          << event->SHUTDOWN_INITIATED_BY_PEER.ErrorCode << ']';
          break;
        case QUIC_CONNECTION_EVENT_PEER_STREAM_STARTED: {
          const auto ordinal = state->next_stream_ordinal.fetch_add(1);
          auto stream_state = new (std::nothrow) stream_t(
            state, event->PEER_STREAM_STARTED.Stream, ordinal);
          if (!stream_state) return QUIC_STATUS_OUT_OF_MEMORY;
          state->server->api->SetCallbackHandler(event->PEER_STREAM_STARTED.Stream,
                                                  reinterpret_cast<void*>(stream_callback),
                                                  stream_state);
          break;
        }
        case QUIC_CONNECTION_EVENT_DATAGRAM_RECEIVED: {
          if (!state->authenticated) {
            state->shutdown(APP_ERROR_AUTH);
            break;
          }
          const auto buffer = event->DATAGRAM_RECEIVED.Buffer;
          MLOS_QUIC_DATAGRAM_HEADER header {};
          if (!buffer || !MlosQuicDecodeDatagramHeader(buffer->Buffer, buffer->Length, &header) ||
              header.flags != 0 ||
              header.channel >= state->udp.size() || !state->udp[header.channel] ||
              !state->udp[header.channel]->send_local(
                buffer->Buffer + MLOS_QUIC_DATAGRAM_HEADER_SIZE, header.payloadLength)) {
            state->shutdown(APP_ERROR_PROTOCOL);
          }
          break;
        }
        case QUIC_CONNECTION_EVENT_DATAGRAM_SEND_STATE_CHANGED:
          if (QUIC_DATAGRAM_SEND_STATE_IS_FINAL(event->DATAGRAM_SEND_STATE_CHANGED.State)) {
            free_send_context(event->DATAGRAM_SEND_STATE_CHANGED.ClientContext);
          }
          break;
        case QUIC_CONNECTION_EVENT_SHUTDOWN_COMPLETE:
          BOOST_LOG(::debug) << "Moonlight OS QUIC: connection shutdown complete"sv;
          state->stop();
          state->server->remove(state);
          if (!event->SHUTDOWN_COMPLETE.AppCloseInProgress) state->server->api->ConnectionClose(connection);
          delete state;
          break;
        default:
          break;
      }
      return QUIC_STATUS_SUCCESS;
    }

    QUIC_STATUS QUIC_API listener_callback(HQUIC, void* context, QUIC_LISTENER_EVENT* event) {
      auto server = static_cast<server_t*>(context);
      if (event->Type != QUIC_LISTENER_EVENT_NEW_CONNECTION) return QUIC_STATUS_NOT_SUPPORTED;
      auto connection = new (std::nothrow) connection_t(server, event->NEW_CONNECTION.Connection);
      if (!connection) return QUIC_STATUS_OUT_OF_MEMORY;
      server->add(connection);
      server->api->SetCallbackHandler(event->NEW_CONNECTION.Connection,
                                      reinterpret_cast<void*>(connection_callback), connection);
      const auto status = server->api->ConnectionSetConfiguration(
        event->NEW_CONNECTION.Connection, server->configuration);
      if (QUIC_FAILED(status)) {
        server->remove(connection);
        delete connection;
      }
      return status;
    }

    udp_bridge_t::udp_bridge_t(connection_t* owner, std::uint8_t channel_,
                               std::uint16_t target_port): connection(owner), channel(channel_) {
      using boost::asio::ip::udp;
      boost::system::error_code error;
      socket.open(udp::v4(), error);
      if (error) return;
      socket.bind(udp::endpoint(boost::asio::ip::address_v4::loopback(), 0), error);
      if (error) return;
      socket.connect(udp::endpoint(boost::asio::ip::address_v4::loopback(), target_port), error);
      if (error) return;
      socket.non_blocking(true, error);
      if (error) return;
      reader = std::thread([this] {
        std::array<std::uint8_t, MAX_DATAGRAM> bytes {};
        while (!stopping) {
          boost::system::error_code error;
          const auto size = socket.receive(boost::asio::buffer(bytes), 0, error);
          if (error == boost::asio::error::would_block ||
              error == boost::asio::error::try_again) {
            std::this_thread::sleep_for(std::chrono::milliseconds(2));
            continue;
          }
          if (error) break;
          if (size && !connection->send_datagram(channel, bytes.data(), size)) {
            connection->shutdown(APP_ERROR_PROTOCOL);
            break;
          }
        }
      });
    }

    udp_bridge_t::~udp_bridge_t() { stop(); }

    bool udp_bridge_t::send_local(const std::uint8_t* data, std::size_t size) {
      boost::system::error_code error;
      return socket.send(boost::asio::buffer(data, size), 0, error) == size && !error;
    }

    void udp_bridge_t::stop() {
      if (stopping.exchange(true)) return;
      boost::system::error_code error;
      socket.close(error);
      if (reader.joinable() && reader.get_id() != std::this_thread::get_id()) reader.join();
    }

    stream_t::~stream_t() { stop(); }

    bool stream_t::send_quic(const std::uint8_t* data, std::size_t size) {
      auto context = new (std::nothrow) send_buffer_t(
        std::vector<std::uint8_t>(data, data + size));
      if (!context) return false;
      const auto status = connection->server->api->StreamSend(
        handle, &context->buffer, 1, QUIC_SEND_FLAG_NONE, context);
      if (QUIC_FAILED(status)) delete context;
      return QUIC_SUCCEEDED(status);
    }

    bool stream_t::start_rtsp() {
      using boost::asio::ip::tcp;
      tcp_io = std::make_unique<boost::asio::io_context>();
      tcp_socket = std::make_unique<tcp::socket>(*tcp_io);
      boost::system::error_code error;
      tcp_socket->open(tcp::v4(), error);
      if (error) return false;
      tcp_socket->bind(tcp::endpoint(boost::asio::ip::address_v4::loopback(), 0), error);
      if (error) return false;
      const auto local_port = tcp_socket->local_endpoint(error).port();
      if (error || !rtsp_stream::register_quic_rtsp_proxy(
                     local_port, connection->launch_session_id)) {
        BOOST_LOG(::error) << "Moonlight OS QUIC: could not register RTSP proxy for launch ["sv
                         << connection->launch_session_id << ']';
        return false;
      }
      tcp_socket->connect(tcp::endpoint(boost::asio::ip::address_v4::loopback(),
                                       connection->server->base_port + 21), error);
      if (error) {
        rtsp_stream::unregister_quic_rtsp_proxy(local_port);
        BOOST_LOG(::error) << "Moonlight OS QUIC: could not connect RTSP proxy ["sv
                         << error.message() << ']';
        return false;
      }
      BOOST_LOG(::debug) << "Moonlight OS QUIC: RTSP stream connected through local port ["sv
                      << local_port << "] for launch ["sv
                      << connection->launch_session_id << ']';
      tcp_reader = std::thread([this] {
        std::array<std::uint8_t, 16384> bytes {};
        while (!stopping) {
          boost::system::error_code error;
          const auto size = tcp_socket->read_some(boost::asio::buffer(bytes), error);
          if (size && !send_quic(bytes.data(), size)) {
            BOOST_LOG(::error) << "Moonlight OS QUIC: could not forward RTSP response"sv;
            connection->shutdown(APP_ERROR_PROTOCOL);
            break;
          }
          if (error) {
            if (!stopping && error == boost::asio::error::eof) {
              connection->server->api->StreamShutdown(
                handle, QUIC_STREAM_SHUTDOWN_FLAG_GRACEFUL, 0);
            } else if (!stopping && error != boost::asio::error::operation_aborted) {
              connection->shutdown(APP_ERROR_PROTOCOL);
            }
            break;
          }
        }
      });
      return true;
    }

    bool stream_t::consume(const QUIC_BUFFER* buffers, std::uint32_t count) {
      std::vector<std::uint8_t> incoming;
      for (std::uint32_t i = 0; i < count; ++i) {
        incoming.insert(incoming.end(), buffers[i].Buffer, buffers[i].Buffer + buffers[i].Length);
      }
      std::size_t offset = 0;
      if (channel == 0xff) {
        const auto needed = MLOS_QUIC_STREAM_PREFACE_SIZE - prefix.size();
        const auto take = std::min(needed, incoming.size());
        prefix.insert(prefix.end(), incoming.begin(), incoming.begin() + take);
        offset += take;
        if (prefix.size() < MLOS_QUIC_STREAM_PREFACE_SIZE) return true;
        MLOS_QUIC_STREAM_PREFACE preface {};
        if (!MlosQuicDecodeStreamPreface(prefix.data(), prefix.size(), &preface)) return false;
        if (preface.flags != 0) return false;
        channel = preface.channel;
        prefix.clear();
        if (!connection->claim_stream_channel(ordinal, channel)) return false;
        if (channel == MLOS_QUIC_STREAM_RTSP) {
          if (!connection->authenticated || !start_rtsp()) {
            BOOST_LOG(::error) << "Moonlight OS QUIC: rejected RTSP stream [ordinal: "sv
                             << ordinal << ']';
            return false;
          }
        } else if (channel != MLOS_QUIC_STREAM_AUTH || connection->authenticated) {
          return false;
        }
      }
      if (channel == MLOS_QUIC_STREAM_AUTH) {
        prefix.insert(prefix.end(), incoming.begin() + offset, incoming.end());
        if (prefix.size() > MLOS_QUIC_AUTH_SIZE) return false;
        if (prefix.size() == MLOS_QUIC_AUTH_SIZE) {
          if (!connection->authenticate(prefix.data(), prefix.size())) return false;
          const std::uint8_t accepted = 1;
          if (!send_quic(&accepted, 1)) return false;
          prefix.clear();
        }
        return true;
      }
      if (channel == MLOS_QUIC_STREAM_RTSP && offset < incoming.size()) {
        boost::system::error_code error;
        const auto forwarded = boost::asio::write(*tcp_socket,
          boost::asio::buffer(incoming.data() + offset, incoming.size() - offset), error) ==
          incoming.size() - offset && !error;
        if (!forwarded) {
          BOOST_LOG(::error) << "Moonlight OS QUIC: could not forward RTSP request ["sv
                           << error.message() << ']';
        }
        return forwarded;
      }
      return true;
    }

    void stream_t::stop() {
      if (stopping.exchange(true)) return;
      if (tcp_socket) {
        boost::system::error_code error;
        tcp_socket->cancel(error);
        tcp_socket->close(error);
      }
      if (tcp_reader.joinable() && tcp_reader.get_id() != std::this_thread::get_id()) tcp_reader.join();
    }

    connection_t::~connection_t() { stop(); }

    void connection_t::shutdown(QUIC_UINT62 error) {
      server->api->ConnectionShutdown(handle, QUIC_CONNECTION_SHUTDOWN_FLAG_NONE, error);
    }

    bool connection_t::send_datagram(std::uint8_t channel, const std::uint8_t* data,
                                     std::size_t size) {
      if (!authenticated || size == 0 || size > UINT16_MAX ||
          size + MLOS_QUIC_DATAGRAM_HEADER_SIZE > MAX_DATAGRAM) return false;
      std::vector<std::uint8_t> packet(MLOS_QUIC_DATAGRAM_HEADER_SIZE + size);
      if (!MlosQuicEncodeDatagramHeader(packet.data(), MLOS_QUIC_DATAGRAM_HEADER_SIZE,
                                       channel, 0, static_cast<std::uint16_t>(size))) return false;
      std::copy(data, data + size, packet.begin() + MLOS_QUIC_DATAGRAM_HEADER_SIZE);
      auto context = new (std::nothrow) send_buffer_t(std::move(packet));
      if (!context) return false;
      const auto status = server->api->DatagramSend(handle, &context->buffer, 1,
                                                     QUIC_SEND_FLAG_NONE, context);
      if (QUIC_FAILED(status)) delete context;
      return QUIC_SUCCEEDED(status);
    }

    bool connection_t::authenticate(const std::uint8_t* data, std::size_t size) {
      MLOS_QUIC_AUTH auth {};
      if (!peer_certificate_seen || !MlosQuicDecodeAuth(data, size, &auth) ||
          CRYPTO_memcmp(peer_certificate_sha256.data(), auth.clientCertificateSha256,
                        peer_certificate_sha256.size()) != 0) return false;
      token_t token {};
      crypto::sha256_t certificate {};
      std::copy(std::begin(auth.token), std::end(auth.token), token.begin());
      std::copy(std::begin(auth.clientCertificateSha256),
                std::end(auth.clientCertificateSha256), certificate.begin());
      auto ticket = ticket_registry().consume(token, certificate);
      if (!ticket) return false;
      launch_session_id = ticket->launch_session_id;
      authenticated = true;
      BOOST_LOG(::debug) << "Moonlight OS QUIC: authenticated launch ["sv
                      << launch_session_id << ']';
      start_udp();
      return true;
    }

    bool connection_t::claim_stream_channel(std::uint64_t ordinal, std::uint8_t channel) {
      std::lock_guard lock(stream_channels_mutex);
      if (!may_claim_stream_channel(ordinal, channel, auth_stream_claimed, authenticated)) {
        return false;
      }
      if (channel == MLOS_QUIC_STREAM_AUTH) {
        auth_stream_claimed = true;
      }
      return true;
    }

    void connection_t::start_udp() {
      const std::array<std::uint16_t, MLOS_QUIC_DATAGRAM_CAMERA + 1> offsets {
        0, 9, 11, 10, 0, 12, 13
      };
      for (std::uint8_t channel = MLOS_QUIC_DATAGRAM_VIDEO;
           channel <= MLOS_QUIC_DATAGRAM_CAMERA; ++channel) {
        if (offsets[channel] != 0) {
          udp[channel] = std::make_unique<udp_bridge_t>(this, channel,
                                                       server->base_port + offsets[channel]);
        }
      }
    }

    void connection_t::stop() {
      if (stopping.exchange(true)) return;
      for (auto& bridge : udp) bridge.reset();
      if (launch_session_id != 0) {
        rtsp_stream::stop_session_by_launch_id(launch_session_id);
      }
    }

    void server_t::add(connection_t* connection) {
      std::lock_guard lock(connections_mutex);
      connections.insert(connection);
    }

    void server_t::remove(connection_t* connection) {
      std::lock_guard lock(connections_mutex);
      connections.erase(connection);
      connections_changed.notify_all();
    }

    bool server_t::start(const std::string& cert, const std::string& key,
                         std::uint16_t port, std::uint16_t base) {
      base_port = base;
      if (!api_succeeded(MsQuicOpen2(&api), "MsQuicOpen2")) return false;
      const QUIC_REGISTRATION_CONFIG registration_config {
        "Helios Moonlight OS", QUIC_EXECUTION_PROFILE_LOW_LATENCY
      };
      if (!api_succeeded(api->RegistrationOpen(&registration_config, &registration),
                         "RegistrationOpen")) return false;
      QUIC_SETTINGS settings {};
      settings.IdleTimeoutMs = 30000;
      settings.IsSet.IdleTimeoutMs = TRUE;
      settings.KeepAliveIntervalMs = 1000;
      settings.IsSet.KeepAliveIntervalMs = TRUE;
      // RTSP uses several short-lived request streams during one handshake.
      // Leave enough credit for those streams to overlap while their graceful
      // shutdown callbacks are still being delivered.
      settings.PeerBidiStreamCount = 32;
      settings.IsSet.PeerBidiStreamCount = TRUE;
      settings.DatagramReceiveEnabled = TRUE;
      settings.IsSet.DatagramReceiveEnabled = TRUE;
      settings.MigrationEnabled = TRUE;
      settings.IsSet.MigrationEnabled = TRUE;
      settings.MinimumMtu = 1280;
      settings.MaximumMtu = 1500;
      settings.IsSet.MinimumMtu = settings.IsSet.MaximumMtu = TRUE;
      QUIC_BUFFER alpn {sizeof(MLOS_QUIC_ALPN) - 1,
                        reinterpret_cast<std::uint8_t*>(const_cast<char*>(MLOS_QUIC_ALPN))};
      if (!api_succeeded(api->ConfigurationOpen(registration, &alpn, 1, &settings,
                                                sizeof(settings), nullptr, &configuration),
                         "ConfigurationOpen")) return false;
      QUIC_CERTIFICATE_FILE certificate_file {key.c_str(), cert.c_str()};
      QUIC_CREDENTIAL_CONFIG credential {};
      credential.Type = QUIC_CREDENTIAL_TYPE_CERTIFICATE_FILE;
      credential.CertificateFile = &certificate_file;
      credential.Flags = static_cast<QUIC_CREDENTIAL_FLAGS>(
        QUIC_CREDENTIAL_FLAG_REQUIRE_CLIENT_AUTHENTICATION |
        QUIC_CREDENTIAL_FLAG_NO_CERTIFICATE_VALIDATION |
        QUIC_CREDENTIAL_FLAG_INDICATE_CERTIFICATE_RECEIVED |
        QUIC_CREDENTIAL_FLAG_USE_PORTABLE_CERTIFICATES);
      if (!api_succeeded(api->ConfigurationLoadCredential(configuration, &credential),
                         "ConfigurationLoadCredential")) return false;
      if (!api_succeeded(api->ListenerOpen(registration, listener_callback, this, &listener),
                         "ListenerOpen")) return false;
      QUIC_ADDR address {};
      QuicAddrSetFamily(&address, QUIC_ADDRESS_FAMILY_UNSPEC);
      QuicAddrSetPort(&address, port);
      if (!api_succeeded(api->ListenerStart(listener, &alpn, 1, &address),
                         "ListenerStart")) return false;
      ready = true;
      return true;
    }

    void server_t::stop() {
      if (ready.exchange(false) && listener) api->ListenerStop(listener);
      if (registration && api) api->RegistrationShutdown(
        registration, QUIC_CONNECTION_SHUTDOWN_FLAG_SILENT, 0);
      {
        std::unique_lock lock(connections_mutex);
        connections_changed.wait_for(lock, std::chrono::seconds(5), [this] {
          return connections.empty();
        });
      }
      if (listener && api) api->ListenerClose(listener);
      listener = nullptr;
      if (configuration && api) api->ConfigurationClose(configuration);
      configuration = nullptr;
      if (registration && api) api->RegistrationClose(registration);
      registration = nullptr;
      if (api) MsQuicClose(api);
      api = nullptr;
    }
  }
#endif

  bool start_server(const std::string& certificate_file, const std::string& private_key_file,
                    std::uint16_t listen_port, std::uint16_t base_port) {
#ifdef HAVE_MSQUIC
    std::lock_guard lock(runtime_mutex);
    if (runtime) return runtime->ready;
    auto server = std::make_unique<server_t>();
    if (!server->start(certificate_file, private_key_file, listen_port, base_port)) return false;
    runtime = std::move(server);
    return true;
#else
    (void)certificate_file;
    (void)private_key_file;
    (void)listen_port;
    (void)base_port;
    return false;
#endif
  }

  void stop_server() {
#ifdef HAVE_MSQUIC
    std::unique_ptr<server_t> server;
    {
      std::lock_guard lock(runtime_mutex);
      server = std::move(runtime);
    }
    if (server) server->stop();
#endif
  }

  bool available() {
#ifdef HAVE_MSQUIC
    std::lock_guard lock(runtime_mutex);
    return runtime && runtime->ready;
#else
    return false;
#endif
  }
}  // namespace quic_transport
