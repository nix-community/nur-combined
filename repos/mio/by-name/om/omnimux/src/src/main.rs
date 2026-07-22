mod actions;
mod fonts;
mod hosts;
mod palette;
mod session;
mod settings;
mod ssh_config;
mod tabs;

use actions::{
    CloseOverlay, CloseTab, Copy, FindInTerminal, HostListDown, HostListUp, NewTab, NextTab,
    Paste, PrevTab, SearchNext, SearchPrev, ZoomIn, ZoomOut, ZoomReset,
};
use fonts::load_bundled_symbol_fonts;
use gpui::prelude::*;
use gpui::*;
use tabs::TerminalTabs;

/// Keymap context for chrome shortcuts that must not steal terminal key bindings.
const CHROME: &str = "omnimux && !omnimux_terminal";

fn main() {
    gpui::Application::new().run(|cx: &mut gpui::App| {
        gpui_component::init(cx);
        load_bundled_symbol_fonts(cx);

        cx.bind_keys([
            KeyBinding::new("cmd-t", NewTab, Some("omnimux")),
            KeyBinding::new("ctrl-t", NewTab, Some("omnimux")),
            KeyBinding::new("cmd-w", CloseTab, Some("omnimux")),
            KeyBinding::new("ctrl-w", CloseTab, Some("omnimux")),
            KeyBinding::new("cmd-f", FindInTerminal, Some(CHROME)),
            KeyBinding::new("ctrl-f", FindInTerminal, Some(CHROME)),
            KeyBinding::new("cmd-=", ZoomIn, Some(CHROME)),
            KeyBinding::new("ctrl-=", ZoomIn, Some(CHROME)),
            KeyBinding::new("cmd-plus", ZoomIn, Some(CHROME)),
            KeyBinding::new("ctrl-plus", ZoomIn, Some(CHROME)),
            KeyBinding::new("cmd--", ZoomOut, Some(CHROME)),
            KeyBinding::new("ctrl--", ZoomOut, Some(CHROME)),
            KeyBinding::new("cmd-0", ZoomReset, Some(CHROME)),
            KeyBinding::new("ctrl-0", ZoomReset, Some(CHROME)),
            // Copy/Paste must work while the terminal is focused (Zed Terminal context).
            // CHROME (`!omnimux_terminal`) would let ctrl-shift-c fall through as ^C.
            KeyBinding::new("cmd-c", Copy, Some("omnimux")),
            KeyBinding::new("cmd-c", Copy, Some("omnimux_terminal")),
            #[cfg(not(target_os = "macos"))]
            KeyBinding::new("ctrl-shift-c", Copy, Some("omnimux")),
            #[cfg(not(target_os = "macos"))]
            KeyBinding::new("ctrl-shift-c", Copy, Some("omnimux_terminal")),
            KeyBinding::new("cmd-v", Paste, Some("omnimux")),
            KeyBinding::new("cmd-v", Paste, Some("omnimux_terminal")),
            #[cfg(not(target_os = "macos"))]
            KeyBinding::new("ctrl-shift-v", Paste, Some("omnimux")),
            #[cfg(not(target_os = "macos"))]
            KeyBinding::new("ctrl-shift-v", Paste, Some("omnimux_terminal")),
            KeyBinding::new("escape", CloseOverlay, Some(CHROME)),
            KeyBinding::new("escape", CloseOverlay, Some("omnimux_prompt")),
            KeyBinding::new("escape", CloseOverlay, Some("omnimux_search")),
            KeyBinding::new("escape", CloseOverlay, Some("omnimux_link_confirm")),
            KeyBinding::new("cmd-]", NextTab, Some(CHROME)),
            KeyBinding::new("ctrl-]", NextTab, Some(CHROME)),
            KeyBinding::new("cmd-[", PrevTab, Some(CHROME)),
            KeyBinding::new("ctrl-[", PrevTab, Some(CHROME)),
            KeyBinding::new("up", HostListUp, Some("omnimux_prompt")),
            KeyBinding::new("down", HostListDown, Some("omnimux_prompt")),
            KeyBinding::new("cmd-g", SearchNext, Some("omnimux_search")),
            KeyBinding::new("ctrl-g", SearchNext, Some("omnimux_search")),
            KeyBinding::new("cmd-shift-g", SearchPrev, Some("omnimux_search")),
            KeyBinding::new("ctrl-shift-g", SearchPrev, Some("omnimux_search")),
        ]);

        let bounds = Bounds::centered(None, size(px(800.0), px(600.0)), cx);
        cx.open_window(
            WindowOptions {
                window_bounds: Some(WindowBounds::Windowed(bounds)),
                titlebar: Some(TitlebarOptions {
                    title: Some("omnimux".into()),
                    appears_transparent: true,
                    traffic_light_position: Some(point(px(12.0), px(10.0))),
                }),
                window_decorations: Some(WindowDecorations::Client),
                app_id: Some("omnimux".into()),
                ..Default::default()
            },
            |window, cx| {
                // gpui-component Input/Switch paint paths call Root::read; the
                // window's first view must be Root (see gpui-component README).
                let view = cx.new(|cx| TerminalTabs::new(window, cx));
                cx.new(|cx| gpui_component::Root::new(view, window, cx))
            },
        )
        .unwrap();
        cx.activate(true);
    });
}
