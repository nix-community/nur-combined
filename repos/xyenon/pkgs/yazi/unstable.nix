{ rustPlatform
, fetchFromGitHub
, lib

, makeWrapper
, installShellFiles
, stdenv
, Foundation

, withFile ? true
, file
, withJq ? true
, jq
, withPoppler ? true
, poppler_utils
, withUnar ? true
, unar
, withFfmpegthumbnailer ? true
, ffmpegthumbnailer
, withFd ? true
, fd
, withRipgrep ? true
, ripgrep
, withFzf ? true
, fzf
, withZoxide ? true
, zoxide

, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "yazi";
  version = "unstable-2023-10-21";

  src = fetchFromGitHub {
    owner = "sxyazi";
    repo = pname;
    rev = "283f9377f27202c9dc4496774b6b7866ca4b7677";
    hash = "sha256-FhKrq4N32uJRHGc0qRl+CIVNRW597jACcTFEgj8hiSE=";
  };

  cargoHash = "sha256-uLymQq8d3Mkb6s5vtmNDcYZBgSNtLYjTXs7kXNTyRhs=";

  nativeBuildInputs = [ makeWrapper installShellFiles ];
  buildInputs = lib.optionals stdenv.isDarwin [ Foundation ];

  postInstall = with lib;
    let
      runtimePaths = [ ]
        ++ optional withFile file
        ++ optional withJq jq
        ++ optional withPoppler poppler_utils
        ++ optional withUnar unar
        ++ optional withFfmpegthumbnailer ffmpegthumbnailer
        ++ optional withFd fd
        ++ optional withRipgrep ripgrep
        ++ optional withFzf fzf
        ++ optional withZoxide zoxide;
    in
    ''
      wrapProgram $out/bin/yazi \
         --prefix PATH : "${makeBinPath runtimePaths}"
      installShellCompletion --cmd yazi \
        --bash ./config/completions/yazi.bash \
        --fish ./config/completions/yazi.fish \
        --zsh  ./config/completions/_yazi
    '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version" "branch" ]; };

  meta = with lib; {
    description = "Blazing fast terminal file manager written in Rust, based on async I/O";
    homepage = "https://github.com/sxyazi/yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
