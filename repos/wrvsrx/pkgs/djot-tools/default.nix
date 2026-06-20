{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-language-server";
    tag = finalAttrs.version;
    hash = "sha256-MaahojGiBbBTLj1IjHGQIYd3WmBqohwOgB9nO9l1pxU=";
  };

  cargoHash = "sha256-xHERDgJcdoWUMVB6XDENjo1kDXAhah7cACKIZ2tAUb8=";
})
