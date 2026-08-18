{ system }:
(builtins.getFlake
  "git+https://trev.zip/llc/trev-mono?rev=c0d1cac90b4cf1d532aa4a5ae5b563d66a3a3510" # v0.2.3
).packages."${system}".default
