use gtk::{glib, prelude::*};
use std::{cell::Cell, f64::consts::PI, rc::Rc};

pub fn panel() -> gtk::Box {
    let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
    panel.add_css_class("about-page");
    panel.set_valign(gtk::Align::Center);
    panel.set_vexpand(true);
    let logo = animated_logo(false);
    panel.append(&logo);
    let title = gtk::Label::new(Some("Spotlight"));
    title.add_css_class("about-title");
    panel.append(&title);
    let version = gtk::Label::new(Some(concat!("Version ", env!("CARGO_PKG_VERSION"))));
    version.set_widget_name("about-version");
    version.add_css_class("about-version");
    version.set_halign(gtk::Align::Center);
    version.set_selectable(true);
    panel.append(&version);
    let description = gtk::Label::new(Some(
        "A little spotlight for everything you do.\nApps, files, notes, and everyday tools — a keystroke away.",
    ));
    description.set_wrap(true);
    description.set_justify(gtk::Justification::Center);
    description.add_css_class("about-description");
    panel.append(&description);
    let author = gtk::Label::new(Some("Created by Danny Rudd"));
    author.set_margin_top(12);
    panel.append(&author);
    let profile = github_link(
        "https://github.com/danny19862025",
        "github.com/danny19862025",
    );
    profile.set_widget_name("about-github");
    panel.append(&profile);
    let repository = github_link(
        "https://github.com/danny19862025/spotlight",
        "Spotlight on GitHub",
    );
    repository.set_widget_name("about-repository");
    panel.append(&repository);
    crate::updates::add_controls(&panel);
    let details = gtk::Label::new(Some(
        "Built with Rust & GTK 4  ·  Made for Linux\nMIT License",
    ));
    details.set_justify(gtk::Justification::Center);
    details.add_css_class("subtitle");
    details.set_margin_top(16);
    panel.append(&details);
    panel
}

fn animated_logo(opening: bool) -> gtk::DrawingArea {
    let logo = gtk::DrawingArea::builder()
        .content_width(200)
        .content_height(190)
        .halign(gtk::Align::Center)
        .build();
    logo.set_widget_name("about-logo");
    logo.add_css_class("about-logo");
    logo.update_property(&[gtk::accessible::Property::Label("Spotlight logo")]);
    let phase = Rc::new(Cell::new(0.0_f64));
    let frame = Rc::clone(&phase);
    let start = Cell::new(None);
    logo.add_tick_callback(move |logo, clock| {
        let animate = gtk::Settings::default().is_none_or(|s| s.is_gtk_enable_animations());
        frame.set(if animate {
            if opening {
                let first = start.get().unwrap_or_else(|| {
                    start.set(Some(clock.frame_time()));
                    clock.frame_time()
                });
                (clock.frame_time() - first) as f64 / 1_000_000.
            } else {
                (clock.frame_time() as f64 / 1_000_000.) % (PI * 8.)
            }
        } else {
            0.
        });
        logo.queue_draw();
        glib::ControlFlow::Continue
    });
    logo.set_draw_func(move |logo, cr, width, height| {
        let t = phase.get();
        let accent = logo.color();
        let (r, g, b) = (
            accent.red() as f64,
            accent.green() as f64,
            accent.blue() as f64,
        );
        cr.translate(width as f64 / 2., height as f64 / 2. + t.sin() * 3.);
        if opening {
            // Two expanding waves and a rotating spark trail introduce the mark.
            for delay in [0., 0.2] {
                let pulse = ((t - delay) / 1.1).clamp(0., 1.);
                cr.set_source_rgba(r, g, b, (1. - pulse) * 0.65 * (t / 0.12).clamp(0., 1.));
                cr.set_line_width(2. * (1. - pulse) + 0.5);
                cr.arc(0., 0., 30. + 62. * pulse, 0., PI * 2.);
                let _ = cr.stroke();
            }
            for i in 0..10 {
                let angle = i as f64 * PI / 5. + t * 1.7;
                let spread = (t / 0.85).clamp(0., 1.);
                let radius = 44. + spread * 47.;
                cr.set_source_rgba(r, g, b, (1. - spread) * 0.8);
                cr.arc(angle.cos() * radius, angle.sin() * radius, 1.8, 0., PI * 2.);
                let _ = cr.fill();
            }
            let reveal = (t / 0.65).clamp(0., 1.);
            let ease = 1. - (1. - reveal).powi(3);
            let scale = 0.45 + 0.55 * ease + (t * 10.).sin() * (-t * 5.).exp() * 0.12;
            cr.scale(scale, scale);
            cr.rotate((1. - ease) * -0.5);
        }
        // A quiet halo and floating motion surround the original three-bar mark.
        for i in (0..8).rev() {
            cr.set_source_rgba(r, g, b, (0.018 + t.sin() * 0.004) * (8 - i) as f64);
            cr.arc(0., 0., 66. + i as f64 * 3., 0., 2. * PI);
            let _ = cr.fill();
        }
        cr.set_source_rgb(0.09, 0.09, 0.11);
        let radius = 28.;
        cr.new_sub_path();
        for (x, y, start) in [
            (32., -32., -PI / 2.),
            (32., 32., 0.),
            (-32., 32., PI / 2.),
            (-32., -32., PI),
        ] {
            cr.arc(x, y, radius, start, start + PI / 2.);
        }
        cr.close_path();
        let _ = cr.fill_preserve();
        if opening {
            // Sweep a soft highlight across the rounded logo tile.
            let _ = cr.save();
            cr.clip();
            let x = -130. + (t / 0.95).clamp(0., 1.) * 280.;
            let shine = gtk::cairo::LinearGradient::new(x - 30., 0., x + 30., 0.);
            shine.add_color_stop_rgba(0., 1., 1., 1., 0.);
            shine.add_color_stop_rgba(0.5, 1., 1., 1., 0.22);
            shine.add_color_stop_rgba(1., 1., 1., 1., 0.);
            if cr.set_source(&shine).is_ok() {
                let _ = cr.paint();
            }
            let _ = cr.restore();
        }
        cr.new_path();
        cr.rotate(-42_f64.to_radians());
        cr.set_source_rgb(r, g, b);
        cr.set_line_width(12.);
        cr.set_line_cap(gtk::cairo::LineCap::Round);
        for (y, end) in [(-20., 34.), (0., 34.), (20., 6.)] {
            cr.move_to(-34., y);
            cr.line_to(end, y);
            let _ = cr.stroke();
        }
    });
    logo
}

