{
  fetchFromGitHub,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "djot-tools";
  version = "0.19.1";

  src = fetchFromGitHub {
    owner = "wrvsrx";
    repo = "djot-tools";
    tag = finalAttrs.version;
    hash = "sha256-AzWlzEBDhW4vAB093wSnvahctJiLO+ns1157tyFsv/w=";
  };

  cargoHash = "sha256-7rxAfZTq6Fg1RkSrAu6f+zD8CsSwuAJ7RgAgH7dkkE4=";

  postInstall = ''
    mkdir -p $out/share/djot-tools
    cp -r skills $out/share/djot-tools/
  '';
})
