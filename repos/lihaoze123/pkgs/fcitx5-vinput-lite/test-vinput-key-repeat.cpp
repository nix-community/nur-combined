// Replay Qt's synthetic release/press pairs against the real Vinput handler.
// Built with -fno-access-control to seed a session without a microphone or D-Bus.
#include <chrono>
#include <cstdlib>
#include <filesystem>
#include <iostream>
#include <stdexcept>
#include <string>
#include <unistd.h>

#include "core/vinput.h"
#include <fcitx/inputcontext.h>

namespace {
void expect(bool condition, const char *message) {
    if (!condition)
        throw std::runtime_error(message);
}

struct Sandbox {
    std::filesystem::path path;
    Sandbox() {
        std::string pattern =
            (std::filesystem::temp_directory_path() / "vinput-repeat-XXXXXX").string();
        auto *dir = mkdtemp(pattern.data());
        if (!dir)
            throw std::runtime_error("mkdtemp failed");
        path = dir;
        for (const char *name :
             {"HOME", "XDG_CONFIG_HOME", "XDG_CACHE_HOME", "XDG_DATA_HOME", "XDG_STATE_HOME"}) {
            setenv(name, dir, 1);
        }
        setenv("DBUS_SESSION_BUS_ADDRESS", "unix:path=/nonexistent-vinput-test-bus", 1);
    }
    ~Sandbox() { std::filesystem::remove_all(path); }
};

class TestInputContext : public fcitx::InputContext {
  public:
    explicit TestInputContext(fcitx::Instance &instance)
        : InputContext(instance.inputContextManager()) {
        created();
    }
    ~TestInputContext() override { destroy(); }
    const char *frontend() const override { return "test"; }

