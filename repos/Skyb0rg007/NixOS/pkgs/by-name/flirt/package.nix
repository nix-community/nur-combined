{
  lib,
  fetchFromForgejo,
  rustPlatform,
  installShellFiles,
  stdenv,
  nix-update-script,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "flirt";
  version = "0-unstable-2026-10-07";

  src = fetchFromForgejo {
    domain = "codeberg.org";
    owner = "flirt";
    repo = "flirt";
    rev = "a93a2d3632b1789e659fcbe503ecfe0e05597728";
    hash = "sha256-YHIERwCY5ThpA/OVs8v3v7tFHHNoNMCtw7IqdEoOnwE=";
  };

  cargoHash = "sha256-gK6bfjHqlvLfNS3k3u2gKAg9KV61zL6O4FeNaamYVO8=";

  nativeBuildInputs = [
    installShellFiles
  ];

  postPatch = ''
    substituteInPlace build.rs \
      --replace-fail 'include_str!(".git/HEAD")' '"${lib.substring 0 7 finalAttrs.src.rev}"'
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd flirt \
      --bash <($out/bin/flirt util completion bash) \
      --fish <($out/bin/flirt util completion fish) \
      --zsh <($out/bin/flirt util completion zsh)
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Review tool for patch series workflows";
    longDescription = ''
      Flirt is a review tool aimed at empowering users of the patch series
      workflow. It has three main features setting it apart from most other
      review tools:

      - It detects and shows the "interdiff" of a previously reviewed commit
        and its current version.

      - It's a local-first tool. It requires the network only to download
        things to review and to upload your review. The process of review
        itself happens offline and integrates with your existing tools, most
        notably your text editor.

      - It has support for multiple backends.
    '';
    license = lib.licenses.agpl3Plus;
    mainProgram = "flirt";
    homepage = "https://codeberg.org/flirt/flirt";
    maintainers = [ lib.maintainers.skyesoss ];
    platforms = lib.platforms.all;
  };
})
