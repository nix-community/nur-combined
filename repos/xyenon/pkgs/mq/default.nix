{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  nix-update-script,
  rustc,
}:

rustPlatform.buildRustPackage {
  pname = "mq";
  version = "0.1.5-unstable-2025-05-14";

  src = fetchFromGitHub {
    owner = "harehare";
    repo = "mq";
    rev = "f91c2c054f6189255410151d873113fe4f320bff";
    hash = "sha256-NxoRkhZy44cuxeOI9Yp5pYse0P9RoFfIBD5268XQX88=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-YnGzLIB8psVeoWo4PFzJBqJp5j5DREmuprtc2g2++pk=";

  nativeBuildInputs = [ installShellFiles ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd mq \
      --bash <($out/bin/mq completion --shell bash) \
      --fish <($out/bin/mq completion --shell fish) \
      --zsh <($out/bin/mq completion --shell zsh)
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = with lib; {
    description = "Jq like markdown processing tool";
    homepage = "https://github.com/harehare/mq";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
    mainProgram = "mq";
    broken = versionOlder rustc.version "1.85.0";
  };
}
