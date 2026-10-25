use gtk::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Clone, Copy, Debug, Default, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum WindowMode {
    #[default]
    Compact,
    Expanded,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(default)]
pub struct Preferences {
    pub mode: WindowMode,
    pub scale: u16,
}

impl Default for Preferences {
    fn default() -> Self {
        Self {
            mode: WindowMode::Compact,
            scale: 100,
        }
    }
}

impl Preferences {
    pub fn normalized(mut self) -> Self {
        if ![90, 100, 110, 125].contains(&self.scale) {
            self.scale = 100;
        }
        self
    }

    pub fn dimensions(self) -> (i32, i32) {
        let (width, height) = match self.mode {
            WindowMode::Compact => (760, 530),
            WindowMode::Expanded => (1040, 720),
        };
        (
            width * i32::from(self.normalized().scale) / 100,
            height * i32::from(self.normalized().scale) / 100,
        )
    }

    pub fn css(self) -> String {
        let s = f64::from(self.normalized().scale) / 100.;
        let (body, search, title, small, heading) = (13. * s, 21. * s, 14. * s, 11. * s, 23. * s);
        let (row_y, row_x, row_h, panel, top_y, top_x) =
            (8. * s, 10. * s, 37. * s, 28. * s, 16. * s, 20. * s);
        format!(
            r#"
.shell, .settings-shell {{ font-size: {body}px; }}
.shell .search {{ font-size: {search}px; min-height: {}px; }}
.shell .item-title, .settings-shell .item-title {{ font-size: {title}px; }}
.shell .subtitle, .shell .badge, .shell .section, .shell .footer,
.settings-shell .subtitle {{ font-size: {small}px; }}
.shell row {{ padding: {row_y}px {row_x}px; min-height: {row_h}px; }}
.shell .launcher-top {{ padding: {top_y}px {top_x}px; }}
.shell .tile {{ padding: {}px; font-size: {}px; }}
.settings-shell .guide-title {{ font-size: {heading}px; }}
.settings-shell .editor {{ padding: {}px {panel}px; }}
.settings-heading {{ padding: {}px {panel}px {}px; }}
.settings-shell button {{ padding: {}px {}px; }}
.settings-tabs button {{ padding: {}px {}px; }}
.settings-shell .window-mode {{ padding: {}px; min-height: {}px; }}
.settings-shell .about-title {{ font-size: {}px; }}
.settings-shell .about-description {{ font-size: {body}px; }}
"#,
            40. * s,
            6. * s,
            19. * s,
            24. * s,
            24. * s,
            18. * s,
            6. * s,
            10. * s,
            12. * s,
            12. * s,
            18. * s,
            112. * s,
            32. * s
        )
    }
}

pub fn fit_window(window: &impl IsA<gtk::Window>, width: i32, height: i32) {
    let window = window.as_ref();
    let display = gtk::prelude::WidgetExt::display(window);
    let monitor = window
        .surface()
        .and_then(|surface| display.monitor_at_surface(&surface))
        .or_else(|| {
            display
                .monitors()
                .item(0)
                .and_downcast::<gtk::gdk::Monitor>()
        });
    let (width, height) = if let Some(monitor) = monitor {
        let area = monitor.geometry();
        (
            width.min((area.width() - 80).max(360)),
            height.min((area.height() - 100).max(360)),
        )
    } else {
        (width, height)
    };
    window.set_default_size(width, height);
}

