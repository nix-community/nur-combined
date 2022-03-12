let
  rust-overlay = (import (builtins.fetchGit {
    url = "https://github.com/oxalica/rust-overlay.git";
    rev = "d453c844766d33c68812a7410b7ebebe350e795e";
  }));
in [
  rust-overlay
  (self: super: {
    rustc = self.rust-bin.nightly.latest.default;
    cargo = self.rust-bin.nightly.latest.default;
  })
]
