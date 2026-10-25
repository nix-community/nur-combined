use gtk::{gdk, gdk_pixbuf::Pixbuf, gio, glib, prelude::*};
use std::{cell::Cell, collections::HashMap, rc::Rc};

#[derive(Clone, Copy, Debug, PartialEq)]
pub struct Point {
    pub x: f64,
    pub y: f64,
}

#[derive(Clone, Copy, Debug)]
struct Viewport {
    scale: f64,
    x: f64,
    y: f64,
    width: f64,
    height: f64,
}

impl Viewport {
    fn new(width: f64, height: f64, image_width: f64, image_height: f64) -> Self {
        let scale = (width / image_width)
            .min(height / image_height)
            .max(f64::EPSILON);
        Self {
            scale,
            x: (width - image_width * scale) / 2.,
            y: (height - image_height * scale) / 2.,
            width: image_width,
            height: image_height,
        }
    }

    fn image_point(self, x: f64, y: f64) -> Point {
        Point {
            x: ((x - self.x) / self.scale).clamp(0., self.width).round(),
            y: ((y - self.y) / self.scale).clamp(0., self.height).round(),
        }
    }
}

pub fn dimensions(start: Point, end: Point) -> (f64, f64, f64) {
    let width = (end.x - start.x).abs();
    let height = (end.y - start.y).abs();
    (width, height, width.hypot(height))
}

pub fn text(start: Point, end: Point) -> String {
    let (width, height, distance) = dimensions(start, end);
    format!("{width:.0} × {height:.0} px · distance {distance:.1} px")
}

pub fn response(value: &glib::Variant) -> Result<Option<Pixbuf>, String> {
    let (status, values) = value
        .get::<(u32, HashMap<String, glib::Variant>)>()
        .ok_or("Invalid screenshot response")?;
    match status {
        0 => {
            let uri = values
                .get("uri")
                .and_then(|v| v.str())
                .ok_or("The desktop returned no screenshot")?;
            let file = gio::File::for_uri(uri);
            let path = file
                .path()
                .ok_or("The desktop returned a non-local screenshot")?;
            let image =
                Pixbuf::from_file(path).map_err(|e| format!("Could not load the screenshot: {e}"));
            // The portal creates this temporary capture for this request only.
            let _ = file.delete(None::<&gio::Cancellable>);
            image.map(Some)
        }
        1 => Ok(None),
        _ => Err("Screen measurement needs a working desktop screenshot portal".into()),
    }
}

#[derive(Clone)]
pub struct Ruler {
    pub window: gtk::Window,
    pub area: gtk::DrawingArea,
    pub drag: gtk::GestureDrag,
    pub copy: gtk::Button,
    pub readout: gtk::Label,
}

