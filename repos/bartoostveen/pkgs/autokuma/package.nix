{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  pkg-config,
  openssl,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "autokuma";
  version = "2.1.0-rc.2";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "BigBoot";
    repo = "AutoKuma";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1vp4g1EZVFrx0HotnXx77MEUwA4bK61A1HnXtbjvjPs=";
  };

  cargoHash = "sha256-TG0RQ+SE/x4SKXFAzWQlu2377USyTPu5Z6oaZ9Omh9M=";

  patches = [
    ./no-doctest.patch
  ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  postInstall = ''
    mv $out/bin/crdgen $out/bin/autokuma-crdgen
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Utility that automates the creation of Uptime Kuma monitors";
    homepage = "https://github.com/BigBoot/AutoKuma";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bartoostveen ];
    mainProgram = "autokuma";
    platforms = lib.platforms.linux;
  };
})