  protected:
    void commitStringImpl(const std::string &) override {}
    void deleteSurroundingTextImpl(int, unsigned int) override {}
    void forwardKeyImpl(const fcitx::ForwardKeyEvent &) override {}
    void updatePreeditImpl() override {}
};

void replay(VinputEngine &engine, TestInputContext &ic, fcitx::KeyStates modifiers, bool release,
            bool repeat) {
    const auto states = modifiers | fcitx::KeyState::NumLock |
                        (repeat ? fcitx::KeyState::Repeat : fcitx::KeyState::NoState);
    fcitx::KeyEvent event(&ic, fcitx::Key(FcitxKey_F9, states, 75), release);
    engine.handleKeyEvent(event);
    expect(event.filtered() && event.accepted(), "hotkey event must be consumed");
}

void run() {
    Sandbox sandbox;
    char name[] = "vinput-key-repeat-test";
    char disable[] = "--disable=all";
    char *argv[] = {name, disable, nullptr};
    fcitx::Instance instance(2, argv);
    TestInputContext ic(instance);
    VinputEngine engine(&instance);
    fcitx::RawConfig config;
    config.setValueByPath("TriggerKey/0", "F9");
    config.setValueByPath("CommandKeys/0", "Control+F9");
    config.setValueByPath("MenuKey/0", "Shift+F9");
    engine.setConfig(config);

    for (auto mode : {TriggerMode::Hold, TriggerMode::Tap, TriggerMode::Both}) {
        for (bool command : {false, true}) {
            for (auto phase : {VinputEngine::Session::Phase::PendingStart,
                               VinputEngine::Session::Phase::Recording}) {
                const auto modifiers =
                    command ? fcitx::KeyStates(fcitx::KeyState::Ctrl) : fcitx::KeyStates();
                const fcitx::Key trigger(FcitxKey_F9, modifiers);
                const auto now = std::chrono::steady_clock::now();
                engine.config_.triggerMode.setValue(mode);
                engine.trigger_mode_ = mode;
                engine.session_ = VinputEngine::Session{
                    phase, &ic, trigger, now, command, false, true, {}, mode != TriggerMode::Tap};
                engine.held_key_sym_ = FcitxKey_F9;
                engine.held_role_ =
                    command ? VinputEngine::HotkeyRole::Command : VinputEngine::HotkeyRole::Trigger;
                engine.held_press_time_ = now;
                engine.last_trigger_time_ = now - std::chrono::seconds(1);
                engine.chord_interrupted_ = false;

                // The captured DMS stream sends one synthetic release then press
                // every 40 ms. Assert after each edge, including the first release.
                for (int i = 0; i < 20; ++i) {
                    for (bool release : {true, false}) {
                        replay(engine, ic, modifiers, release, true);
                        expect(engine.session_.has_value(), "repeat must not cancel the session");
                        expect(engine.session_->phase == phase,
                               "repeat must not stop or toggle recording");
                        expect(!engine.session_->trigger_released,
                               "synthetic release is not a physical release");
                        expect(!engine.chord_interrupted_, "repeat must not interrupt the hotkey");
                        expect(!engine.pending_stop_event_ ||
                                   !engine.pending_stop_event_->isEnabled(),
                               "repeat must not arm the stop timer");
                    }
                }
                replay(engine, ic, modifiers, true, false);
                expect(engine.session_ && engine.session_->trigger_released,
                       "physical release must still be handled");
                if (mode == TriggerMode::Hold && phase == VinputEngine::Session::Phase::Recording) {
                    expect(engine.pending_stop_event_ && engine.pending_stop_event_->isEnabled(),
                           "physical release must schedule Hold recording to stop");
                }
                engine.cancelPendingStop();
                engine.session_.reset();
            }
        }
    }

    // WeChat's legacy Fcitx4 client omits Repeat. Replay its unmarked
    // release/press pairs faster than the 80 ms trigger debounce interval.
    for (auto mode : {TriggerMode::Hold, TriggerMode::Both}) {
        for (bool command : {false, true}) {
            const auto modifiers =
                command ? fcitx::KeyStates(fcitx::KeyState::Ctrl) : fcitx::KeyStates();
            const fcitx::Key trigger(FcitxKey_F9, modifiers);
            const auto start = std::chrono::steady_clock::now() - std::chrono::seconds(1);
            engine.config_.triggerMode.setValue(mode);
            engine.trigger_mode_ = mode;
            engine.session_ = VinputEngine::Session{VinputEngine::Session::Phase::Recording,
                                                    &ic,
                                                    trigger,
                                                    start,
                                                    command,
                                                    false,
                                                    true,
                                                    {},
                                                    true};
            engine.held_key_sym_ = FcitxKey_F9;
            engine.held_role_ =
                command ? VinputEngine::HotkeyRole::Command : VinputEngine::HotkeyRole::Trigger;
            engine.held_press_time_ = start;
            engine.last_trigger_time_ = std::chrono::steady_clock::now();
            for (int i = 0; i < 20; ++i) {
                replay(engine, ic, modifiers, true, false);
                replay(engine, ic, modifiers, false, false);
                expect(engine.session_ &&
                           engine.session_->phase == VinputEngine::Session::Phase::Recording,
                       "legacy Qt repeat must continue the Hold recording");
                expect(!engine.session_->trigger_released,
                       "legacy repeat press must restore the held state");
                expect(!engine.pending_stop_event_->isEnabled(),
                       "legacy repeat press must cancel the stop timer");
            }
            replay(engine, ic, modifiers, true, false);
            expect(engine.pending_stop_event_->isEnabled(),
                   "final legacy release must still schedule a stop");
            engine.cancelPendingStop();
            engine.session_.reset();
        }
    }

    // Menu hotkeys also wait for the physical release.
    replay(engine, ic, fcitx::KeyState::Shift, false, false);
    for (bool release : {true, false}) {
        replay(engine, ic, fcitx::KeyState::Shift, release, true);
        expect(!engine.palette_menu_visible_, "repeated menu key must not open the menu");
        expect(engine.held_role_ == VinputEngine::HotkeyRole::Menu,
               "repeat must preserve the held menu key");
    }
    replay(engine, ic, fcitx::KeyState::Shift, true, false);
    expect(engine.palette_menu_visible_, "physical menu release must open the menu");
    engine.hidePaletteMenu();

    // Repeating ordinary keys must still reach the application.
    fcitx::KeyEvent ordinary(&ic, fcitx::Key(FcitxKey_a, fcitx::KeyState::Repeat));
    engine.handleKeyEvent(ordinary);
    expect(!ordinary.filtered() && !ordinary.accepted(), "ordinary key repeats must pass through");
    std::cout << "Qt key repeat regression: PASS\n";
}
} // namespace

int main() {
    try {
        run();
    } catch (const std::exception &error) {
        std::cerr << error.what() << '\n';
        return 1;
    }
}