pub fn open(parent: &gtk::ApplicationWindow, image: Pixbuf) -> Ruler {
    let window = gtk::Window::builder()
        .application(&parent.application().expect("Application"))
        .title("Spotlight Screen Measurement")
        .decorated(false)
        .build();
    window.add_css_class("screen-measure");
    let overlay = gtk::Overlay::new();
    let area = gtk::DrawingArea::builder()
        .hexpand(true)
        .vexpand(true)
        .build();
    area.set_cursor_from_name(Some("crosshair"));
    overlay.set_child(Some(&area));
    let tools = gtk::Box::new(gtk::Orientation::Vertical, 8);
    tools.add_css_class("measure-tools");
    tools.set_halign(gtk::Align::Center);
    tools.set_valign(gtk::Align::Start);
    tools.set_margin_top(18);
    let heading = gtk::Label::new(Some("Screen Measurement"));
    heading.add_css_class("item-title");
    tools.append(&heading);
    let readout = gtk::Label::new(Some("Drag between two points to measure"));
    readout.set_selectable(false);
    tools.append(&readout);
    let instructions = gtk::Label::new(Some(
        "Screenshot pixels · Ctrl+C copies · Tab hides controls · Esc closes",
    ));
    instructions.add_css_class("subtitle");
    tools.append(&instructions);
    let buttons = gtk::Box::new(gtk::Orientation::Horizontal, 8);
    buttons.set_halign(gtk::Align::Center);
    let copy = gtk::Button::with_label("Copy Measurement");
    copy.set_sensitive(false);
    let done = gtk::Button::with_label("Done");
    buttons.append(&copy);
    buttons.append(&done);
    tools.append(&buttons);
    overlay.add_overlay(&tools);
    window.set_child(Some(&overlay));

    let size = (image.width() as f64, image.height() as f64);
    let selection = Rc::new(Cell::new(None::<(Point, Point)>));
    let drawing_selection = Rc::clone(&selection);
    area.set_draw_func(move |_, cr, width, height| {
        use gdk::prelude::GdkCairoContextExt;
        let view = Viewport::new(width as f64, height as f64, size.0, size.1);
        cr.set_source_rgb(0.06, 0.06, 0.08);
        let _ = cr.paint();
        let _ = cr.save();
        cr.translate(view.x, view.y);
        cr.scale(view.scale, view.scale);
        cr.set_source_pixbuf(&image, 0., 0.);
        let _ = cr.paint();
        let _ = cr.restore();
        if let Some((start, end)) = drawing_selection.get() {
            let sx = view.x + start.x * view.scale;
            let sy = view.y + start.y * view.scale;
            let ex = view.x + end.x * view.scale;
            let ey = view.y + end.y * view.scale;
            cr.set_source_rgba(0.93, 0.30, 0.38, 0.14);
            cr.rectangle(sx.min(ex), sy.min(ey), (ex - sx).abs(), (ey - sy).abs());
            let _ = cr.fill();
            // Dark outline keeps the ruler visible on light backgrounds.
            for (line_width, color) in [(4., (0.08, 0.08, 0.10)), (2., (1., 0.36, 0.43))] {
                cr.set_line_width(line_width);
                cr.set_source_rgb(color.0, color.1, color.2);
                cr.rectangle(sx.min(ex), sy.min(ey), (ex - sx).abs(), (ey - sy).abs());
                cr.move_to(sx, sy);
                cr.line_to(ex, ey);
                let _ = cr.stroke();
                for (x, y) in [(sx, sy), (ex, ey)] {
                    cr.move_to(x - 7., y);
                    cr.line_to(x + 7., y);
                    cr.move_to(x, y - 7.);
                    cr.line_to(x, y + 7.);
                }
                let _ = cr.stroke();
            }
        }
    });

    let drag = gtk::GestureDrag::new();
    drag.set_button(1);
    let origin = Rc::new(Cell::new((0., 0.)));
    let start_origin = Rc::clone(&origin);
    let start_selection = Rc::clone(&selection);
    let weak_area = area.downgrade();
    let label = readout.clone();
    let copy_button = copy.clone();
    drag.connect_drag_begin(move |_, x, y| {
        let Some(area) = weak_area.upgrade() else {
            return;
        };
        start_origin.set((x, y));
        let view = Viewport::new(area.width() as f64, area.height() as f64, size.0, size.1);
        let point = view.image_point(x, y);
        start_selection.set(Some((point, point)));
        copy_button.set_sensitive(false);
        label.set_text(&text(point, point));
        area.queue_draw();
    });
    for signal in ["drag-update", "drag-end"] {
        let origin = Rc::clone(&origin);
        let selection = Rc::clone(&selection);
        let weak_area = area.downgrade();
        let label = readout.clone();
        let copy_button = copy.clone();
        drag.connect_local(signal, false, move |args| {
            let area = weak_area.upgrade()?;
            let (Some((start, _)), Ok(dx), Ok(dy)) =
                (selection.get(), args[1].get::<f64>(), args[2].get::<f64>())
            else {
                return None;
            };
            let view = Viewport::new(area.width() as f64, area.height() as f64, size.0, size.1);
            let (x, y) = origin.get();
            let end = view.image_point(x + dx, y + dy);
            selection.set(Some((start, end)));
            label.set_text(&text(start, end));
            copy_button.set_sensitive(start != end);
            area.queue_draw();
            None
        });
    }
    area.add_controller(drag.clone());
    let copy_selection = Rc::clone(&selection);
    copy.connect_clicked(move |button| {
        if let Some((start, end)) = copy_selection.get() {
            button.clipboard().set_text(&text(start, end));
        }
    });
    let weak_window = window.downgrade();
    done.connect_clicked(move |_| {
        if let Some(window) = weak_window.upgrade() {
            window.close();
        }
    });
    let keys = gtk::EventControllerKey::new();
    keys.set_propagation_phase(gtk::PropagationPhase::Capture);
    let weak_window = window.downgrade();
    let copy_button = copy.clone();
    let controls = tools.clone();
    keys.connect_key_pressed(move |_, key, _, mods| {
        if key == gdk::Key::Tab {
            controls.set_visible(!controls.is_visible());
            return glib::Propagation::Stop;
        }
        if key == gdk::Key::Escape {
            if let Some(window) = weak_window.upgrade() {
                window.close();
            }
            return glib::Propagation::Stop;
        }
        if mods.contains(gdk::ModifierType::CONTROL_MASK)
            && matches!(key, gdk::Key::c | gdk::Key::C)
        {
            if copy_button.is_sensitive() {
                copy_button.emit_clicked();
            }
            return glib::Propagation::Stop;
        }
        glib::Propagation::Proceed
    });
    window.add_controller(keys);
    if let Some(monitor) = parent
        .surface()
        .and_then(|s| gtk::prelude::WidgetExt::display(parent).monitor_at_surface(&s))
    {
        window.fullscreen_on_monitor(&monitor);
    } else {
        window.fullscreen();
    }
    Ruler {
        window,
        area,
        drag,
        copy,
        readout,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn measures_both_directions_and_straight_lines() {
        let start = Point { x: 10., y: 20. };
        let end = Point { x: 310., y: 420. };
        assert_eq!(dimensions(start, end), (300., 400., 500.));
        assert_eq!(dimensions(end, start), (300., 400., 500.));
        assert_eq!(
            dimensions(start, Point { x: 310., y: 20. }),
            (300., 0., 300.)
        );
        assert_eq!(text(start, end), "300 × 400 px · distance 500.0 px");
    }

    #[test]
    fn converts_scaled_and_letterboxed_coordinates_to_image_pixels() {
        let view = Viewport::new(1000., 800., 2000., 1000.);
        assert_eq!(view.image_point(250., 250.), Point { x: 500., y: 200. });
        assert_eq!(view.image_point(-50., 10.), Point { x: 0., y: 0. });
        assert_eq!(view.image_point(1200., 900.), Point { x: 2000., y: 1000. });
        let hidpi = Viewport::new(1920., 1080., 3840., 2160.);
        assert_eq!(hidpi.image_point(300., 400.), Point { x: 600., y: 800. });
    }

    #[test]
    fn portal_cancellation_and_errors_are_handled() {
        let values = HashMap::<String, glib::Variant>::new();
        assert!(
            response(&(1u32, values.clone()).to_variant())
                .unwrap()
                .is_none()
        );
        assert!(response(&(2u32, values.clone()).to_variant()).is_err());
        assert!(response(&(0u32, values).to_variant()).is_err());
        assert!(response(&"invalid".to_variant()).is_err());
    }
}
