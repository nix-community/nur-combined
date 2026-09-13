#include <gtest/gtest.h>

#include "src/crypto.h"
#include "src/quic_transport.h"

#if defined(HAVE_MSQUIC) && defined(__linux__)

#include <sys/mman.h>
#include <unistd.h>

#include <array>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstring>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#include <boost/asio.hpp>
#include <msquic.h>

extern "C" {
#include "moonlight-common-c/src/MlosQuicWire.h"
}

namespace {
  using namespace std::chrono_literals;

  class memory_file_t {
  public:
    memory_file_t(const char *name, const std::string &contents) {
      fd_ = memfd_create(name, MFD_CLOEXEC);
      if (fd_ < 0) return;
      std::size_t offset = 0;
      while (offset < contents.size()) {
        const auto written = write(fd_, contents.data() + offset, contents.size() - offset);
        if (written <= 0) {
          close(fd_);
          fd_ = -1;
          return;
        }
        offset += static_cast<std::size_t>(written);
      }
      path_ = "/proc/self/fd/" + std::to_string(fd_);
    }

    ~memory_file_t() {
      if (fd_ >= 0) close(fd_);
    }

    memory_file_t(const memory_file_t &) = delete;
    memory_file_t &operator=(const memory_file_t &) = delete;
    bool valid() const { return fd_ >= 0; }
    const std::string &path() const { return path_; }

  private:
    int fd_ = -1;
    std::string path_;
  };

  struct send_context_t {
    QUIC_BUFFER buffer {};
    std::vector<std::uint8_t> bytes;
    explicit send_context_t(std::vector<std::uint8_t> value): bytes(std::move(value)) {
      buffer.Length = static_cast<std::uint32_t>(bytes.size());
      buffer.Buffer = bytes.data();
    }
  };

  class loopback_client_t {
  public:
    ~loopback_client_t() { stop(); }

    bool start(const std::string &certificate_path, const std::string &key_path,
               const quic_transport::ticket_t &ticket, std::uint16_t port) {
      ticket_ = ticket;
      expected_server_certificate_ = ticket.client_certificate_sha256;
      if (QUIC_FAILED(MsQuicOpen2(&api_))) return false;
      const QUIC_REGISTRATION_CONFIG registration_config {
        "Helios QUIC loopback test", QUIC_EXECUTION_PROFILE_LOW_LATENCY
      };
      if (QUIC_FAILED(api_->RegistrationOpen(&registration_config, &registration_))) return false;

      QUIC_SETTINGS settings {};
      settings.IdleTimeoutMs = 10000;
      settings.IsSet.IdleTimeoutMs = TRUE;
      settings.KeepAliveIntervalMs = 500;
      settings.IsSet.KeepAliveIntervalMs = TRUE;
      settings.DatagramReceiveEnabled = TRUE;
      settings.IsSet.DatagramReceiveEnabled = TRUE;
      settings.MigrationEnabled = TRUE;
      settings.IsSet.MigrationEnabled = TRUE;
      QUIC_BUFFER alpn {sizeof(MLOS_QUIC_ALPN) - 1,
                        reinterpret_cast<std::uint8_t *>(const_cast<char *>(MLOS_QUIC_ALPN))};
      if (QUIC_FAILED(api_->ConfigurationOpen(registration_, &alpn, 1, &settings,
                                              sizeof(settings), nullptr, &configuration_))) {
        return false;
      }

      QUIC_CERTIFICATE_FILE certificate_file {key_path.c_str(), certificate_path.c_str()};
      QUIC_CREDENTIAL_CONFIG credential {};
      credential.Type = QUIC_CREDENTIAL_TYPE_CERTIFICATE_FILE;
      credential.CertificateFile = &certificate_file;
      credential.Flags = static_cast<QUIC_CREDENTIAL_FLAGS>(
        QUIC_CREDENTIAL_FLAG_CLIENT |
        QUIC_CREDENTIAL_FLAG_NO_CERTIFICATE_VALIDATION |
        QUIC_CREDENTIAL_FLAG_INDICATE_CERTIFICATE_RECEIVED |
        QUIC_CREDENTIAL_FLAG_USE_PORTABLE_CERTIFICATES);
      if (QUIC_FAILED(api_->ConfigurationLoadCredential(configuration_, &credential)) ||
          QUIC_FAILED(api_->ConnectionOpen(registration_, connection_callback, this, &connection_)) ||
          QUIC_FAILED(api_->ConnectionStart(connection_, configuration_, QUIC_ADDRESS_FAMILY_UNSPEC,
                                            "127.0.0.1", port))) {
        return false;
      }
      return wait_for([this] {
        return authenticated_.load() || failed_.load() || finished_.load();
      }) && authenticated_.load();
    }

