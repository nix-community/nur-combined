{
  lib,
  stdenv,
  rustPlatform,
  source,
  coreutils,
  installShellFiles,
  makeWrapper,
  which,
  procps,
  lsof,
  xdg-utils,
}:
rustPlatform.buildRustPackage rec {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  cargoHash = "sha256-EZ/CRVQjGB14HpBjKBRLW9Sj9In7Kp8754E5XiiQYX4=";

  patches = [./fix-download-url-in-data-test.patch];

  cargoBuildFlags = [
    "--package"
    "autocli"
  ];
  cargoTestFlags = ["--workspace"];
  doCheck = true;
  nativeCheckInputs = [
    coreutils
    which
  ];

  nativeBuildInputs =
    [installShellFiles]
    ++ lib.optionals stdenv.hostPlatform.isLinux [makeWrapper];

  postInstall = ''
    installShellCompletion --cmd autocli \
      --bash <($out/bin/autocli completion bash) \
      --zsh <($out/bin/autocli completion zsh) \
      --fish <($out/bin/autocli completion fish)

    install -Dm644 LICENSE NOTICE -t $out/share/doc/autocli
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/autocli \
      --prefix PATH : ${
      lib.makeBinPath [
        which
        procps
        lsof
        xdg-utils
      ]
    }
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/autocli --version | grep -F '${version}'
    $out/bin/autocli --help >/dev/null
    $out/bin/autocli hackernews --help >/dev/null

    test -f $out/share/bash-completion/completions/autocli.bash
    test -f $out/share/zsh/site-functions/_autocli
    test -f $out/share/fish/vendor_completions.d/autocli.fish
    test -f $out/share/doc/autocli/LICENSE
    test -f $out/share/doc/autocli/NOTICE

    runHook postInstallCheck
  '';

  meta = {
    description = "AutoCLI is a Blazing fast, memory-safe command-line tool — Fetch information from any website with a single command. Covers Twitter/X, Reddit, YouTube, HackerNews, Bilibili, Zhihu, Xiaohongshu, and 55+ sites, with support for controlling Electron desktop apps, integrating local CLI tools (gh, docker, kubectl), now powered by AutoCLI.ai";
    homepage = "https://github.com/nashsu/AutoCLI";
    changelog = "https://github.com/nashsu/AutoCLI/releases/tag/v${version}";
    license = lib.licenses.asl20;
    mainProgram = "autocli";
    maintainers = [
      {
        name = "mzwing";
      }
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
  };
}
