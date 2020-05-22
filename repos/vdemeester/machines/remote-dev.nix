{
  imports = [
    ./base.nix
  ];
  profiles.dev = {
    go.enable = true;
    js.enable = true;
    rust.enable = true;
  };
  manual.manpages.enable = false;
}
