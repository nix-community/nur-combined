{
  fetchFromGitHub,
  nixfmt,
}:
nixfmt.overrideAttrs (finalAttrs: prevAttrs: {
  version = prevAttrs.version + "-rfc-2024-01-04";
  name = "${prevAttrs.pname}-${finalAttrs.version}";
  src = fetchFromGitHub {
    owner = "piegamesde";
    repo = "nixfmt";
    rev = "35da23233a1cfd799d2b59cee056ece6dff06ea1";
    hash = "sha256-g6n0K5VsD0MitRXJ0mrspGP7R9VKJYNwJFZRmBop1Nw=";
  };
})
