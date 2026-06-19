{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-RR5WoP/40/UJ/zthHotL4oHNywB83IMwXw0VtAlnq5s=";
  };

  cargoHash = "sha256-hY+B87IMsj6q8n7Qj/fnq/0g9UVAHVHjm2izhuGMkxk=";
})
