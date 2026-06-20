{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-JUllOX3/fwA6zX/qQGHZM/sd4ov8zSprazEBP1VTT0o=";
  };

  cargoHash = "sha256-zzbnCkJJbh4Ag+x9KNIqHAA4l/WWAptBG5b4S3c8WcI=";
})
