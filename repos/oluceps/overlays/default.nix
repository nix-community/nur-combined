# Add your overlays here
#
# my-overlay = import ./my-overlay;
let
  rust-overlay = (import (builtins.fetchGit {
    url = "https://github.com/oxalica/rust-overlay.git";
    rev = "e10213240f9cb80091d50a898aa3758c5f4bfeeb";
  }));
in
[
  rust-overlay
  (self: super: {
    rustc = self.rust-bin.nightly.latest.default;
    cargo = self.rust-bin.nightly.latest.default;
  })
]
