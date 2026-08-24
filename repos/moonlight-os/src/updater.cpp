/**
 * @file src/updater.cpp
 * @brief Signed, staged application updates.
 */

#include "updater.h"

#include "crypto.h"
#include "entry_handler.h"
#include "logging.h"
#include "process.h"
#include "utility.h"

#include <algorithm>
#include <array>
#include <cctype>
#include <charconv>
#include <chrono>
#include <curl/curl.h>
#include <filesystem>
#include <fstream>
#include <mutex>
#include <openssl/evp.h>
#include <openssl/pem.h>
#include <optional>
#include <string>
#include <thread>
#include <tuple>
#include <vector>

#ifdef _WIN32
  #define WIN32_LEAN_AND_MEAN
  #include <Windows.h>
  #include <winsvc.h>
#endif

using namespace std::literals;

namespace updater {
  namespace fs = std::filesystem;

  namespace {
    constexpr auto releases_url = "https://api.github.com/repos/moonlight-os/helios/releases?per_page=20"sv;
    constexpr auto release_download_prefix = "https://github.com/moonlight-os/helios/releases/download/"sv;
    constexpr auto manifest_name = "helios-update.json"sv;
    constexpr auto signature_name = "helios-update.json.sig"sv;
    constexpr auto artifact_name = "helios-windows-x86_64.zip"sv;
    constexpr std::size_t max_release_response = 4 * 1024 * 1024;
    constexpr std::size_t max_manifest_size = 64 * 1024;
    constexpr std::uint64_t max_artifact_size = 2ULL * 1024 * 1024 * 1024;

    constexpr auto update_public_key = R"pem(-----BEGIN PUBLIC KEY-----
MCowBQYDK2VwAyEANO1J9QCTfzzdHItZ97Lhh6YtRCPZ238YANBhHbFfoRM=
-----END PUBLIC KEY-----
)pem"sv;

    struct release_t {
      std::string version;
      std::string tag;
      std::string release_url;
      std::string notes;
      std::string artifact_url;
      std::string sha256;
      std::uint64_t size {};
      bool prerelease {};
    };

    struct state_t {
      std::mutex mutex;
      std::string phase {"idle"};
      std::string message;
      std::string error;
      std::optional<release_t> release;
    } state;

    struct transfer_t {
      std::string *memory {};
      std::ofstream *file {};
      std::uint64_t received {};
      std::uint64_t limit {};
    };

    std::size_t write_transfer(char *data, std::size_t size, std::size_t count, void *userdata) {
      auto &transfer = *static_cast<transfer_t *>(userdata);
      const auto bytes = size * count;
      if (bytes > transfer.limit - std::min(transfer.received, transfer.limit)) {
        return 0;
      }
      transfer.received += bytes;
      if (transfer.memory) {
        transfer.memory->append(data, bytes);
      } else {
        transfer.file->write(data, static_cast<std::streamsize>(bytes));
        if (!*transfer.file) {
          return 0;
        }
      }
      return bytes;
    }

    bool valid_download_url(std::string_view url) {
      return url.starts_with(release_download_prefix) &&
             url.find('\\') == std::string_view::npos &&
             url.find('\r') == std::string_view::npos &&
             url.find('\n') == std::string_view::npos;
    }

    bool configure_curl(CURL *curl, const std::string &url, transfer_t &transfer, std::string &error) {
      if (curl_easy_setopt(curl, CURLOPT_URL, url.c_str()) != CURLE_OK || curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_transfer) != CURLE_OK || curl_easy_setopt(curl, CURLOPT_WRITEDATA, &transfer) != CURLE_OK) {
        error = "Could not configure the update download.";
        return false;
      }
      curl_easy_setopt(curl, CURLOPT_USERAGENT, "Helios-Updater/1");
      curl_easy_setopt(curl, CURLOPT_SSLVERSION, CURL_SSLVERSION_TLSv1_2);
      curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
      curl_easy_setopt(curl, CURLOPT_MAXREDIRS, 5L);
      curl_easy_setopt(curl, CURLOPT_FAILONERROR, 1L);
      curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, 15L);
      curl_easy_setopt(curl, CURLOPT_TIMEOUT, 600L);
      curl_easy_setopt(curl, CURLOPT_LOW_SPEED_LIMIT, 1024L);
      curl_easy_setopt(curl, CURLOPT_LOW_SPEED_TIME, 30L);
