#include "src/platform/common.h"

#include <windows.h>
#include <wincodec.h>
#include <sddl.h>

#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <iomanip>
#include <vector>

#include "src/logging.h"
#include "src/platform/windows/misc.h"
#include "src/platform/windows/virtual_display.h"

using namespace std::literals;

namespace platf {
  namespace {
    constexpr wchar_t frame_mapping_name[] = L"Global\\MoonlightOSCameraFrame-v1";
    constexpr wchar_t frame_mutex_name[] = L"Global\\MoonlightOSCameraFrameMutex-v1";
    constexpr wchar_t frame_event_name[] = L"Global\\MoonlightOSCameraFrameReady-v1";
    constexpr std::uint32_t frame_magic = 0x4D4C5643u;
    constexpr std::uint32_t output_width = 1280;
    constexpr std::uint32_t output_height = 720;
    constexpr std::uint32_t output_stride = output_width * 4;
    constexpr std::uint32_t output_size = output_stride * output_height;

    struct shared_frame_t {
      std::uint32_t magic;
      std::uint32_t version;
      std::uint32_t width;
      std::uint32_t height;
      std::uint32_t stride;
      std::uint32_t byte_count;
      std::uint32_t timestamp_ms;
      volatile LONG generation;
      std::uint8_t pixels[output_size];
    };

    template<class T>
    void release(T *&value) {
      if (value) value->Release();
      value = nullptr;
    }

