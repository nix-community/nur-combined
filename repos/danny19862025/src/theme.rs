use crate::color;
use gtk::{gdk, prelude::*};
use serde::{Deserialize, Serialize};
use std::{cell::Cell, rc::Rc};

#[derive(Clone, Debug, PartialEq, Eq, Serialize, Deserialize)]
#[serde(default)]
pub struct Theme {
    pub background: String,
    pub text: String,
    pub accent: String,
    pub selection: String,
}

impl Default for Theme {
    fn default() -> Self {
        Self::preset(0)
    }
}

impl Theme {
    pub fn preset(index: u32) -> Self {
        let colors = match index {
            1 => ["#F7F8FC", "#202331", "#635BDB", "#DFE4FA"],
            2 => ["#0D1728", "#E5EEFF", "#62B8FF", "#243C5C"],
            _ => ["#17171C", "#EEEDF2", "#EC5862", "#34343F"],
        };
        Self {
            background: colors[0].into(),
            text: colors[1].into(),
            accent: colors[2].into(),
            selection: colors[3].into(),
        }
    }

    fn values(&self) -> [&str; 4] {
        [&self.background, &self.text, &self.accent, &self.selection]
    }

    fn from_entries(entries: &[gtk::Entry]) -> Result<Self, String> {
        let mut theme = Self::default();
        let fields = [
            &mut theme.background,
            &mut theme.text,
            &mut theme.accent,
            &mut theme.selection,
        ];
        for (field, entry) in fields.into_iter().zip(entries) {
            *field = entry.text().trim().to_ascii_uppercase();
            color::rgb(field).map_err(|_| "Use a color such as #635BDB in every field")?;
        }
        Ok(theme)
    }