#if LIBCURL_VERSION_NUM >= 0x075500
      curl_easy_setopt(curl, CURLOPT_PROTOCOLS_STR, "https");
      curl_easy_setopt(curl, CURLOPT_REDIR_PROTOCOLS_STR, "https");
#else
      curl_easy_setopt(curl, CURLOPT_PROTOCOLS, CURLPROTO_HTTPS);
      curl_easy_setopt(curl, CURLOPT_REDIR_PROTOCOLS, CURLPROTO_HTTPS);
#endif
#ifdef _WIN32
      curl_easy_setopt(curl, CURLOPT_SSL_OPTIONS, CURLSSLOPT_NATIVE_CA);
#endif
      return true;
    }

    bool get_memory(const std::string &url, std::size_t maximum, std::string &output, std::string &error) {
      output.clear();
      CURL *curl = curl_easy_init();  // NOSONAR: TLS is constrained below.
      if (!curl) {
        error = "Could not initialize the update download.";
        return false;
      }
      transfer_t transfer {&output, nullptr, 0, maximum};
      const bool configured = configure_curl(curl, url, transfer, error);
      const auto result = configured ? curl_easy_perform(curl) : CURLE_FAILED_INIT;
      long status_code = 0;
      curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &status_code);
      curl_easy_cleanup(curl);
      if (!configured || result != CURLE_OK || status_code < 200 || status_code >= 300) {
        if (error.empty()) {
          error = "The update server could not be reached.";
        }
        output.clear();
        return false;
      }
      return true;
    }

    [[maybe_unused]] bool download_file(const std::string &url, const fs::path &path, std::uint64_t maximum, std::string &error) {
      std::ofstream file(path, std::ios::binary | std::ios::out | std::ios::trunc);
      if (!file) {
        error = "The update archive could not be created.";
        return false;
      }
      CURL *curl = curl_easy_init();  // NOSONAR: TLS is constrained below.
      if (!curl) {
        error = "Could not initialize the update download.";
        return false;
      }
      transfer_t transfer {nullptr, &file, 0, maximum};
      const bool configured = configure_curl(curl, url, transfer, error);
      const auto result = configured ? curl_easy_perform(curl) : CURLE_FAILED_INIT;
      long status_code = 0;
      curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &status_code);
      curl_easy_cleanup(curl);
      file.close();
      if (!configured || result != CURLE_OK || status_code < 200 || status_code >= 300) {
        if (error.empty()) {
          error = "The update archive could not be downloaded.";
        }
        return false;
      }
      return true;
    }

    [[maybe_unused]] std::optional<std::string> sha256_file(const fs::path &path) {
      std::ifstream file(path, std::ios::binary);
      if (!file) {
        return std::nullopt;
      }
      crypto::md_ctx_t context {EVP_MD_CTX_new()};
      if (!context || EVP_DigestInit_ex(context.get(), EVP_sha256(), nullptr) != 1) {
        return std::nullopt;
      }
      std::array<char, 1024 * 1024> buffer {};
      while (file) {
        file.read(buffer.data(), static_cast<std::streamsize>(buffer.size()));
        const auto count = file.gcount();
        if (count > 0 && EVP_DigestUpdate(context.get(), buffer.data(), static_cast<std::size_t>(count)) != 1) {
          return std::nullopt;
        }
      }
      if (!file.eof()) {
        return std::nullopt;
      }
      crypto::sha256_t digest {};
      unsigned int length = 0;
      if (EVP_DigestFinal_ex(context.get(), digest.data(), &length) != 1 || length != digest.size()) {
        return std::nullopt;
      }
      return util::hex(digest).to_string();
    }

    std::optional<std::string> asset_url(const nlohmann::json &release, std::string_view name) {
      if (!release.contains("assets") || !release["assets"].is_array()) {
        return std::nullopt;
      }
      for (const auto &asset : release["assets"]) {
        if (asset.value("name", "") == name && asset.contains("browser_download_url") && asset["browser_download_url"].is_string()) {
          auto url = asset["browser_download_url"].get<std::string>();
          if (valid_download_url(url)) {
            return url;
          }
        }
      }
      return std::nullopt;
    }

    std::optional<release_t> inspect_release(const nlohmann::json &release, std::string &error) {
      const auto manifest_url = asset_url(release, manifest_name);
      const auto signature_url = asset_url(release, signature_name);
      if (!manifest_url && !signature_url) {
        return std::nullopt;
      }
      if (!manifest_url || !signature_url) {
        error = "A release has incomplete update metadata.";
        return std::nullopt;
      }

      std::string manifest_bytes;
      std::string signature_bytes;
      if (!get_memory(*manifest_url, max_manifest_size, manifest_bytes, error) || !get_memory(*signature_url, 128, signature_bytes, error)) {
        return std::nullopt;
      }
      if (!verify_ed25519(update_public_key, manifest_bytes, signature_bytes)) {
        error = "The update manifest signature is invalid.";
        return std::nullopt;
      }

      try {
        const auto manifest = nlohmann::json::parse(manifest_bytes);
        const auto version = manifest.value("version", "");
        const auto tag = manifest.value("tag", "");
        const auto normalized_tag = (tag.starts_with('v') || tag.starts_with('V')) ? tag.substr(1) : tag;
        if (manifest.value("schema", 0) != 1 || tag != release.value("tag_name", "") || normalized_tag != version || manifest.value("prerelease", false) != release.value("prerelease", false) || !manifest.contains("artifact") || !manifest["artifact"].is_object()) {
          error = "The signed update manifest does not match its release.";
          return std::nullopt;
        }
        const auto &artifact = manifest["artifact"];
        const auto filename = artifact.value("name", "");
        const auto sha256 = artifact.value("sha256", "");
        const auto size = artifact.value("size", 0ULL);
        const auto parsed_version = parse_version(version);
        if (!parsed_version || parsed_version->prerelease != manifest.value("prerelease", false) || filename != artifact_name || size == 0 || size > max_artifact_size || sha256.size() != 64 || !std::ranges::all_of(sha256, [](unsigned char value) {
              return std::isxdigit(value) != 0;
            })) {
          error = "The signed update manifest contains invalid values.";
          return std::nullopt;
        }
        const auto archive_url = asset_url(release, filename);
        if (!archive_url) {
          error = "The signed update archive is missing from its release.";
          return std::nullopt;
        }
        return release_t {
          version,
          manifest.value("tag", ""),
          std::string(release_download_prefix.substr(0, release_download_prefix.find("/download/"))) + "/tag/" + tag,
          release.value("body", ""),
          *archive_url,
          sha256,
          size,
          manifest.value("prerelease", false),
        };
      } catch (const std::exception &) {
        error = "The signed update manifest is not valid JSON.";
        return std::nullopt;
      }
    }

    void set_error(std::string message) {
      BOOST_LOG(error) << "Updater: " << message;
      std::lock_guard lock(state.mutex);
      state.phase = "error";
      state.error = std::move(message);
      state.message.clear();
    }