    bool send_datagram(std::uint8_t channel, std::string_view payload) {
      std::vector<std::uint8_t> packet(MLOS_QUIC_DATAGRAM_HEADER_SIZE + payload.size());
      if (!MlosQuicEncodeDatagramHeader(packet.data(), MLOS_QUIC_DATAGRAM_HEADER_SIZE,
                                       channel, 0, static_cast<std::uint16_t>(payload.size()))) {
        return false;
      }
      std::memcpy(packet.data() + MLOS_QUIC_DATAGRAM_HEADER_SIZE, payload.data(), payload.size());
      auto context = new (std::nothrow) send_context_t(std::move(packet));
      if (!context) return false;
      const auto status = api_->DatagramSend(connection_, &context->buffer, 1,
                                             QUIC_SEND_FLAG_NONE, context);
      if (QUIC_FAILED(status)) delete context;
      return QUIC_SUCCEEDED(status);
    }

    bool wait_for_datagram(std::string_view expected) {
      std::unique_lock lock(mutex_);
      const auto ready = changed_.wait_for(lock, 10s, [this] {
        return datagrams_received_.load() != 0 || failed_.load() || finished_.load();
      });
      return ready && std::string_view {
        reinterpret_cast<const char *>(received_datagram_.data()), received_datagram_.size()
      } == expected;
    }

    bool wait_for_datagram_count(std::size_t expected) {
      std::unique_lock lock(mutex_);
      return changed_.wait_for(lock, 10s, [this, expected] {
        return datagrams_received_.load() >= expected || failed_.load() || finished_.load();
      }) && datagrams_received_.load() >= expected;
    }

    void reset_datagram() {
      std::lock_guard lock(mutex_);
      received_datagram_.clear();
      datagrams_received_ = 0;
    }

    bool migrate() {
      QUIC_ADDR address {};
      std::uint32_t address_size = sizeof(address);
      if (QUIC_FAILED(api_->GetParam(connection_, QUIC_PARAM_CONN_LOCAL_ADDRESS,
                                    &address_size, &address))) {
        return false;
      }
      const auto original_port = QuicAddrGetPort(&address);
      // The preceding bidirectional datagrams have reached the applications,
      // but MsQuic can still be completing their send-path bookkeeping. Its
      // own NAT-rebinding interop test quiesces the path before SetParam; doing
      // the same avoids replacing a binding still referenced by SocketSend.
      std::this_thread::sleep_for(250ms);
      migrated_ = false;
      migration_requested_ = true;
      QUIC_STATUS migration_status = QUIC_STATUS_ADDRESS_IN_USE;
      // Use an explicit replacement port, matching MsQuic's own NAT rebinding
      // interop test. Passing port zero here asks the Linux datapath to replace
      // its binding while a path-validation send may still reference it, which
      // causes MsQuic 2.x to bugcheck in SocketSend under load.
      for (std::uint16_t offset = 1236;
           offset <= 1246 && QUIC_FAILED(migration_status); ++offset) {
        auto candidate = static_cast<std::uint16_t>(original_port + offset);
        if (candidate == 0 || candidate == original_port) continue;
        QuicAddrSetPort(&address, candidate);
        migration_status = api_->SetParam(connection_, QUIC_PARAM_CONN_LOCAL_ADDRESS,
                                          sizeof(address), &address);
      }
      if (QUIC_FAILED(migration_status)) {
        migration_requested_ = false;
        return false;
      }
      // MsQuic may not emit LOCAL_ADDRESS_CHANGED until traffic exercises the
      // new path. Give its path-validation send the same settling interval as
      // the upstream interop test, then query the result once (polling GetParam
      // during the switch races the Linux datapath in MsQuic 2.x).
      {
        std::unique_lock lock(mutex_);
        changed_.wait_for(lock, 250ms, [this] {
          return migrated_.load() || failed_.load() || finished_.load();
        });
      }
      QUIC_ADDR migrated_address {};
      std::uint32_t migrated_address_size = sizeof(migrated_address);
      const auto changed = !failed_.load() && !finished_.load() &&
        QUIC_SUCCEEDED(api_->GetParam(connection_, QUIC_PARAM_CONN_LOCAL_ADDRESS,
                                     &migrated_address_size, &migrated_address)) &&
        QuicAddrGetPort(&migrated_address) != 0 &&
        QuicAddrGetPort(&migrated_address) != original_port;
      migration_requested_ = false;
      return changed;
    }

