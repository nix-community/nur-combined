use serde_json::{Value, json};
use std::io::{BufRead, BufReader, Write};
use std::path::PathBuf;
use std::process::{Child, Command, Stdio};
use std::sync::mpsc::{self, Receiver};
use std::time::{Duration, Instant, SystemTime, UNIX_EPOCH};

pub struct Agent {
    child: Child,
    replies: Receiver<Value>,
    pub home: PathBuf,
    game: String,
    headless: bool,
}

impl Agent {
    pub fn new(game: &str, headless: bool) -> Self {
        let serial = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .unwrap()
            .as_nanos();
        let home = std::env::temp_dir().join(format!("hanga-test-{}-{serial}", std::process::id()));
        std::fs::create_dir_all(&home).unwrap();
        let (child, replies) = Self::launch(game, headless, &home);
        Self {
            child,
            replies,
            home,
            game: game.into(),
            headless,
        }
    }

    fn launch(game: &str, headless: bool, home: &PathBuf) -> (Child, Receiver<Value>) {
        let binary = std::env::var_os("HANGA_BIN")
            .map(PathBuf::from)
            .or_else(|| option_env!("CARGO_BIN_EXE_hanga").map(PathBuf::from))
            .unwrap_or_else(|| {
                std::env::current_exe()
                    .unwrap()
                    .parent()
                    .unwrap()
                    .join("hanga")
            });
        let mut cmd = Command::new(binary);
        cmd.args(["--agent-client", "--game", game])
            .env("HOME", home)
            .env("XDG_CONFIG_HOME", home.join("config"))
            .env("XDG_CACHE_HOME", home.join("cache"))
            .env("XDG_DATA_HOME", home.join("data"))
            .stdin(Stdio::piped())
            .stdout(Stdio::piped());
        if headless {
            cmd.arg("--headless");
        }
        let mut child = cmd.spawn().expect("spawn packaged Hanga");
        let stdout = child.stdout.take().unwrap();
        let (tx, replies) = mpsc::channel();
        std::thread::spawn(move || {
            for line in BufReader::new(stdout).lines().map_while(Result::ok) {
                if let Ok(value) = serde_json::from_str::<Value>(&line) {
                    if tx.send(value).is_err() {
                        break;
                    }
                }
            }
        });
        (child, replies)
    }

    pub fn send(&mut self, command: Value) {
        let input = self.child.stdin.as_mut().unwrap();
        writeln!(input, "{command}").unwrap();
        input.flush().unwrap();
    }

    pub fn look(&mut self) -> Value {
        self.request(json!({"action": "Look"}))
    }

    pub fn inspect(&mut self, pos: Value) -> Value {
        self.request(json!({"action": "InspectBlock", "pos": pos}))
    }

    fn request(&mut self, command: Value) -> Value {
        self.send(command);
        let reply = self
            .replies
            .recv_timeout(Duration::from_secs(60))
            .expect("Hanga must answer within a bounded time");
        assert_eq!(reply["status"], "ok");
        reply
    }

    pub fn wait_for(&mut self, predicate: impl Fn(&Value) -> bool) -> Value {
        let end = Instant::now() + Duration::from_secs(60);
        loop {
            let reply = self.look();
            if predicate(&reply) {
                return reply;
            }
            assert!(
                Instant::now() < end,
                "{} did not become playable: {reply}",
                self.game
            );
            std::thread::sleep(Duration::from_millis(100));
        }
    }

    pub fn restart(&mut self) {
        let _ = self.child.kill();
        self.child.wait().unwrap();
        let (child, replies) = Self::launch(&self.game, self.headless, &self.home);
        self.child = child;
        self.replies = replies;
    }
}

impl Drop for Agent {
    fn drop(&mut self) {
        let _ = self.child.kill();
        let _ = self.child.wait();
        let _ = std::fs::remove_dir_all(&self.home);
    }
}
