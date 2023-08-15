{ rustPlatform
, fetchFromGitHub
, lib

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

, stdenv
, Foundation

, nix-update-script
}:

rustPlatform.buildRustPackage rec {
  pname = "yazi";
  version = "unstable-2023-08-15";

  src = fetchFromGitHub {
    owner = "sxyazi";
    repo = pname;
    rev = "d83b8027f954897e799a6f026c3278d65cb04741";
    hash = "sha256-xzCktGDifcdwipcCOyL9gqmLrOUt/hSDoHEtRlP4DC4=";
  };

  postPatch =
    lib.optionalString withFile
      ''
        substituteInPlace core/src/external/file.rs \
          --replace '"file"' '"${file}/bin/file"'
      ''
    + lib.optionalString withJq
      ''
        substituteInPlace core/src/external/jq.rs \
          --replace '"jq"' '"${jq}/bin/jq"'
      ''
    + lib.optionalString withPoppler
      ''
        substituteInPlace core/src/external/pdftoppm.rs \
          --replace '"pdftoppm"' '"${poppler_utils}/bin/pdftoppm"'
      ''
    + lib.optionalString withUnar
      ''
        substituteInPlace core/src/external/lsar.rs \
          --replace '"lsar"' '"${unar}/bin/lsar"'
        substituteInPlace core/src/external/unar.rs \
          --replace '"unar"' '"${unar}/bin/unar"'
      ''
    + lib.optionalString withFfmpegthumbnailer
      ''
        substituteInPlace core/src/external/ffmpegthumbnailer.rs \
          --replace '"ffmpegthumbnailer"' '"${ffmpegthumbnailer}/bin/ffmpegthumbnailer"'
      ''
    + lib.optionalString withFd
      ''
        substituteInPlace core/src/external/fd.rs \
          --replace '"fd"' '"${fd}/bin/fd"'
      ''
    + lib.optionalString withRipgrep
      ''
        substituteInPlace core/src/external/rg.rs \
          --replace '"rg"' '"${ripgrep}/bin/rg"'
      ''
    + lib.optionalString withFzf
      ''
        substituteInPlace core/src/external/fzf.rs \
          --replace '"fzf"' '"${fzf}/bin/fzf"'
      ''
    + lib.optionalString withZoxide
      ''
        substituteInPlace core/src/external/zoxide.rs \
          --replace '"zoxide"' '"${zoxide}/bin/zoxide"'
      '';

  cargoHash = "sha256-ER4O6DEK1/IcuCQEfxf8nzc7pbnlE/hRe1m5QrS6rr0=";

  buildInputs = lib.optionals stdenv.isDarwin [ Foundation ];

  passthru.updateScript = nix-update-script { extraArgs = [ "--version" "branch" ]; };

  meta = with lib; {
    description = "Blazing fast terminal file manager written in Rust, based on async I/O";
    homepage = "https://github.com/sxyazi/yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
