use gtk::{glib, prelude::*};
use std::{cell::Cell, f64::consts::PI, rc::Rc};

pub fn panel() -> gtk::Box {
    let panel = gtk::Box::new(gtk::Orientation::Vertical, 12);
    panel.add_css_class("about-page");
    panel.set_valign(gtk::Align::Center);
    panel.set_vexpand(true);
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
    logo.add_tick_callback(move |logo, clock| {
        let animate = gtk::Settings::default().is_none_or(|s| s.is_gtk_enable_animations());
        frame.set(if animate {
            (clock.frame_time() as f64 / 1_000_000.) % (PI * 8.)
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
        let _ = cr.fill();
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
    let author = gtk::Label::new(Some("Created by Danny"));
    author.set_margin_top(12);
    panel.append(&author);
    let details = gtk::Label::new(Some(
        "Built with Rust & GTK 4  ·  Made for Linux\nMIT License",
    ));
    details.set_justify(gtk::Justification::Center);
    details.add_css_class("subtitle");
    details.set_margin_top(16);
    panel.append(&details);
    panel
}
