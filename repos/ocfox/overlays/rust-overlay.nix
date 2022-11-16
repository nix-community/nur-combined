let
  rust-overlay = (import (builtins.fetchGit {
    url = "https://github.com/oxalica/rust-overlay.git";
    rev = "fd76032706405b6abe09bff25ca7e28ac1fa0043";
  }));
in
[
  rust-overlay
  (self: super: {
    rustc = self.rust-bin.nightly.latest.default;
    cargo = self.rust-bin.nightly.latest.default;
  })
]
