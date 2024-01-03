{
  fetchFromGitHub,
  nixfmt,
}:
nixfmt.overrideAttrs (finalAttrs: prevAttrs: {
  version = prevAttrs.version + "-rfc-2023-12-13";
  name = "${prevAttrs.pname}-${finalAttrs.version}";
  src = fetchFromGitHub {
    owner = "piegamesde";
    repo = "nixfmt";
    rev = "0a8c246723bdd16207bb03681614892fa1d2f9b5";
    hash = "sha256-vRhF9hE4P8rwcEtPYcEuoIHvCUiI+37OeHW/QRtnMQk=";
  };
})
