{
  darwin,
  fetchFromGitHub,
  installShellFiles,
  lib,
  makeBinaryWrapper,
  nix-output-monitor,
  nix-update-script,
  nvd,
  rustPlatform,
  rustc,
  stdenv,
  version ? "3.6.0-0",
  hash ? "sha256-u6rTrvXRii4wm1qs1F0/IcRDLwfEcEDxC5YO5NkL8Gg=",
}:
let
  rustcMinor = lib.strings.toInt (builtins.elemAt (lib.strings.splitString "." rustc.version) 1);
  runtimeDeps = [
    nvd
    nix-output-monitor
  ];
  cargoHash =
    if rustcMinor > 83 then
      "sha256-tWo76Vksb6qqRkXgx3qN7XdvmNtyp29Zkc9x3CECGxE="
    else
      "sha256-uXc5R6ZSKUJMJ5JNphx7Hg5GqxrFi1tWPxnIYVJJ7Qo=";
in
rustPlatform.buildRustPackage {
  inherit version cargoHash;
  pname = "nh";

  src = fetchFromGitHub {
    owner = "ToyVo";
    repo = "nh";
    rev = "refs/tags/v${version}";
    inherit hash;
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.apple_sdk.frameworks.SystemConfiguration
  ];

  preFixup = ''
    installShellCompletion --cmd nh \
      --bash <("$out/bin/nh" completions --shell bash) \
      --zsh <("$out/bin/nh" completions --shell zsh) \
      --fish <("$out/bin/nh" completions --shell fish)
  '';

  postFixup = ''
    wrapProgram $out/bin/nh \
      --prefix PATH : ${lib.makeBinPath runtimeDeps}
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fork of nh with added support for nix-darwin and other features.";
    homepage = "https://github.com/ToyVo/nh";
    license = lib.licenses.eupl12;
    mainProgram = "nh";
    maintainers = [
      {
        name = "Collin Diekvoss";
        email = "Collin@Diekvoss.com";
        github = "toyvo";
        githubId = 5168912;
      }
    ];
  };
}
