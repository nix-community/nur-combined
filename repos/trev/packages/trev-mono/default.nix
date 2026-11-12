{
  getForgejoFlake,
  system,
}:
(getForgejoFlake {
  url = "https://trev.zip/llc/trev-mono";
  rev = "dde2cca7a2cb25d38cbdeac0fb8d4d5652d549b8"; # v0.2.7
  hash = "sha256-I8joLsLp09qAAQtvv6VRzYd6JnOaVaFXuO6s2htd1os=";
}).packages."${system}".default
