{ system }:
(builtins.getFlake
  "git+https://trev.zip/llc/trev-mono?rev=1f63c59eed00f9cf6327c80bd9d89e75ad6c60d7" # v0.2.5
).packages."${system}".default
