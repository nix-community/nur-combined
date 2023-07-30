{ rustPlatform
, fetchFromGitHub
, lib

, withJq ? true
, jq
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

, stdenv
, Foundation

, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  name = "yazi";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "sxyazi";
    repo = name;
    rev = "v${version}";
    hash = "sha256-0yMMYqZ/8WXPcXJuBflgJzaUn+/eIcWioR/aun2HOYo=";
  };

  postPatch =
    lib.optionalString withJq
      ''
        substituteInPlace src/core/external/jq.rs \
          --replace '"jq"' '"${jq}/bin/jq"'
      ''
    + lib.optionalString withUnar
      ''
        substituteInPlace src/core/external/lsar.rs \
          --replace '"lsar"' '"${unar}/bin/lsar"'
        substituteInPlace src/core/external/unar.rs \
          --replace '"unar"' '"${unar}/bin/unar"'
      ''
    + lib.optionalString withFfmpegthumbnailer
      ''
        substituteInPlace src/core/external/ffmpegthumbnailer.rs \
          --replace '"ffmpegthumbnailer"' '"${ffmpegthumbnailer}/bin/ffmpegthumbnailer"'
      ''
    + lib.optionalString withFd
      ''
        substituteInPlace src/core/external/fd.rs \
          --replace '"fd"' '"${fd}/bin/fd"'
      ''
    + lib.optionalString withRipgrep
      ''
        substituteInPlace src/core/external/rg.rs \
          --replace '"rg"' '"${ripgrep}/bin/rg"'
      ''
    + lib.optionalString withFzf
      ''
        substituteInPlace src/core/external/fzf.rs \
          --replace '"fzf"' '"${fzf}/bin/fzf"'
      ''
    + lib.optionalString withZoxide
      ''
        substituteInPlace src/core/external/zoxide.rs \
          --replace '"zoxide"' '"${zoxide}/bin/zoxide"'
      '';

  cargoHash = "sha256-HcNwoJtOns0Lj9A9CWJ2iOnUHIuPPzGemovobzMGQSA=";

  buildInputs = lib.optionals stdenv.isDarwin [ Foundation ];

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Blazing fast terminal file manager written in Rust, based on async I/O";
    homepage = "https://github.com/sxyazi/yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