#ifdef _WIN32
    fs::path executable_directory() {
      std::wstring buffer(32768, L'\0');
      const auto length = GetModuleFileNameW(nullptr, buffer.data(), static_cast<DWORD>(buffer.size()));
      if (length == 0 || length >= buffer.size()) {
        return {};
      }
      buffer.resize(length);
      return fs::path(buffer).parent_path();
    }

    bool service_exists() {
      SC_HANDLE manager = OpenSCManagerW(nullptr, nullptr, SC_MANAGER_CONNECT);
      if (!manager) {
        return false;
      }
      SC_HANDLE service = OpenServiceW(manager, L"HeliosService", SERVICE_QUERY_STATUS);
      if (service) {
        CloseServiceHandle(service);
      }
      CloseServiceHandle(manager);
      return service != nullptr;
    }

    std::wstring quote_argument(const std::wstring &value) {
      std::wstring quoted = L"\"";
      std::size_t slashes = 0;
      for (const auto ch : value) {
        if (ch == L'\\') {
          ++slashes;
        } else if (ch == L'\"') {
          quoted.append(slashes * 2 + 1, L'\\');
          quoted.push_back(ch);
          slashes = 0;
        } else {
          quoted.append(slashes, L'\\');
          slashes = 0;
          quoted.push_back(ch);
        }
      }
      quoted.append(slashes * 2, L'\\');
      quoted.push_back(L'\"');
      return quoted;
    }

    bool launch_handoff(
      const fs::path &script,
      const fs::path &archive,
      const fs::path &target,
      const fs::path &current,
      const release_t &release,
      std::uint16_t health_port,
      std::string &error
    ) {
      wchar_t windows_directory[MAX_PATH] {};
      if (GetWindowsDirectoryW(windows_directory, ARRAYSIZE(windows_directory)) == 0) {
        error = "Windows PowerShell could not be located.";
        return false;
      }
      const fs::path powershell = fs::path(windows_directory) / L"System32/WindowsPowerShell/v1.0/powershell.exe";
      if (!fs::is_regular_file(powershell) || !fs::is_regular_file(script)) {
        error = "The packaged update handoff script is missing.";
        return false;
      }

      std::wstring command = quote_argument(powershell.wstring()) +
                             L" -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File " + quote_argument(script.wstring()) +
                             L" -ArchivePath " + quote_argument(archive.wstring()) +
                             L" -TargetDirectory " + quote_argument(target.wstring()) +
                             L" -CurrentDirectory " + quote_argument(current.wstring()) +
                             L" -ExpectedSha256 " + quote_argument(std::wstring(release.sha256.begin(), release.sha256.end())) +
                             L" -ExpectedSize " + std::to_wstring(release.size) +
                             L" -ParentProcessId " + std::to_wstring(GetCurrentProcessId()) +
                             L" -HealthPort " + std::to_wstring(health_port);

      STARTUPINFOW startup {};
      startup.cb = sizeof(startup);
      PROCESS_INFORMATION process {};
      if (!CreateProcessW(
            powershell.c_str(),
            command.data(),
            nullptr,
            nullptr,
            FALSE,
            CREATE_UNICODE_ENVIRONMENT | CREATE_NO_WINDOW | CREATE_NEW_PROCESS_GROUP | CREATE_BREAKAWAY_FROM_JOB,
            nullptr,
            current.c_str(),
            &startup,
            &process
          )) {
        error = "The update handoff could not be started (Windows error " + std::to_string(GetLastError()) + ").";
        return false;
      }
      CloseHandle(process.hThread);
      CloseHandle(process.hProcess);
      return true;
    }
