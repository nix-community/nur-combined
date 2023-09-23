{ rustPlatform
, fetchFromGitHub
, lib

, makeWrapper
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
  version = "unstable-2023-09-23";

  src = fetchFromGitHub {
    owner = "sxyazi";
    repo = pname;
    rev = "ec261a2708b6638a03797a8071b25c4db359b065";
    hash = "sha256-s0zB/oGNZmzJfQ/781K9uDPhVveHsViY4ayzIdyFZow=";
  };

  cargoHash = "sha256-dT7DQ6ElYUEBQ0khfgx4QFOS27pjgxQldE8m+YBpZiI=";

  nativeBuildInputs = [ makeWrapper ];
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
    '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version" "branch" ]; };

  meta = with lib; {
    description = "Blazing fast terminal file manager written in Rust, based on async I/O";
    homepage = "https://github.com/sxyazi/yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
