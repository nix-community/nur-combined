{
  fetchFromGitHub,
  nixfmt,
}:
nixfmt.overrideAttrs (finalAttrs: prevAttrs: {
  version = prevAttrs.version + "-rfc-2024-01-10";
  name = "${prevAttrs.pname}-${finalAttrs.version}";
  src = fetchFromGitHub {
    owner = "piegamesde";
    repo = "nixfmt";
    rev = "82457ef5fc7b324d3cab4300af0ff7f854135cfa";
    hash = "sha256-yhnKT8z5FOTUb/1ZXaErmFHsv1oKg1aYQVLVUCzQWMA=";
  };
})
