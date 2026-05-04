/// Simple internal ANSI color engine for a beautiful terminal experience.
/// No extra dependencies, just pure escape codes.
pub enum Color {
    Red,
    Green,
    Yellow,
    Blue,
    Magenta,
    Cyan,
    White,
    Gray,
    Reset,
}

impl Color {
    pub fn as_str(&self) -> &'static str {
        match self {
            Color::Red => "\x1b[31m",
            Color::Green => "\x1b[32m",
            Color::Yellow => "\x1b[33m",
            Color::Blue => "\x1b[34m",
            Color::Magenta => "\x1b[35m",
            Color::Cyan => "\x1b[36m",
            Color::White => "\x1b[37m",
            Color::Gray => "\x1b[90m",
            Color::Reset => "\x1b[0m",
        }
    }

    pub fn rgb(r: u8, g: u8, b: u8) -> String {
        format!("\x1b[38;2;{};{};{}m", r, g, b)
    }

    pub fn bg_rgb(r: u8, g: u8, b: u8) -> String {
        format!("\x1b[48;2;{};{};{}m", r, g, b)
    }
}

pub trait Styled {
    fn style(self, color: Color) -> String;
    fn red(self) -> String;
    fn green(self) -> String;
    fn yellow(self) -> String;
    fn blue(self) -> String;
    fn magenta(self) -> String;
    fn cyan(self) -> String;
    fn gray(self) -> String;
    fn bold(self) -> String;
    fn rgb(self, r: u8, g: u8, b: u8) -> String;
    fn bg_rgb(self, r: u8, g: u8, b: u8) -> String;
}

impl<T: std::fmt::Display> Styled for T {
    fn style(self, color: Color) -> String {
        format!("{}{}{}", color.as_str(), self, Color::Reset.as_str())
    }

    fn red(self) -> String { self.style(Color::Red) }
    fn green(self) -> String { self.style(Color::Green) }
    fn yellow(self) -> String { self.style(Color::Yellow) }
    fn blue(self) -> String { self.style(Color::Blue) }
    fn magenta(self) -> String { self.style(Color::Magenta) }
    fn cyan(self) -> String { self.style(Color::Cyan) }
    fn gray(self) -> String { self.style(Color::Gray) }

    fn bold(self) -> String {
        format!("\x1b[1m{}\x1b[22m", self)
    }

    fn rgb(self, r: u8, g: u8, b: u8) -> String {
        format!("{}{}{}", Color::rgb(r, g, b), self, Color::Reset.as_str())
    }

    fn bg_rgb(self, r: u8, g: u8, b: u8) -> String {
        format!("{}{}{}", Color::bg_rgb(r, g, b), self, Color::Reset.as_str())
    }
}

/// Helper to print a luxury divider
pub fn print_divider() {
    println!("{}", "─".repeat(50).gray());
}

/// Helper for stylized logs
pub fn log_step(name: &str, msg: &str) {
    let tag = format!("[{: >10}]", name);
    println!("{} {}", tag.bold(), msg);
}

pub fn log_info(msg: &str) {
    let tag = format!("[{: >10}]", "Info");
    println!("{} {}", tag.cyan().bold(), msg);
}

pub fn log_warn(msg: &str) {
    let tag = format!("[{: >10}]", "Warning");
    println!("{} {}", tag.yellow().bold(), msg);
}

pub fn log_error(msg: &str) {
    let tag = format!("[{: >10}]", "Error");
    println!("{} {}", tag.red().bold(), msg);
}

pub fn log_success(name: &str, msg: &str) {
    let tag = format!("[{: >10}]", name);
    println!("{} {}", tag.green().bold(), msg);
}

/// Helper for plain logs (bold tag but no color)
pub fn log_plain(name: &str, msg: &str) {
    let tag = format!("[{: >10}]", name);
    println!("{} {}", tag.bold(), msg);
}

pub fn print_logo() {
    let instant = r#"
  __             __               __  
 |  |-----.-----|  |_.-----.-----|  |_
 |  |     |__ --|   _|  _  |     |   _|
 |__|__|__|_____|____|___._|__|__|____|"#;

    let eyedropper = r#"
  ______                __                                    
 |   ___|--.--.-----.--|  |----.-----.-----.-----.-----.----.
 |   ___|  |  |  -__|  _  |   _|  _  |  _  |  _  |  -__|   _|
 |______|___  |_____|_____|__| |_____|   __|   __|_____|__|  
        |_____|                      |__|  |__|"#;

    let tag = format!("[{: >10}]", "Hello");
    println!("{}", instant.trim_start_matches(['\n', '\r']).cyan().bold());
    println!("{}", eyedropper.trim_start_matches(['\n', '\r']).cyan().bold());
    println!("\n{} {} {}", tag.bold(), "Instant Eyedropper Reborn".green().bold(), env!("CARGO_PKG_VERSION").gray());
}
