mod fonts;
mod palette;
mod session;
mod settings;
mod ssh_config;
mod tabs;

use fonts::load_bundled_symbol_fonts;
use gpui::prelude::*;
use gpui::*;
use tabs::TerminalTabs;

fn main() {
    gpui::Application::new().run(|cx: &mut gpui::App| {
        gpui_component::init(cx);
        load_bundled_symbol_fonts(cx);

        let bounds = Bounds::centered(None, size(px(800.0), px(600.0)), cx);
        cx.open_window(
            WindowOptions {
                window_bounds: Some(WindowBounds::Windowed(bounds)),
                titlebar: Some(TitlebarOptions {
                    title: Some("omnimux".into()),
                    appears_transparent: true,
                    traffic_light_position: Some(point(px(12.0), px(10.0))),
                }),
                // Always client decorations so we have a single title bar (app chrome +
                // window controls). Server decorations on Plasma doubled the chrome.
                window_decorations: Some(WindowDecorations::Client),
                app_id: Some("omnimux".into()),
                ..Default::default()
            },
            |window, cx| cx.new(|cx| TerminalTabs::new(window, cx)),
        )
        .unwrap();
        cx.activate(true);
    });
}