    void stop() {
      if (connection_ && !finished_.load()) {
        api_->ConnectionShutdown(connection_, QUIC_CONNECTION_SHUTDOWN_FLAG_NONE, 0);
        wait_for([this] { return finished_.load(); });
      }
      if (connection_ && api_) api_->ConnectionClose(connection_);
      connection_ = nullptr;
      if (configuration_ && api_) api_->ConfigurationClose(configuration_);
      configuration_ = nullptr;
      if (registration_ && api_) api_->RegistrationClose(registration_);
      registration_ = nullptr;
      if (api_) MsQuicClose(api_);
      api_ = nullptr;
    }

  private:
    template<typename Predicate>
    bool wait_for(Predicate predicate) {
      std::unique_lock lock(mutex_);
      return changed_.wait_for(lock, 10s, predicate);
    }

    bool open_auth_stream() {
      if (QUIC_FAILED(api_->StreamOpen(connection_, QUIC_STREAM_OPEN_FLAG_NONE,
                                      stream_callback, this, &auth_stream_)) ||
          QUIC_FAILED(api_->StreamStart(auth_stream_, QUIC_STREAM_START_FLAG_IMMEDIATE))) {
        return false;
      }
      std::vector<std::uint8_t> packet(MLOS_QUIC_STREAM_PREFACE_SIZE + MLOS_QUIC_AUTH_SIZE);
      if (!MlosQuicEncodeStreamPreface(packet.data(), MLOS_QUIC_STREAM_PREFACE_SIZE,
                                      MLOS_QUIC_STREAM_AUTH, 0) ||
          !MlosQuicEncodeAuth(packet.data() + MLOS_QUIC_STREAM_PREFACE_SIZE,
                             MLOS_QUIC_AUTH_SIZE, ticket_.token.data(),
                             ticket_.client_certificate_sha256.data())) {
        return false;
      }
      auto context = new (std::nothrow) send_context_t(std::move(packet));
      if (!context) return false;
      const auto status = api_->StreamSend(auth_stream_, &context->buffer, 1,
                                           QUIC_SEND_FLAG_NONE, context);
      if (QUIC_FAILED(status)) delete context;
      return QUIC_SUCCEEDED(status);
    }

    void fail() {
      failed_ = true;
      changed_.notify_all();
      if (connection_) api_->ConnectionShutdown(connection_, QUIC_CONNECTION_SHUTDOWN_FLAG_NONE,
                                                0x100);
    }

    static QUIC_STATUS QUIC_API stream_callback(HQUIC stream, void *context,
                                                 QUIC_STREAM_EVENT *event) {
      auto self = static_cast<loopback_client_t *>(context);
      switch (event->Type) {
        case QUIC_STREAM_EVENT_RECEIVE:
          for (std::uint32_t i = 0; i < event->RECEIVE.BufferCount; ++i) {
            self->auth_reply_.insert(self->auth_reply_.end(),
                                     event->RECEIVE.Buffers[i].Buffer,
                                     event->RECEIVE.Buffers[i].Buffer +
                                       event->RECEIVE.Buffers[i].Length);
          }
          if (self->auth_reply_.size() > 1 ||
              (self->auth_reply_.size() == 1 && self->auth_reply_[0] != 1)) {
            self->fail();
          } else if (self->auth_reply_.size() == 1) {
            self->authenticated_ = true;
            self->changed_.notify_all();
          }
          break;
        case QUIC_STREAM_EVENT_SEND_COMPLETE:
          delete static_cast<send_context_t *>(event->SEND_COMPLETE.ClientContext);
          break;
        case QUIC_STREAM_EVENT_PEER_SEND_ABORTED:
        case QUIC_STREAM_EVENT_PEER_RECEIVE_ABORTED:
          self->fail();
          break;
        case QUIC_STREAM_EVENT_SHUTDOWN_COMPLETE:
          self->api_->StreamClose(stream);
          self->auth_stream_ = nullptr;
          break;
        default:
          break;
      }
      return QUIC_STATUS_SUCCESS;
    }