#endif

    [[maybe_unused]] void check_worker(bool include_prereleases) {
      std::string response;
      std::string error;
      if (!get_memory(std::string(releases_url), max_release_response, response, error)) {
        set_error(std::move(error));
        return;
      }
      try {
        const auto releases = nlohmann::json::parse(response);
        if (!releases.is_array()) {
          set_error("The update server returned an unexpected response.");
          return;
        }
        const auto current = parse_version(PROJECT_VERSION);
        if (!current) {
          set_error("This Helios build has an unsupported version number.");
          return;
        }
        std::optional<release_t> best_release;
        std::optional<version_t> best_version;
        for (const auto &candidate : releases) {
          if (candidate.value("draft", false) || (candidate.value("prerelease", false) && !include_prereleases)) {
            continue;
          }
          error.clear();
          auto release = inspect_release(candidate, error);
          if (!release) {
            if (!error.empty()) {
              set_error(std::move(error));
              return;
            }
            continue;
          }
          auto available = parse_version(release->version);
          if (!available) {
            set_error("The release version is invalid.");
            return;
          }
          if (!best_version || compare_versions(*available, *best_version) > 0) {
            best_version = *available;
            best_release = std::move(release);
          }
        }
        if (best_release) {
          std::lock_guard lock(state.mutex);
          state.error.clear();
          state.release = *best_release;
          if (compare_versions(*best_version, *current) > 0) {
            state.phase = "available";
            state.message = "A signed Helios update is ready to install.";
          } else {
            state.phase = "current";
            state.message = "Helios is up to date.";
          }
          return;
        }
        std::lock_guard lock(state.mutex);
        state.phase = "current";
        state.error.clear();
        state.release.reset();
        state.message = "No signed compatible release is available.";
      } catch (const std::exception &) {
        set_error("The update server returned invalid JSON.");
      }
    }

    [[maybe_unused]] void install_worker(release_t release, std::uint16_t health_port) {
#ifndef _WIN32
      set_error("Built-in installation is currently available on Windows only.");
#else
      if (proc::proc.running() != 0) {
        set_error("Stop the active streaming session before installing an update.");
        return;
      }
      if (!service_exists()) {
        set_error("Built-in installation requires HeliosService to be installed.");
        return;
      }

      const auto current = executable_directory();
      if (current.empty()) {
        set_error("The current Helios installation directory could not be determined.");
        return;
      }
      const auto parent = current.parent_path();
      const auto stamp = std::to_string(std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::system_clock::now().time_since_epoch()).count());
      const auto update_root = parent / ("helios-update-" + release.version + "-" + release.sha256.substr(0, 8) + "-" + stamp);
      const auto archive = update_root / std::string(artifact_name);
      const auto target = parent / ("helios-" + release.version + "-" + release.sha256.substr(0, 8) + "-service");
      if (fs::exists(update_root) || fs::exists(target)) {
        set_error("The update staging directory already exists; no files were changed.");
        return;
      }
      std::error_code filesystem_error;
      fs::create_directories(update_root, filesystem_error);
      if (filesystem_error) {
        set_error("The update staging directory could not be created.");
        return;
      }
      std::string error;
      if (!download_file(release.artifact_url, archive, release.size, error)) {
        set_error(std::move(error));
        return;
      }
      const auto actual_size = fs::file_size(archive, filesystem_error);
      if (filesystem_error || actual_size != release.size) {
        set_error("The downloaded update archive has the wrong size.");
        return;
      }
      auto digest = sha256_file(archive);
      if (!digest || !std::ranges::equal(*digest, release.sha256, [](char left, char right) {
            return std::tolower(static_cast<unsigned char>(left)) == std::tolower(static_cast<unsigned char>(right));
          })) {
        set_error("The downloaded update archive failed SHA-256 verification.");
        return;
      }
      if (proc::proc.running() != 0) {
        set_error("A streaming session started while the update was downloading. Stop it and try again.");
        return;
      }

      const auto script = current / L"scripts/update/apply-update.ps1";
      if (!launch_handoff(script, archive, target, current, release, health_port, error)) {
        set_error(std::move(error));
        return;
      }
      {
        std::lock_guard lock(state.mutex);
        state.phase = "installing";
        state.error.clear();
        state.message = "The signed update is installing. Helios will restart automatically.";
      }
      BOOST_LOG(info) << "Updater: verified " << release.version << " and started the staged service handoff.";
      std::this_thread::sleep_for(1s);
      proc::proc.terminate();
      lifetime::exit_sunshine(ERROR_SHUTDOWN_IN_PROGRESS, true);
