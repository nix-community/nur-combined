{ system }:
(builtins.getFlake
  "git+https://trev.zip/llc/trev-mono?rev=915389e17959b6995a6df85bfdfbae0664c0591b" # v0.2.4
).packages."${system}".default
