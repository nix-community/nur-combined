use gpui::*;

#[derive(Clone, Copy)]
pub struct ChromeColors {
    pub bar: Rgba,
    pub active: Rgba,
    pub text: Rgba,
    pub border: Rgba,
    pub panel: Rgba,
    pub muted: Rgba,
    pub hover: Rgba,
    pub btn: Rgba,
}

pub fn chrome_colors(is_dark: bool) -> ChromeColors {
    if is_dark {
        ChromeColors {
            bar: rgb(0x2d2d2d),
            active: rgb(0x1e1e1e),
            text: rgb(0xffffff),
            border: rgb(0x000000),
            panel: rgb(0x2d2d2d),
            muted: rgb(0xaaaaaa),
            hover: rgb(0x555555),
            btn: rgb(0x444444),
        }
    } else {
        ChromeColors {
            bar: rgb(0xe0e0e0),
            active: rgb(0xffffff),
            text: rgb(0x000000),
            border: rgb(0xcccccc),
            panel: rgb(0xf0f0f0),
            muted: rgb(0x555555),
            hover: rgb(0xcccccc),
            btn: rgb(0xcccccc),
        }
    }
}