    static QUIC_STATUS QUIC_API connection_callback(HQUIC, void *context,
                                                     QUIC_CONNECTION_EVENT *event) {
      auto self = static_cast<loopback_client_t *>(context);
      switch (event->Type) {
        case QUIC_CONNECTION_EVENT_PEER_CERTIFICATE_RECEIVED: {
          const auto certificate = reinterpret_cast<const QUIC_BUFFER *>(
            event->PEER_CERTIFICATE_RECEIVED.Certificate);
          if (!certificate || !certificate->Buffer || !certificate->Length) {
            self->fail();
            break;
          }
          const auto fingerprint = crypto::hash(std::string_view {
            reinterpret_cast<const char *>(certificate->Buffer), certificate->Length
          });
          self->server_certificate_valid_ =
            CRYPTO_memcmp(fingerprint.data(), self->expected_server_certificate_.data(),
                          fingerprint.size()) == 0;
          if (!self->server_certificate_valid_) self->fail();
          break;
        }
        case QUIC_CONNECTION_EVENT_CONNECTED:
          if (!self->server_certificate_valid_.load() || !self->open_auth_stream()) self->fail();
          break;
        case QUIC_CONNECTION_EVENT_LOCAL_ADDRESS_CHANGED:
          if (self->migration_requested_.load()) {
            self->migrated_ = true;
            self->changed_.notify_all();
          }
          break;
        case QUIC_CONNECTION_EVENT_DATAGRAM_RECEIVED: {
          MLOS_QUIC_DATAGRAM_HEADER header {};
          const auto buffer = event->DATAGRAM_RECEIVED.Buffer;
          if (!buffer || !MlosQuicDecodeDatagramHeader(buffer->Buffer, buffer->Length, &header) ||
              header.flags != 0 || header.channel != MLOS_QUIC_DATAGRAM_VIDEO) {
            self->fail();
            break;
          }
          {
            std::lock_guard lock(self->mutex_);
            self->received_datagram_.assign(
              buffer->Buffer + MLOS_QUIC_DATAGRAM_HEADER_SIZE,
              buffer->Buffer + MLOS_QUIC_DATAGRAM_HEADER_SIZE + header.payloadLength);
            ++self->datagrams_received_;
          }
          self->changed_.notify_all();
          break;
        }
        case QUIC_CONNECTION_EVENT_DATAGRAM_SEND_STATE_CHANGED:
          if (QUIC_DATAGRAM_SEND_STATE_IS_FINAL(event->DATAGRAM_SEND_STATE_CHANGED.State)) {
            delete static_cast<send_context_t *>(
              event->DATAGRAM_SEND_STATE_CHANGED.ClientContext);
          }
          break;
        case QUIC_CONNECTION_EVENT_SHUTDOWN_COMPLETE:
          self->finished_ = true;
          self->changed_.notify_all();
          break;
        default:
          break;
      }
      return QUIC_STATUS_SUCCESS;
    }

    const QUIC_API_TABLE *api_ = nullptr;
    HQUIC registration_ = nullptr;
    HQUIC configuration_ = nullptr;
    HQUIC connection_ = nullptr;
    HQUIC auth_stream_ = nullptr;
    quic_transport::ticket_t ticket_ {};
    crypto::sha256_t expected_server_certificate_ {};
    std::mutex mutex_;
    std::condition_variable changed_;
    std::atomic_bool authenticated_ {false};
    std::atomic_bool server_certificate_valid_ {false};
    std::atomic_bool failed_ {false};
    std::atomic_bool finished_ {false};
    std::atomic_size_t datagrams_received_ {0};
    std::atomic_bool migration_requested_ {false};
    std::atomic_bool migrated_ {false};
    std::vector<std::uint8_t> auth_reply_;
    std::vector<std::uint8_t> received_datagram_;
  };

  class server_guard_t {
  public:
    ~server_guard_t() { quic_transport::stop_server(); }
  };
}

