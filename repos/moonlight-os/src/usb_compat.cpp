/**
 * @file src/usb_compat.cpp
 * @brief Compatibility response on the former mlos-host-utils TCP port.
 */
#include <atomic>
#include <chrono>
#include <thread>

#include <boost/asio.hpp>

#include "logging.h"
#include "usb_compat.h"

namespace usb_compat {
  namespace asio = boost::asio;
  using tcp = asio::ip::tcp;
  using namespace std::chrono_literals;
  using namespace std::literals;

  constexpr std::string_view moved_response =
    "{\"v\":1,\"ok\":false,\"code\":\"moved\",\"error\":\"USB passthrough moved into authenticated Helios streaming sessions; update Moonlight OS and remove the old host pairing.\"}\n";

  class listener_t: public platf::deinit_t {
  public:
    explicit listener_t(std::uint16_t port_): port(port_), acceptor(io) {
      boost::system::error_code ec;
      acceptor.open(tcp::v4(), ec);
      if (ec) return;
      acceptor.set_option(tcp::acceptor::reuse_address(true), ec);
      acceptor.bind(tcp::endpoint(tcp::v4(), port), ec);
      if (ec) {
        BOOST_LOG(info) << "Legacy USB migration listener is unavailable (the old host-utils may still be running): "sv
                        << ec.message();
        acceptor.close();
        return;
      }
      acceptor.listen(8, ec);
      if (ec) {
        acceptor.close();
        return;
      }
      acceptor.non_blocking(true, ec);
      if (ec) {
        acceptor.close();
        return;
      }
      worker = std::thread([this] { loop(); });
      BOOST_LOG(info) << "Legacy USB migration notice listening on TCP "sv << port;
    }

    ~listener_t() override {
      stopping = true;
      // Do not close an Asio acceptor while another thread is inside accept().
      // A loopback wake-up makes that call return; the worker observes the
      // stop flag, exits, and only then is the acceptor closed on this thread.
      boost::system::error_code ec;
      if (acceptor.is_open()) {
        asio::io_context wake_io;
        tcp::socket wake_socket(wake_io);
        wake_socket.connect(tcp::endpoint(asio::ip::address_v4::loopback(), port), ec);
      }
      if (worker.joinable()) worker.join();
      acceptor.close(ec);
    }

  private:
    void loop() {
      while (!stopping) {
        tcp::socket socket(io);
        boost::system::error_code ec;
        acceptor.accept(socket, ec);
        if (ec == asio::error::would_block || ec == asio::error::try_again) {
          std::this_thread::sleep_for(25ms);
          continue;
        }
        if (ec) {
          if (!stopping) BOOST_LOG(warning) << "Legacy USB migration accept failed: "sv << ec.message();
          continue;
        }
        if (stopping) break;
        asio::write(socket, asio::buffer(moved_response), ec);
        socket.shutdown(tcp::socket::shutdown_both, ec);
        socket.close(ec);
      }
    }

    asio::io_context io;
    std::uint16_t port;
    tcp::acceptor acceptor;
    std::atomic<bool> stopping {false};
    std::thread worker;
  };

  std::unique_ptr<platf::deinit_t> start(std::uint16_t port) {
    return std::make_unique<listener_t>(port);
  }
}