    bool registered_media_source() {
      constexpr wchar_t clsid_path[] =
        L"Software\\Classes\\CLSID\\{B7A32F78-6B0D-4B0A-A9E5-9C8A53C79831}";
      HKEY key = nullptr;
      if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, clsid_path, 0, KEY_READ, &key) == ERROR_SUCCESS ||
          RegOpenKeyExW(HKEY_CURRENT_USER, clsid_path, 0, KEY_READ, &key) == ERROR_SUCCESS) {
        RegCloseKey(key);
        return true;
      }
      return false;
    }

    class mf_virtual_camera_t final: public virtual_camera_t {
    public:
      mf_virtual_camera_t() {
        auto result = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
        uninitialize_com_ = result == S_OK || result == S_FALSE;
        if (FAILED(result) && result != RPC_E_CHANGED_MODE) return;
        if (FAILED(CoCreateInstance(CLSID_WICImagingFactory, nullptr, CLSCTX_INPROC_SERVER,
                                    IID_IWICImagingFactory,
                                    reinterpret_cast<void **>(&factory_)))) return;
        PSECURITY_DESCRIPTOR descriptor = nullptr;
        SECURITY_ATTRIBUTES attributes {sizeof(attributes), nullptr, FALSE};
        if (ConvertStringSecurityDescriptorToSecurityDescriptorW(
              L"D:P(A;;GA;;;SY)(A;;GA;;;BA)(A;;GR;;;LS)", SDDL_REVISION_1,
              &descriptor, nullptr)) attributes.lpSecurityDescriptor = descriptor;
        mapping_ = CreateFileMappingW(INVALID_HANDLE_VALUE, &attributes, PAGE_READWRITE, 0,
                                      sizeof(shared_frame_t), frame_mapping_name);
        if (!mapping_) {
          if (descriptor) LocalFree(descriptor);
          return;
        }
        frame_ = static_cast<shared_frame_t *>(
          MapViewOfFile(mapping_, FILE_MAP_ALL_ACCESS, 0, 0, sizeof(shared_frame_t)));
        mutex_ = CreateMutexW(&attributes, FALSE, frame_mutex_name);
        ready_event_ = CreateEventW(&attributes, FALSE, FALSE, frame_event_name);
        if (descriptor) LocalFree(descriptor);
        valid_ = frame_ && mutex_ && ready_event_;
        if (valid_) {
          frame_->magic = frame_magic;
          frame_->version = 1;
          frame_->width = output_width;
          frame_->height = output_height;
          frame_->stride = output_stride;
        }
      }

      ~mf_virtual_camera_t() override {
        if (frame_) UnmapViewOfFile(frame_);
        if (ready_event_) CloseHandle(ready_event_);
        if (mutex_) CloseHandle(mutex_);
        if (mapping_) CloseHandle(mapping_);
        release(factory_);
        if (uninitialize_com_) CoUninitialize();
      }

      explicit operator bool() const { return valid_; }

      bool write_mjpeg(const std::uint8_t *bytes, std::size_t size,
                       std::uint16_t, std::uint16_t,
                       std::uint32_t timestamp_ms) override {
        if (!valid_ || !bytes || size == 0 || size > UINT32_MAX) return false;
        IWICStream *stream = nullptr;
        IWICBitmapDecoder *decoder = nullptr;
        IWICBitmapFrameDecode *decoded = nullptr;
        IWICBitmapScaler *scaler = nullptr;
        IWICFormatConverter *converter = nullptr;
        std::vector<std::uint8_t> pixels(output_size);
        HRESULT result = factory_->CreateStream(&stream);
        if (SUCCEEDED(result)) result = stream->InitializeFromMemory(
          const_cast<BYTE *>(bytes), static_cast<DWORD>(size));
        if (SUCCEEDED(result)) result = factory_->CreateDecoderFromStream(
          stream, nullptr, WICDecodeMetadataCacheOnLoad, &decoder);
        if (SUCCEEDED(result)) result = decoder->GetFrame(0, &decoded);
        if (SUCCEEDED(result)) result = factory_->CreateBitmapScaler(&scaler);
        if (SUCCEEDED(result)) result = scaler->Initialize(
          decoded, output_width, output_height, WICBitmapInterpolationModeFant);
        if (SUCCEEDED(result)) result = factory_->CreateFormatConverter(&converter);
        if (SUCCEEDED(result)) result = converter->Initialize(
          scaler, GUID_WICPixelFormat32bppBGRA, WICBitmapDitherTypeNone,
          nullptr, 0, WICBitmapPaletteTypeCustom);
        if (SUCCEEDED(result)) result = converter->CopyPixels(
          nullptr, output_stride, output_size, pixels.data());
        release(converter);
        release(scaler);
        release(decoded);
        release(decoder);
        release(stream);
        if (FAILED(result)) {
          BOOST_LOG(error) << "Couldn't decode camera MJPEG frame for Media Foundation: 0x"sv
                           << std::hex << static_cast<unsigned long>(result);
          return false;
        }
        auto wait = WaitForSingleObject(mutex_, 1000);
        if (wait != WAIT_OBJECT_0 && wait != WAIT_ABANDONED) return false;
        frame_->magic = frame_magic;
        frame_->version = 1;
        frame_->width = output_width;
        frame_->height = output_height;
        frame_->stride = output_stride;
        frame_->byte_count = output_size;
        frame_->timestamp_ms = timestamp_ms;
        std::copy(pixels.begin(), pixels.end(), frame_->pixels);
        InterlockedIncrement(&frame_->generation);
        ReleaseMutex(mutex_);
        SetEvent(ready_event_);
        return true;
      }

    private:
      IWICImagingFactory *factory_ = nullptr;
      HANDLE mapping_ = nullptr;
      HANDLE mutex_ = nullptr;
      HANDLE ready_event_ = nullptr;
      shared_frame_t *frame_ = nullptr;
      bool valid_ = false;
      bool uninitialize_com_ = false;
    };

    class sudovda_topology_t final: public virtual_display_topology_t {
    public:
      ~sudovda_topology_t() override {
        for (const auto &output : outputs_) VDISPLAY::removeVirtualDisplay(output.guid);
      }

      bool apply(const std::vector<client_display_t> &displays) override {
        if (displays.empty()) return false;
        while (outputs_.size() < displays.size()) {
          output_t output;
          if (FAILED(CoCreateGuid(&output.guid))) return false;
          char uid[64];
          std::snprintf(uid, sizeof(uid),
            "%08lx-%04x-%04x-%02x%02x-%02x%02x%02x%02x%02x%02x",
            output.guid.Data1, output.guid.Data2, output.guid.Data3,
            output.guid.Data4[0], output.guid.Data4[1], output.guid.Data4[2], output.guid.Data4[3],
            output.guid.Data4[4], output.guid.Data4[5], output.guid.Data4[6], output.guid.Data4[7]);
          const auto &spec = displays[outputs_.size()];
          output.name = VDISPLAY::createVirtualDisplay(
            uid, "Moonlight OS display", spec.width, spec.height,
            spec.refresh_millihz, output.guid);
          if (output.name.empty()) return false;
          outputs_.push_back(std::move(output));
        }
        while (outputs_.size() > displays.size()) {
          VDISPLAY::removeVirtualDisplay(outputs_.back().guid);
          outputs_.pop_back();
        }

        std::size_t primary = 0;
        for (std::size_t i = 0; i < displays.size(); ++i) {
          if (displays[i].primary) primary = i;
          if (VDISPLAY::changeDisplaySettings(outputs_[i].name.c_str(), displays[i].width,
                displays[i].height, displays[i].refresh_millihz) != ERROR_SUCCESS) return false;
          VDISPLAY::setDisplayHDRByName(outputs_[i].name.c_str(), displays[i].hdr);
        }
        const auto &primary_spec = displays[primary];

        // The client primary must also be the Windows primary. Leaving the
        // first virtual output as a secondary monitor produces a valid video
        // capture, but the taskbar and newly launched applications remain on
        // an unseen host display. It also leaves absolute input targeting a
        // desktop that the user cannot meaningfully operate.
        //
        // changeDisplaySettings2(..., true) is the legacy isolated-display
        // arrangement helper. It deliberately keeps the existing Windows
        // primary and moves the virtual output to the lower-right, which is
        // the opposite of the topology contract's primary flag.
        if (!VDISPLAY::setPrimaryDisplay(outputs_[primary].name.c_str())) return false;
        DEVMODEW primary_mode = {};
        if (!VDISPLAY::getDeviceSettings(outputs_[primary].name.c_str(), primary_mode)) return false;
        for (std::size_t i = 0; i < displays.size(); ++i) {
          auto x = primary_mode.dmPosition.x + displays[i].x - primary_spec.x;
          auto y = primary_mode.dmPosition.y + displays[i].y - primary_spec.y;
          if (VDISPLAY::changeDisplayPosition(outputs_[i].name.c_str(), x, y) != ERROR_SUCCESS) return false;
        }
        if (ChangeDisplaySettingsExW(nullptr, nullptr, nullptr, 0, nullptr) != ERROR_SUCCESS) return false;
        return true;
      }

      std::vector<std::string> display_names() const override {
        std::vector<std::string> names;
        names.reserve(outputs_.size());
        for (const auto &output : outputs_) names.push_back(platf::to_utf8(output.name));
        return names;
      }

    private:
      struct output_t { GUID guid {}; std::wstring name; };
      std::vector<output_t> outputs_;
    };
  }

  bool virtual_camera_available() { return registered_media_source(); }

  std::unique_ptr<virtual_camera_t> virtual_camera() {
    if (!registered_media_source()) return nullptr;
    auto camera = std::make_unique<mf_virtual_camera_t>();
    if (!*camera) return nullptr;
    BOOST_LOG(info) << "Publishing camera uplink through Windows Media Foundation"sv;
    return camera;
  }

  bool virtual_display_topology_available() {
    if (VDISPLAY::SUDOVDA_DRIVER_HANDLE == INVALID_HANDLE_VALUE &&
        VDISPLAY::openVDisplayDevice() != VDISPLAY::DRIVER_STATUS::OK) return false;
    return true;
  }

  std::unique_ptr<virtual_display_topology_t> virtual_display_topology() {
    if (!virtual_display_topology_available()) return nullptr;
    return std::make_unique<sudovda_topology_t>();
  }
}
