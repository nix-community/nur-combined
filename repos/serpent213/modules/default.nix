{pkgs}: {
  pushlog =
    import (pkgs.fetchFromGitHub {
      owner = "serpent213";
      repo = "pushlog";
      rev = "v0.1.0";
      # Get hash with `nix-prefetch-url --unpack https://github.com/yourusername/your-tool/archive/v1.0.0.tar.gz`
      sha256 = "sha256:18jihyg5dqysm412chi4dfacfyrifr48cgf6qrfnsva8rjbw8s1l";
    }) {
      inherit (pkgs) python3Packages;
    };
}