pub fn panel(
    initial: Preferences,
    apply: impl Fn(Preferences) -> Result<(), String> + 'static,
) -> gtk::Box {
    let initial = initial.normalized();
    let panel = gtk::Box::new(gtk::Orientation::Vertical, 18);
    panel.add_css_class("editor");
    let heading = gtk::Label::new(Some("Window & interface"));
    heading.add_css_class("guide-title");
    heading.set_xalign(0.);
    panel.append(&heading);
    let description = gtk::Label::new(Some("Give Spotlight the space that suits you."));
    description.add_css_class("subtitle");
    description.set_xalign(0.);
    panel.append(&description);
    let modes = gtk::Box::new(gtk::Orientation::Horizontal, 12);
    let card = |name, expanded: bool, description, widget_name| {
        let button = gtk::ToggleButton::new();
        button.set_widget_name(widget_name);
        button.add_css_class("window-mode");
        button.set_hexpand(true);
        let contents = gtk::Box::new(gtk::Orientation::Vertical, 10);
        let image = gtk::DrawingArea::builder()
            .content_width(28)
            .content_height(28)
            .halign(gtk::Align::Center)
            .build();
        image.set_draw_func(move |image, cr, _, _| {
            let color = image.color();
            cr.set_source_rgba(
                color.red() as f64,
                color.green() as f64,
                color.blue() as f64,
                color.alpha() as f64,
            );
            cr.set_line_width(2.);
            if expanded {
                cr.rectangle(3., 4., 22., 20.);
                cr.move_to(3., 9.);
                cr.line_to(25., 9.);
            } else {
                cr.move_to(7., 17.);
                cr.line_to(3., 17.);
                cr.line_to(3., 4.);
                cr.line_to(19., 4.);
                cr.line_to(19., 8.);
                cr.rectangle(8., 9., 17., 15.);
                cr.move_to(8., 14.);
                cr.line_to(25., 14.);
            }
            let _ = cr.stroke();
        });
        contents.append(&image);
        let label = gtk::Label::new(Some(name));
        label.add_css_class("item-title");
        contents.append(&label);
        let detail = gtk::Label::new(Some(description));
        detail.add_css_class("subtitle");
        contents.append(&detail);
        button.set_child(Some(&contents));
        button.update_property(&[gtk::accessible::Property::Label(name)]);
        button
    };
    let compact = card("Compact", false, "Quick and focused", "window-compact");
    let expanded = card("Expanded", true, "More room to browse", "window-expanded");
    expanded.set_group(Some(&compact));
    compact.set_active(initial.mode == WindowMode::Compact);
    expanded.set_active(initial.mode == WindowMode::Expanded);
    modes.append(&compact);
    modes.append(&expanded);
    panel.append(&modes);
    let size_label = gtk::Label::new(Some("Interface size"));
    size_label.set_xalign(0.);
    size_label.add_css_class("item-title");
    size_label.set_margin_top(12);
    panel.append(&size_label);
    let size = gtk::DropDown::from_strings(&[
        "Small · 90%",
        "Default · 100%",
        "Large · 110%",
        "Extra large · 125%",
    ]);
    size.set_widget_name("interface-size");
    size.set_selected(
        [90, 100, 110, 125]
            .iter()
            .position(|s| *s == initial.scale)
            .unwrap() as u32,
    );
    size.update_property(&[gtk::accessible::Property::Label("Interface size")]);
    panel.append(&size);
    let hint = gtk::Label::new(Some(
        "Adjust text and spacing in the launcher and Settings.\nWindow size stays within your screen.",
    ));
    hint.set_wrap(true);
    hint.set_xalign(0.);
    hint.add_css_class("subtitle");
    panel.append(&hint);
    let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 10);
    let save = gtk::Button::with_label("Apply changes");
    save.set_widget_name("interface-apply");
    save.add_css_class("accent");
    buttons.append(&save);
    let reset = gtk::Button::with_label("Reset to default");
    reset.set_widget_name("interface-reset");
    buttons.append(&reset);
    panel.append(&buttons);
    let status = gtk::Label::new(None);
    status.set_widget_name("interface-status");
    status.set_wrap(true);
    status.set_xalign(0.);
    status.add_css_class("subtitle");
    panel.append(&status);
    let scale = size.clone();
    let mode = expanded.clone();
    save.connect_clicked(move |_| {
        let preferences = Preferences {
            mode: if mode.is_active() {
                WindowMode::Expanded
            } else {
                WindowMode::Compact
            },
            scale: [90, 100, 110, 125][scale.selected() as usize],
        };
        match apply(preferences) {
            Ok(()) => status.set_text("Saved · applied now and remembered for next time"),
            Err(error) => status.set_text(&error),
        }
    });
    reset.connect_clicked(move |_| {
        compact.set_active(true);
        size.set_selected(1);
    });
    panel
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn saved_preferences_and_old_store_defaults() {
        let old: crate::core::Store = serde_json::from_str("{}").unwrap();
        assert_eq!(old.interface, Preferences::default());
        let settings = Preferences {
            mode: WindowMode::Expanded,
            scale: 125,
        };
        assert_eq!(
            serde_json::from_str::<Preferences>(&serde_json::to_string(&settings).unwrap())
                .unwrap(),
            settings
        );
        assert_eq!(
            Preferences {
                scale: 65535,
                ..settings
            }
            .normalized()
            .scale,
            100
        );
    }
}
