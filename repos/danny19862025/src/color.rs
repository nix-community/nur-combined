use gtk::glib;
use std::collections::HashMap;

pub fn hex(rgb: (f64, f64, f64)) -> Result<String, String> {
    let values = [rgb.0, rgb.1, rgb.2];
    if values
        .iter()
        .any(|v| !v.is_finite() || !(0.0..=1.0).contains(v))
    {
        return Err("The color picker returned an invalid color".into());
    }
    let [r, g, b] = values.map(|v| (v * 255.).round() as u8);
    Ok(format!("#{r:02X}{g:02X}{b:02X}"))
}

pub fn rgb(hex: &str) -> Result<[u8; 3], String> {
    let value = hex.strip_prefix('#').ok_or("Expected a #RRGGBB color")?;
    if value.len() != 6 || !value.bytes().all(|b| b.is_ascii_hexdigit()) {
        return Err("Expected a #RRGGBB color".into());
    }
    let value = u32::from_str_radix(value, 16).map_err(|_| "Invalid hex color")?;
    Ok([(value >> 16) as u8, (value >> 8) as u8, value as u8])
}

pub struct Format {
    pub name: &'static str,
    pub value: String,
}

fn number(value: f64) -> String {
    let value = if value.abs() < 0.0005 { 0. } else { value };
    format!("{value:.3}")
        .trim_end_matches('0')
        .trim_end_matches('.')
        .to_string()
}

pub fn formats(hex: &str) -> Result<Vec<Format>, String> {
    let [red, green, blue] = rgb(hex)?;
    let (r, g, b) = (red as f64 / 255., green as f64 / 255., blue as f64 / 255.);
    let max = r.max(g).max(b);
    let min = r.min(g).min(b);
    let delta = max - min;
    let hue = if delta == 0. {
        0.
    } else if max == r {
        60. * ((g - b) / delta).rem_euclid(6.)
    } else if max == g {
        60. * ((b - r) / delta + 2.)
    } else {
        60. * ((r - g) / delta + 4.)
    };
    let lightness = (max + min) / 2.;
    let saturation = if delta == 0. {
        0.
    } else {
        delta / (1. - (2. * lightness - 1.).abs())
    };
    let hsv_saturation = if max == 0. { 0. } else { delta / max };
    let (h, s, l) = (
        number(hue),
        number(saturation * 100.),
        number(lightness * 100.),
    );
    let hex = format!("#{red:02X}{green:02X}{blue:02X}");
    Ok(vec![
        Format {
            name: "HEX",
            value: hex.clone(),
        },
        Format {
            name: "HEX + alpha",
            value: format!("{hex}FF"),
        },
        Format {
            name: "RGB",
            value: format!("rgb({red}, {green}, {blue})"),
        },
        Format {
            name: "RGBA",
            value: format!("rgba({red}, {green}, {blue}, 1)"),
        },
        Format {
            name: "HSL",
            value: format!("hsl({h}, {s}%, {l}%)"),
        },
        Format {
            name: "HSLA",
            value: format!("hsla({h}, {s}%, {l}%, 1)"),
        },
        Format {
            name: "HSV / HSB",
            value: format!(
                "{h}°, {}%, {}%",
                number(hsv_saturation * 100.),
                number(max * 100.)
            ),
        },
    ])
}

pub fn response(value: &glib::Variant) -> Result<Option<String>, String> {
    let (status, values) = value
        .get::<(u32, HashMap<String, glib::Variant>)>()
        .ok_or("Invalid color picker response")?;
    match status {
        0 => hex(values
            .get("color")
            .and_then(|v| v.get::<(f64, f64, f64)>())
            .ok_or("The color picker returned no color")?)
        .map(Some),
        1 => Ok(None),
        _ => Err("Color picking is unavailable in this desktop session".into()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use gtk::prelude::*;

    #[test]
    fn formats_and_validates_portal_colors() {
        assert_eq!(hex((0., 0.5, 1.)).unwrap(), "#0080FF");
        assert_eq!(hex((1., 0., 0.)).unwrap(), "#FF0000");
        assert_eq!(hex((0., 0., 0.)).unwrap(), "#000000");
        assert!(hex((f64::NAN, 0., 0.)).is_err());
        assert!(hex((1.1, 0., 0.)).is_err());
        let mut values = HashMap::new();
        values.insert("color".to_string(), (1., 0., 0.).to_variant());
        assert_eq!(
            response(&(0u32, values.clone()).to_variant())
                .unwrap()
                .as_deref(),
            Some("#FF0000")
        );
        assert_eq!(
            response(&(1u32, values.clone()).to_variant()).unwrap(),
            None
        );
        assert!(response(&(2u32, values).to_variant()).is_err());
        assert!(response(&(0u32, HashMap::<String, glib::Variant>::new()).to_variant()).is_err());
    }

    #[test]
    fn converts_primary_colors_and_grayscale() {
        for (hex, hsl, hsv) in [
            ("#FF0000", "hsl(0, 100%, 50%)", "0°, 100%, 100%"),
            ("#00FF00", "hsl(120, 100%, 50%)", "120°, 100%, 100%"),
            ("#0000FF", "hsl(240, 100%, 50%)", "240°, 100%, 100%"),
            ("#FFFFFF", "hsl(0, 0%, 100%)", "0°, 0%, 100%"),
            ("#000000", "hsl(0, 0%, 0%)", "0°, 0%, 0%"),
            ("#808080", "hsl(0, 0%, 50.196%)", "0°, 0%, 50.196%"),
        ] {
            let values = formats(hex).unwrap();
            assert_eq!(values.iter().find(|v| v.name == "HSL").unwrap().value, hsl);
            assert_eq!(
                values.iter().find(|v| v.name == "HSV / HSB").unwrap().value,
                hsv
            );
            assert_eq!(values[1].value, format!("{hex}FF"));
        }
        let values = formats("#0080ff").unwrap();
        assert_eq!(values[0].value, "#0080FF");
        assert_eq!(values[2].value, "rgb(0, 128, 255)");
        assert_eq!(values[3].value, "rgba(0, 128, 255, 1)");
        assert_eq!(values[4].value, "hsl(209.882, 100%, 50%)");
        for value in ["red", "#12", "#GGGGGG", "#FFFFFFFF", "#😀😀"] {
            assert!(formats(value).is_err());
        }
    }
}
