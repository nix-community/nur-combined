{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-GWmhoFHjMNxuNfgY1zWeWPU7zauO82pBWukggezy7co=";
  };

  cargoHash = "sha256-EwLjms9NXm1B1xmwYUBgk8SaqabSjCoBs1kLfWyxBSg=";
})
