{
  getForgejoFlake,
  system,
}:
(getForgejoFlake {
  url = "https://trev.zip/llc/trev-mono";
  rev = "826f051f3bf2822a24ad46fe2cfa082d05b950a8"; # v0.2.8
  hash = "sha256-OBVyHpKSqnE+TloFYGeERb8eHZN6NNmQxbfZZLqwzu0=";
}).packages."${system}".default