    pub fn css(&self) -> Result<String, String> {
        let [bg, fg, accent, selection] = self
            .values()
            .map(color::rgb)
            .into_iter()
            .collect::<Result<Vec<_>, _>>()?
            .try_into()
            .unwrap();
        let background = hex(bg);
        let text = hex(fg);
        let accent = hex(accent);
        let selection = hex(selection);
        let surface = blend(bg, fg, 0.05);
        let raised = blend(bg, fg, 0.09);
        let border = blend(bg, fg, 0.17);
        let muted = blend(bg, fg, 0.64);
        let accent_text = contrast(color::rgb(&accent)?);
        let selected_text = contrast(color::rgb(&selection)?);
        Ok(format!(
            r#"
window {{ color: {text}; }}
.shell, .editor, .screen-measure {{ background: {background}; color: {text}; border-color: {border}; }}
.launcher-top, .footer {{ border-color: {border}; }}
.accent {{ background: {accent}; color: {accent_text}; border-color: {accent}; }}
.search {{ color: {text}; caret-color: {accent}; }}
.item-title, button label {{ color: {text}; }}
.guide-title {{ color: {text}; }}
.guide-example {{ background: {surface}; color: {text}; }}
.section, .subtitle, .badge, .footer {{ color: {muted}; }}
.footer label {{ color: {muted}; }}
.footer button label {{ color: {text}; }}
row:hover {{ background: transparent; }}
row:selected, row:selected:hover {{ background: {selection}; color: {selected_text}; }}
row:selected .item-title {{ color: {selected_text}; }}
row:selected .subtitle, row:selected .badge {{ color: {selected_text}; opacity: 0.78; }}
.tile, button, .key {{ background: {raised}; color: {text}; border-color: {border}; }}
button:hover {{ background: {selection}; color: {selected_text}; }}
button:hover:not(:disabled), button:focus-visible:not(:disabled) {{ border-color: alpha({accent}, 0.65); box-shadow: 0 0 12px 1px alpha({accent}, 0.28); }}
button:checked:not(:disabled) {{ border-color: {accent}; box-shadow: 0 0 10px 1px alpha({accent}, 0.22); }}
button:active:not(:disabled) {{ box-shadow: 0 0 6px 1px alpha({accent}, 0.32); }}
.accent label {{ color: {accent_text}; }}
button:hover label {{ color: {selected_text}; }}
.flat {{ background: transparent; }}
.editor entry, .editor textview, .editor textview text {{ background: {surface}; color: {text}; caret-color: {accent}; }}
.notice, .editor link {{ color: {accent}; }}
popover > contents {{ background: {surface}; color: {text}; border-color: {border}; }}
.settings-shell {{ background: {background}; color: {text}; border-color: {border}; }}
.settings-tabs, .settings-footer {{ border-color: {border}; }}
.settings-tabs button, .settings-tabs button:checked {{ background: transparent; border-color: transparent; color: {muted}; }}
.settings-tabs button label {{ color: {muted}; }}
.settings-tabs button:hover {{ background: {surface}; }}
.settings-tabs button:hover label {{ color: {text}; }}
.settings-tabs button:checked {{ border-bottom-color: {accent}; }}
.settings-tabs button:checked label {{ color: {accent}; }}
.settings-tabs button:focus-visible {{ outline-color: {accent}; }}
.settings-tabs button:hover:not(:disabled), .settings-tabs button:focus-visible:not(:disabled) {{ border-color: transparent; border-bottom-color: {accent}; box-shadow: inset 0 -2px 12px alpha({accent}, 0.22); }}
.settings-tabs button:checked:not(:disabled) {{ box-shadow: inset 0 -2px 10px alpha({accent}, 0.18); }}
.settings-shell .window-mode:checked {{ background: {selection}; border-color: {accent}; }}
.settings-shell .window-mode:checked label {{ color: {selected_text}; }}
.settings-shell .window-mode:checked .subtitle {{ color: {selected_text}; opacity: 0.75; }}
.about-logo {{ color: #62A0EA; }}
.about-version {{ background: {raised}; color: {text}; }}
.about-description {{ color: {muted}; }}
.measure-tools {{ background: {background}; border-color: {border}; }}
"#
        ))
    }
}

fn hex(rgb: [u8; 3]) -> String {
    format!("#{:02X}{:02X}{:02X}", rgb[0], rgb[1], rgb[2])
}

fn blend(background: [u8; 3], foreground: [u8; 3], amount: f64) -> String {
    hex(std::array::from_fn(|i| {
        (background[i] as f64 * (1. - amount) + foreground[i] as f64 * amount).round() as u8
    }))
}

fn contrast(rgb: [u8; 3]) -> &'static str {
    let luminance: f64 = rgb
        .into_iter()
        .zip([0.2126, 0.7152, 0.0722])
        .map(|(value, weight)| {
            let value = value as f64 / 255.;
            weight
                * if value <= 0.04045 {
                    value / 12.92
                } else {
                    ((value + 0.055) / 1.055).powf(2.4)
                }
        })
        .sum();
    if luminance > 0.179 {
        "#15151C"
    } else {
        "#FFFFFF"
    }
}

pub fn panel(initial: Theme, apply: impl Fn(Theme) -> Result<(), String> + 'static) -> gtk::Box {
    let panel = gtk::Box::new(gtk::Orientation::Vertical, 8);
    panel.add_css_class("editor");
    let title = gtk::Label::new(Some("Theme & colors"));
    title.set_xalign(0.);
    title.add_css_class("item-title");
    panel.append(&title);
    let description = gtk::Label::new(Some(
        "Choose a preset or customize the colors, then apply your theme.",
    ));
    description.set_wrap(true);
    description.set_xalign(0.);
    description.add_css_class("subtitle");
    panel.append(&description);
    let presets = gtk::DropDown::from_strings(&["Dark", "Light", "Midnight", "Custom"]);
    presets.set_widget_name("theme-presets");
    presets.set_selected(
        (0..3)
            .find(|index| Theme::preset(*index) == initial)
            .unwrap_or(3),
    );
    panel.append(&presets);
    let entries = Rc::new(
        ["Background", "Text", "Accent", "Selection"]
            .into_iter()
            .zip(initial.values())
            .map(|(name, value)| {
                let row = gtk::Box::new(gtk::Orientation::Horizontal, 12);
                let label = gtk::Label::new(Some(name));
                label.set_xalign(0.);
                label.set_hexpand(true);
                row.append(&label);
                let entry = gtk::Entry::builder()
                    .text(value)
                    .width_chars(9)
                    .max_width_chars(9)
                    .build();
                entry.set_widget_name(&format!("theme-{}", name.to_ascii_lowercase()));
                entry.set_tooltip_text(Some("Hex color · #RRGGBB"));
                row.append(&entry);
                let picker = gtk::ColorDialogButton::new(Some(
                    gtk::ColorDialog::builder()
                        .title(format!("Choose {name} color"))
                        .with_alpha(false)
                        .build(),
                ));
                picker.set_tooltip_text(Some(&format!("Choose {name} color")));
                picker.set_widget_name(&format!("theme-{}-picker", name.to_ascii_lowercase()));
                picker.set_rgba(&gdk::RGBA::parse(value).unwrap());
                let weak_entry = entry.downgrade();
                picker.connect_rgba_notify(move |picker| {
                    if let Some(entry) = weak_entry.upgrade() {
                        let rgba = picker.rgba();
                        if let Ok(value) =
                            color::hex((rgba.red() as f64, rgba.green() as f64, rgba.blue() as f64))
                            && entry.text().as_str() != value
                        {
                            entry.set_text(&value);
                        }
                    }
                });
                let swatch = picker.clone();
                entry.connect_changed(move |entry| {
                    if color::rgb(entry.text().trim()).is_ok()
                        && let Ok(rgba) = gdk::RGBA::parse(entry.text().trim())
                        && swatch.rgba() != rgba
                    {
                        swatch.set_rgba(&rgba);
                    }
                });
                row.append(&picker);
                panel.append(&row);
                entry
            })
            .collect::<Vec<_>>(),
    );
    let preview = gtk::DrawingArea::builder()
        .content_width(420)
        .content_height(140)
        .build();
    let values = Rc::clone(&entries);
    preview.set_draw_func(move |_, context, width, height| {
        let Ok(theme) = Theme::from_entries(&values) else {
            return;
        };
        let set_color = |value: &str| {
            let [r, g, b] = color::rgb(value).unwrap();
            context.set_source_rgb(r as f64 / 255., g as f64 / 255., b as f64 / 255.);
        };
        set_color(&theme.background);
        let _ = context.paint();
        set_color(&theme.accent);
        context.rectangle(14., 16., 28., 28.);
        let _ = context.fill();
        set_color(&theme.text);
        context.set_font_size(17.);
        context.move_to(54., 36.);
        let _ = context.show_text("Search apps, files…");
        set_color(&theme.selection);
        context.rectangle(10., 60., width as f64 - 20., 40.);
        let _ = context.fill();
        set_color(contrast(color::rgb(&theme.selection).unwrap()));
        context.set_font_size(14.);
        context.move_to(24., 85.);
        let _ = context.show_text("Firefox");
        context.set_font_size(11.);
        context.move_to(width as f64 - 100., 85.);
        let _ = context.show_text("Application");
        set_color(&theme.text);
        context.set_font_size(14.);
        context.move_to(24., height as f64 - 25.);
        let _ = context.show_text("Documents");
    });
    panel.append(&preview);
    let updating = Rc::new(Cell::new(false));
    for entry in entries.iter() {
        let preview = preview.downgrade();
        let presets = presets.downgrade();
        let updating = Rc::clone(&updating);
        entry.connect_changed(move |_| {
            if let Some(preview) = preview.upgrade() {
                preview.queue_draw();
            }
            if !updating.get()
                && let Some(presets) = presets.upgrade()
            {
                presets.set_selected(3);
            }
        });
    }
    let values = Rc::clone(&entries);
    presets.connect_selected_notify(move |presets| {
        if presets.selected() < 3 {
            updating.set(true);
            for (entry, value) in values
                .iter()
                .zip(Theme::preset(presets.selected()).values())
            {
                entry.set_text(value);
            }
            updating.set(false);
        }
    });
    let status = gtk::Label::new(None);
    status.set_wrap(true);
    status.set_xalign(0.);
    status.set_widget_name("theme-status");
    let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
    let save = gtk::Button::with_label("Apply theme");
    save.add_css_class("accent");
    save.set_widget_name("theme-apply");
    let values = Rc::clone(&entries);
    let message = status.clone();
    save.connect_clicked(
        move |_| match Theme::from_entries(&values).and_then(&apply) {
            Ok(()) => message.set_text("Theme saved · used whenever Spotlight opens"),
            Err(error) => message.set_text(&error),
        },
    );
    buttons.append(&save);
    let reset = gtk::Button::with_label("Reset colors");
    reset.set_widget_name("theme-reset");
    reset.connect_clicked(move |_| {
        presets.set_selected(3);
        presets.set_selected(0);
    });
    buttons.append(&reset);
    panel.append(&buttons);
    panel.append(&status);
    panel
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn presets_and_saved_colors_are_safe_css() {
        for index in 0..3 {
            let theme = Theme::preset(index);
            assert!(theme.css().unwrap().contains(&theme.background));
            assert_eq!(
                serde_json::from_str::<Theme>(&serde_json::to_string(&theme).unwrap()).unwrap(),
                theme
            );
        }
        assert_eq!(
            serde_json::from_str::<Theme>("{}").unwrap(),
            Theme::default()
        );
        assert_eq!(
            serde_json::from_str::<crate::core::Store>("{}")
                .unwrap()
                .theme,
            Theme::default()
        );
        let invalid = Theme {
            accent: "red; } window { background: white".into(),
            ..Theme::default()
        };
        assert!(invalid.css().is_err());
        assert_eq!(contrast([255; 3]), "#15151C");
        assert_eq!(contrast([0; 3]), "#FFFFFF");
    }
}
