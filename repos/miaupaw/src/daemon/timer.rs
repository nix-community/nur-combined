use std::time::Instant;

/// Performance measurement utility.
/// Tracks elapsed time per stage
/// and prints to console in format: [+Total ms] (+Delta ms) | Event
pub struct Perf {
    start: Instant,
    last: Instant,
}

impl Perf {
    pub fn new() -> Self {
        let now = Instant::now();
        Self {
            start: now,
            last: now,
        }
    }

    /// Logs an event and updates the last checkpoint time.
    pub fn log(&mut self, msg: &str) {
        let now = Instant::now();
        let total = now.duration_since(self.start).as_millis();
        let delta = now.duration_since(self.last).as_millis();

        // Pretty-prints via the terminal logger.
        crate::core::terminal::log_step("Perf", &format!("{:>4}ms (+{:>3}ms) | {}", total, delta, msg));

        self.last = now;
    }
}

impl Default for Perf {
    fn default() -> Self {
        Self::new()
    }
}
