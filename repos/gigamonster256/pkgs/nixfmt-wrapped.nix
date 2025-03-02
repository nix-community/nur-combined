{
  writeShellApplication,
  fd,
  nixfmt-rfc-style,
}:
writeShellApplication {
  name = "nixfmt-wrapper";

  runtimeInputs = [
    fd
    nixfmt-rfc-style
  ];

  text = ''
    fd "$@" -t f -e nix -x nixfmt '{}'
  '';
}