#endif
    }

    int compare_prerelease(std::string_view left, std::string_view right) {
      while (true) {
        const auto left_separator = left.find('.');
        const auto right_separator = right.find('.');
        const auto left_part = left.substr(0, left_separator);
        const auto right_part = right.substr(0, right_separator);
        std::uint64_t left_number = 0;
        std::uint64_t right_number = 0;
        const auto [left_end, left_error] = std::from_chars(left_part.data(), left_part.data() + left_part.size(), left_number);
        const auto [right_end, right_error] = std::from_chars(right_part.data(), right_part.data() + right_part.size(), right_number);
        const bool left_numeric = !left_part.empty() && left_error == std::errc {} && left_end == left_part.data() + left_part.size();
        const bool right_numeric = !right_part.empty() && right_error == std::errc {} && right_end == right_part.data() + right_part.size();
        if (left_numeric && right_numeric && left_number != right_number) {
          return left_number < right_number ? -1 : 1;
        }
        if (left_numeric != right_numeric) {
          return left_numeric ? -1 : 1;
        }
        if (!left_numeric && left_part != right_part) {
          return left_part < right_part ? -1 : 1;
        }
        const bool left_done = left_separator == std::string_view::npos;
        const bool right_done = right_separator == std::string_view::npos;
        if (left_done || right_done) {
          if (left_done == right_done) {
            return 0;
          }
          return left_done ? -1 : 1;
        }
        left.remove_prefix(left_separator + 1);
        right.remove_prefix(right_separator + 1);
      }
    }
  }  // namespace

  std::optional<version_t> parse_version(std::string_view value) {
    if (value.empty() || value.size() > 128) {
      return std::nullopt;
    }
    if (value.starts_with('v') || value.starts_with('V')) {
      value.remove_prefix(1);
    }
    version_t result;
    std::array<std::uint64_t *, 3> fields {&result.major, &result.minor, &result.patch};
    for (std::size_t index = 0; index < fields.size(); ++index) {
      const auto separator = index < fields.size() - 1 ? value.find('.') : value.find_first_not_of("0123456789");
      const auto end = separator == std::string_view::npos ? value.size() : separator;
      if (end == 0) {
        return std::nullopt;
      }
      const auto part = value.substr(0, end);
      const auto [pointer, ec] = std::from_chars(part.data(), part.data() + part.size(), *fields[index]);
      if (ec != std::errc {} || pointer != part.data() + part.size()) {
        return std::nullopt;
      }
      if (index < fields.size() - 1) {
        if (separator == std::string_view::npos) {
          return std::nullopt;
        }
        value.remove_prefix(separator + 1);
      } else if (separator != std::string_view::npos) {
        const auto suffix = value.substr(separator);
        if (suffix.size() < 2 || (suffix.front() != '-' && suffix.front() != '+' && suffix.front() != '.')) {
          return std::nullopt;
        }
        if (!std::ranges::all_of(suffix.substr(1), [](unsigned char character) {
              return std::isalnum(character) || character == '.' || character == '-';
            })) {
          return std::nullopt;
        }
        result.prerelease = suffix.front() != '+';
        if (result.prerelease) {
          result.prerelease_label = std::string(suffix.substr(1));
        }
      }
    }
    return result;
  }

  int compare_versions(const version_t &left, const version_t &right) {
    const auto left_tuple = std::tie(left.major, left.minor, left.patch);
    const auto right_tuple = std::tie(right.major, right.minor, right.patch);
    if (left_tuple < right_tuple) {
      return -1;
    }
    if (left_tuple > right_tuple) {
      return 1;
    }
    if (left.prerelease != right.prerelease) {
      return left.prerelease ? -1 : 1;
    }
    if (left.prerelease) {
      return compare_prerelease(left.prerelease_label, right.prerelease_label);
    }
    return 0;
  }

  bool verify_ed25519(std::string_view public_key_pem, std::string_view message, std::string_view signature) {
    if (signature.size() != 64) {
      return false;
    }
    crypto::bio_t bio {BIO_new_mem_buf(public_key_pem.data(), static_cast<int>(public_key_pem.size()))};
    if (!bio) {
      return false;
    }
    crypto::pkey_t public_key {PEM_read_bio_PUBKEY(bio.get(), nullptr, nullptr, nullptr)};
    if (!public_key || EVP_PKEY_base_id(public_key.get()) != EVP_PKEY_ED25519) {
      return false;
    }
    crypto::md_ctx_t context {EVP_MD_CTX_new()};
    return context &&
           EVP_DigestVerifyInit(context.get(), nullptr, nullptr, nullptr, public_key.get()) == 1 &&
           EVP_DigestVerify(
             context.get(),
             reinterpret_cast<const unsigned char *>(signature.data()),
             signature.size(),
             reinterpret_cast<const unsigned char *>(message.data()),
             message.size()
           ) == 1;
  }

  nlohmann::json status() {
    std::lock_guard lock(state.mutex);
    nlohmann::json output {
      {"status", true},
#ifdef _WIN32
      {"supported", true},
#else
      {"supported", false},
#endif
      {"phase", state.phase},
      {"current_version", PROJECT_VERSION},
      {"message", state.message},
      {"error", state.error},
    };
    if (state.release) {
      output["available_version"] = state.release->version;
      output["release_url"] = state.release->release_url;
      output["release_notes"] = state.release->notes;
      output["prerelease"] = state.release->prerelease;
    }
    return output;
  }

  bool begin_check(bool include_prereleases, std::string &error) {
#ifndef _WIN32
    error = "Built-in updates are currently available on Windows only.";
    return false;
#else
    {
      std::lock_guard lock(state.mutex);
      if (state.phase == "checking" || state.phase == "downloading" || state.phase == "installing") {
        error = "An update operation is already running.";
        return false;
      }
      state.phase = "checking";
      state.message = "Checking signed Helios releases...";
      state.error.clear();
      state.release.reset();
    }
    std::thread(check_worker, include_prereleases).detach();
    return true;
#endif
  }

  bool begin_install(std::uint16_t health_port, std::string &error) {
#ifndef _WIN32
    error = "Built-in updates are currently available on Windows only.";
    return false;
#else
    release_t release;
    {
      std::lock_guard lock(state.mutex);
      if (state.phase != "available" || !state.release) {
        error = "No verified update is ready to install.";
        return false;
      }
      release = *state.release;
      state.phase = "downloading";
      state.message = "Downloading and verifying the update archive...";
      state.error.clear();
    }
    std::thread(install_worker, std::move(release), health_port).detach();
    return true;
#endif
  }
}  // namespace updater
