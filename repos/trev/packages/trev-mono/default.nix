{ system }:
(builtins.getFlake
  "git+https://trev.zip/llc/trev-mono?rev=e5dc69b0a51d30701cb4e38c2783bf0a0c07d195" # v0.2.2
).packages."${system}".default
