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

, unstableGitUpdater
}:

rustPlatform.buildRustPackage rec {
  pname = "yazi";
  version = "unstable-2023-08-15";

  src = fetchFromGitHub {
    owner = "sxyazi";
    repo = pname;
    rev = "8fd3d15918b9ebba127fe11cff38b1bb73393f60";
    hash = "sha256-Txqvo0i0Tv+wbeZhELs1csPjiW4JQXnosBynI/x9cM4=";
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

  cargoHash = "sha256-cIbBeWOW1ymufOgeA5olAqqRSS8VZnKRCOtv3d04VgU=";

  buildInputs = lib.optionals stdenv.isDarwin [ Foundation ];

  passthru.updateScript = unstableGitUpdater { };

  meta = with lib; {
    description = "Blazing fast terminal file manager written in Rust, based on async I/O";
    homepage = "https://github.com/sxyazi/yazi";
    license = licenses.mit;
    maintainers = with maintainers; [ xyenon ];
  };
}
