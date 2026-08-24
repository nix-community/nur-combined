#include "src/platform/common.h"

#include <cerrno>
#include <cstdlib>
#include <cstring>
#include <fcntl.h>
#include <linux/videodev2.h>
#include <sys/ioctl.h>
#include <unistd.h>

#include "src/logging.h"

using namespace std::literals;

namespace platf {
  namespace {
    bool ioctl_retry(int fd, unsigned long request, void *value) {
      int result;
      do {
        result = ::ioctl(fd, request, value);
      } while (result < 0 && errno == EINTR);
      return result == 0;
    }

    class v4l2_virtual_camera_t final: public virtual_camera_t {
    public:
      explicit v4l2_virtual_camera_t(int fd): fd_ {fd} {}
      ~v4l2_virtual_camera_t() override {
        ::close(fd_);
      }

      bool write_mjpeg(const std::uint8_t *bytes, std::size_t size,
                       std::uint16_t width, std::uint16_t height,
                       std::uint32_t) override {
        if (width != width_ || height != height_) {
          v4l2_format format {};
          format.type = V4L2_BUF_TYPE_VIDEO_OUTPUT;
          format.fmt.pix.width = width;
          format.fmt.pix.height = height;
          format.fmt.pix.pixelformat = V4L2_PIX_FMT_MJPEG;
          format.fmt.pix.field = V4L2_FIELD_NONE;
          format.fmt.pix.sizeimage = static_cast<__u32>(size);
          if (!ioctl_retry(fd_, VIDIOC_S_FMT, &format) ||
              format.fmt.pix.pixelformat != V4L2_PIX_FMT_MJPEG) {
            BOOST_LOG(error) << "Virtual camera rejected MJPEG "sv << width << 'x' << height;
            return false;
          }
          width_ = width;
          height_ = height;
        }

        std::size_t written = 0;
        while (written < size) {
          auto result = ::write(fd_, bytes + written, size - written);
          if (result < 0 && errno == EINTR) continue;
          if (result <= 0) {
            BOOST_LOG(error) << "Couldn't write virtual camera frame: "sv << std::strerror(errno);
            return false;
          }
          written += static_cast<std::size_t>(result);
        }
        return true;
      }

    private:
      int fd_;
      std::uint16_t width_ = 0;
      std::uint16_t height_ = 0;
    };

    class fixture_virtual_camera_t final: public virtual_camera_t {
    public:
      explicit fixture_virtual_camera_t(int fd): fd_ {fd} {}
      ~fixture_virtual_camera_t() override {
        ::close(fd_);
      }

      bool write_mjpeg(const std::uint8_t *bytes, std::size_t size,
                       std::uint16_t width, std::uint16_t height,
                       std::uint32_t timestamp_ms) override {
        std::uint8_t header[12] = {
          static_cast<std::uint8_t>(size >> 24), static_cast<std::uint8_t>(size >> 16),
          static_cast<std::uint8_t>(size >> 8), static_cast<std::uint8_t>(size),
          static_cast<std::uint8_t>(width >> 8), static_cast<std::uint8_t>(width),
          static_cast<std::uint8_t>(height >> 8), static_cast<std::uint8_t>(height),
          static_cast<std::uint8_t>(timestamp_ms >> 24), static_cast<std::uint8_t>(timestamp_ms >> 16),
          static_cast<std::uint8_t>(timestamp_ms >> 8), static_cast<std::uint8_t>(timestamp_ms)
        };
        return write_all(header, sizeof(header)) && write_all(bytes, size);
      }

    private:
      bool write_all(const std::uint8_t *bytes, std::size_t size) {
        while (size) {
          auto result = ::write(fd_, bytes, size);
          if (result < 0 && errno == EINTR) continue;
          if (result <= 0) return false;
          bytes += result;
          size -= static_cast<std::size_t>(result);
        }
        return true;
      }
      int fd_;
    };

    int open_v4l2_output() {
      for (int index = 0; index < 64; ++index) {
        auto path = "/dev/video" + std::to_string(index);
        auto fd = ::open(path.c_str(), O_WRONLY | O_CLOEXEC | O_NONBLOCK);
        if (fd < 0) continue;
        v4l2_capability capability {};
        if (ioctl_retry(fd, VIDIOC_QUERYCAP, &capability)) {
          auto caps = capability.device_caps ? capability.device_caps : capability.capabilities;
          if ((caps & V4L2_CAP_VIDEO_OUTPUT) &&
              (caps & (V4L2_CAP_STREAMING | V4L2_CAP_READWRITE))) return fd;
        }
        ::close(fd);
      }
      return -1;
    }
  }

  bool virtual_camera_available() {
    if (std::getenv("HELIOS_CAMERA_TEST_OUTPUT")) return true;
    auto fd = open_v4l2_output();
    if (fd < 0) return false;
    ::close(fd);
    return true;
  }

  std::unique_ptr<virtual_camera_t> virtual_camera() {
    if (const char *fixture = std::getenv("HELIOS_CAMERA_TEST_OUTPUT")) {
      auto fd = ::open(fixture, O_WRONLY | O_CREAT | O_EXCL | O_CLOEXEC | O_NOFOLLOW, 0600);
      if (fd >= 0) {
        BOOST_LOG(info) << "Publishing camera uplink to deterministic test sink"sv;
        return std::make_unique<fixture_virtual_camera_t>(fd);
      }
      BOOST_LOG(error) << "Couldn't create deterministic camera test sink: "sv << std::strerror(errno);
      return nullptr;
    }
    auto fd = open_v4l2_output();
    if (fd < 0) return nullptr;
    BOOST_LOG(info) << "Publishing camera uplink through a V4L2 output"sv;
    return std::make_unique<v4l2_virtual_camera_t>(fd);
  }
}
