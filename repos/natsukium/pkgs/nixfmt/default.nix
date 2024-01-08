{
  fetchFromGitHub,
  nixfmt,
}:
nixfmt.overrideAttrs (finalAttrs: prevAttrs: {
  version = prevAttrs.version + "-rfc-2024-01-08";
  name = "${prevAttrs.pname}-${finalAttrs.version}";
  src = fetchFromGitHub {
    owner = "piegamesde";
    repo = "nixfmt";
    rev = "a273e5ae71bf74c4a53d1818fc2e2e6cc703bab4";
    hash = "sha256-z9FgYQuP0IG0bPJdtwrBbpf58z33nsqi1SMe98EHEBI=";
  };
})
