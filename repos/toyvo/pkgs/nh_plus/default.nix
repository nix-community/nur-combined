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
}:
let
  rustcMinor = lib.strings.toInt (builtins.elemAt (lib.strings.splitString "." rustc.version) 1);
  version = "3.6.0-0";
  runtimeDeps = [
    nvd
    nix-output-monitor
  ];
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "nh_plus";

  src = fetchFromGitHub {
    owner = "ToyVo";
    repo = "nh_plus";
    rev = "refs/tags/v${version}";
    hash = "sha256-u6rTrvXRii4wm1qs1F0/IcRDLwfEcEDxC5YO5NkL8Gg=";
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

  cargoHash = "sha256-U6ff8spNpAp50QcLVQzIB9zUOGkBbd5E5S4eFD5Cdgk=";

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fork of nh with added support for nix-darwin and other features.";
    homepage = "https://github.com/ToyVo/nh_plus";
    license = lib.licenses.eupl12;
    mainProgram = "nh";
    broken = rustcMinor < 80;
    maintainers = with lib.maintainers; [
      {
        name = "Collin Diekvoss";
        email = "Collin@Diekvoss.com";
        github = "toyvo";
        githubId = 5168912;
      }
    ];
  };
}