fn github_link(uri: &str, label: &str) -> gtk::LinkButton {
    let link = gtk::LinkButton::new(uri);
    link.set_halign(gtk::Align::Center);
    link.set_tooltip_text(Some(uri));
    let content = gtk::Box::new(gtk::Orientation::Horizontal, 10);
    if let Ok(loader) = gtk::gdk_pixbuf::PixbufLoader::with_type("svg") {
        loader.set_size(48, 48);
        if loader.write(include_bytes!("../assets/github.svg")).is_ok()
            && loader.close().is_ok()
            && let Some(pixbuf) = loader.pixbuf()
        {
            let icon = gtk::Image::from_pixbuf(Some(&pixbuf));
            icon.set_pixel_size(24);
            content.append(&icon);
        }
    }
    content.append(&gtk::Label::new(Some(label)));
    link.set_child(Some(&content));
    link
}

/// A short logo reveal on each Settings opening, driven by GTK's frame clock.
pub fn opening_animation(overlay: &gtk::Overlay) {
    if gtk::Settings::default().is_some_and(|s| !s.is_gtk_enable_animations()) {
        return;
    }
    let intro = gtk::Box::new(gtk::Orientation::Vertical, 8);
    intro.set_widget_name("settings-logo-intro");
    intro.add_css_class("settings-shell");
    intro.set_hexpand(true);
    intro.set_vexpand(true);
    // Keep Settings controls available during the brief reveal.
    intro.set_can_target(false);
    let content = gtk::Box::new(gtk::Orientation::Vertical, 8);
    content.set_valign(gtk::Align::Center);
    content.set_vexpand(true);
    content.append(&animated_logo(true));
    let title = gtk::Label::new(Some("Spotlight"));
    title.add_css_class("about-title");
    content.append(&title);
    intro.append(&content);
    overlay.add_overlay(&intro);
    let parent = overlay.downgrade();
    let layer = intro.downgrade();
    let start = Cell::new(None);
    intro.add_tick_callback(move |intro, clock| {
        let elapsed = (clock.frame_time()
            - start.get().unwrap_or_else(|| {
                start.set(Some(clock.frame_time()));
                clock.frame_time()
            })) as f64
            / 1_000_000.;
        intro.set_opacity(((1.65 - elapsed) / 0.35).clamp(0., 1.));
        if elapsed >= 1.65 {
            if let (Some(parent), Some(layer)) = (parent.upgrade(), layer.upgrade()) {
                parent.remove_overlay(&layer);
            }
            glib::ControlFlow::Break
        } else {
            glib::ControlFlow::Continue
        }
    });
}