TEST(QuicLiveLoopbackTests, AuthenticatesMigratesAndBridgesMediaDatagramsBothWays) {
  const auto credentials = crypto::gen_creds("Helios QUIC loopback", 2048);
  memory_file_t certificate("helios-quic-test-cert", credentials.x509);
  memory_file_t key("helios-quic-test-key", credentials.pkey);
  ASSERT_TRUE(certificate.valid());
  ASSERT_TRUE(key.valid());

  auto ticket = quic_transport::issue_ticket(credentials.x509, 0x12345678);
  ASSERT_TRUE(ticket);
  quic_transport::ticket_registry().insert(*ticket);

  boost::asio::io_context io;
  boost::asio::ip::udp::socket media(io, {
    boost::asio::ip::address_v4::loopback(), 0
  });
  const auto media_port = media.local_endpoint().port();
  ASSERT_GT(media_port, 1033);
  ASSERT_LT(media_port, 65514);
  const auto base_port = static_cast<std::uint16_t>(media_port - 9);

  boost::asio::ip::udp::socket port_probe(io, {
    boost::asio::ip::address_v4::loopback(), 0
  });
  const auto quic_port = port_probe.local_endpoint().port();
  port_probe.close();

  ASSERT_TRUE(quic_transport::start_server(certificate.path(), key.path(),
                                           quic_port, base_port));
  server_guard_t server_guard;
  loopback_client_t client;
  ASSERT_TRUE(client.start(certificate.path(), key.path(), *ticket, quic_port));
  EXPECT_EQ(quic_transport::ticket_registry().size(), 0u);

  constexpr std::string_view request = "client-to-helios";
  ASSERT_TRUE(client.send_datagram(MLOS_QUIC_DATAGRAM_VIDEO, request));
  media.non_blocking(true);
  std::array<char, 128> bytes {};
  boost::asio::ip::udp::endpoint bridge;
  std::size_t received = 0;
  const auto deadline = std::chrono::steady_clock::now() + 10s;
  while (std::chrono::steady_clock::now() < deadline && received == 0) {
    boost::system::error_code error;
    received = media.receive_from(boost::asio::buffer(bytes), bridge, 0, error);
    if (error == boost::asio::error::would_block || error == boost::asio::error::try_again) {
      std::this_thread::sleep_for(2ms);
      received = 0;
    } else if (error) {
      FAIL() << error.message();
    }
  }
  ASSERT_EQ(std::string_view(bytes.data(), received), request);

  constexpr std::string_view response = "helios-to-client";
  ASSERT_EQ(media.send_to(boost::asio::buffer(response), bridge), response.size());
  ASSERT_TRUE(client.wait_for_datagram(response));

  // Encoder IDR frames commonly arrive as bursts larger than MsQuic's
  // internal datagram submission queue. Verify the bridge applies
  // backpressure instead of silently truncating the burst around packet 61.
  client.reset_datagram();
  const std::string burst_packet(1200, 'I');
  constexpr std::size_t burst_packets = 155;
  for (std::size_t i = 0; i < burst_packets; ++i) {
    ASSERT_EQ(media.send_to(boost::asio::buffer(burst_packet), bridge), burst_packet.size());
  }
  ASSERT_TRUE(client.wait_for_datagram_count(burst_packets));

  ASSERT_TRUE(client.migrate());
  client.reset_datagram();
  constexpr std::string_view migrated_request = "client-to-helios-after-migration";
  ASSERT_TRUE(client.send_datagram(MLOS_QUIC_DATAGRAM_VIDEO, migrated_request));
  received = 0;
  const auto migrated_deadline = std::chrono::steady_clock::now() + 10s;
  while (std::chrono::steady_clock::now() < migrated_deadline && received == 0) {
    boost::system::error_code error;
    received = media.receive_from(boost::asio::buffer(bytes), bridge, 0, error);
    if (error == boost::asio::error::would_block || error == boost::asio::error::try_again) {
      std::this_thread::sleep_for(2ms);
      received = 0;
    } else if (error) {
      FAIL() << error.message();
    }
  }
  ASSERT_EQ(std::string_view(bytes.data(), received), migrated_request);

  constexpr std::string_view migrated_response = "helios-to-client-after-migration";
  ASSERT_EQ(media.send_to(boost::asio::buffer(migrated_response), bridge),
            migrated_response.size());
  ASSERT_TRUE(client.wait_for_datagram(migrated_response));
}

#else

TEST(QuicLiveLoopbackTests, RequiresLinuxMsQuicBuild) {
  GTEST_SKIP() << "Live MsQuic loopback coverage requires Linux with MsQuic enabled";
}

#endif
