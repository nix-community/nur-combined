{ writeShellApplication

  # Dependencies
, just
}:

writeShellApplication {
  name = "just-local";

  runtimeInputs = [ just ];

  text = ''
    just --justfile '.local.justfile' "$@"
  '';
}
