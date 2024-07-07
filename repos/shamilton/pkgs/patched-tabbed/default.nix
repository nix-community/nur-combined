{ tabbed
, fetchFromGitHub
, libbsd
, zeromq
, nix-gitignore
}:
(tabbed.override {
  patches = [ ./keys.patch ];
}).overrideAttrs (old: {
  name = "tabbed-20180310-patched";
  src = fetchFromGitHub {
    owner = "SCOTT-HAMILTON";
    repo = "tabbed";
    rev = "0946c7766fa8639ebe8d81751ad43604572ac495";
    sha256 = "sha256-fZ8BCSWwraNAPlEwsu7srKzGdW2MYKxZfJkPm2Y/26o=";
  };
  # src = nix-gitignore.gitignoreSource [ ] /home/scott/GIT/tabbed;
  buildInputs = (old.buildInputs or []) ++ [ libbsd zeromq ];
  # dontStrip = true;
})
