{
  lib,
  python3Packages,
  atomicparsley,
  deno,
  fetchFromGitHub,
  ffmpeg-headless,
  installShellFiles,
  pandoc,
  rtmpdump,
  atomicparsleySupport ? true,
  ffmpegSupport ? true,
  javascriptSupport ? true,
  rtmpSupport ? true,
  nix-update-script,
}:

python3Packages.buildPythonApplication rec {
  pname = "yt-dlp";
  version = "2026.02.04-unstable-2026-02-21";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "yt-dlp";
    repo = "yt-dlp";
    rev = "81bdea03f3414dd4d086610c970ec14e15bd3d36";
    hash = "sha256-ArfmE8j8wNAnUnPpVZoktYtUf+p21Sn+5okhdHQlyhs=";
  };

  postPatch = ''
    substituteInPlace yt_dlp/version.py \
      --replace-fail "UPDATE_HINT = None" 'UPDATE_HINT = "spotdemo4/nur likely already contain an updated version.\n       To get it run nix-channel --update or nix flake update in your config directory."'
    ${lib.optionalString javascriptSupport ''
      # deno is required for full YouTube support (since 2025.11.12).
      # This makes yt-dlp find deno even if it is used as a python dependency, i.e. in kodiPackages.sendtokodi.
      # Crafted so people can replace deno with one of the other JS runtimes.
      substituteInPlace yt_dlp/utils/_jsruntime.py \
        --replace-fail "path = _determine_runtime_path(self._path, '${deno.meta.mainProgram}')" "path = '${lib.getExe deno}'"
    ''}
  '';

  build-system = with python3Packages; [ hatchling ];

  nativeBuildInputs = [
    installShellFiles
    pandoc
  ];

  # expose optional-dependencies, but provide all features
  dependencies = lib.concatAttrValues optional-dependencies;

  optional-dependencies = {
    default =
      with python3Packages;
      [
        brotli
        certifi
        mutagen
        pycryptodomex
        requests
        urllib3
        websockets
      ]
      ++ [
        passthru.ejs # keep pinned version in sync!
      ];
    curl-cffi = [ python3Packages.curl-cffi ];
    secretstorage = with python3Packages; [
      cffi
      secretstorage
    ];
  };

  pythonRelaxDeps = [ "websockets" ];

  preBuild = ''
    python devscripts/make_lazy_extractors.py
  '';

  postBuild = ''
    python devscripts/prepare_manpage.py yt-dlp.1.temp.md
    pandoc -s -f markdown-smart -t man yt-dlp.1.temp.md -o yt-dlp.1
    rm yt-dlp.1.temp.md

    mkdir -p completions/{bash,fish,zsh}
    python devscripts/bash-completion.py completions/bash/yt-dlp
    python devscripts/zsh-completion.py completions/zsh/_yt-dlp
    python devscripts/fish-completion.py completions/fish/yt-dlp.fish
  '';

  # Ensure these utilities are available in $PATH:
  # - ffmpeg: post-processing & transcoding support
  # - rtmpdump: download files over RTMP
  # - atomicparsley: embedding thumbnails
  makeWrapperArgs =
    let
      packagesToBinPath =
        lib.optional atomicparsleySupport atomicparsley
        ++ lib.optional ffmpegSupport ffmpeg-headless
        ++ lib.optional rtmpSupport rtmpdump;
    in
    lib.optionals (packagesToBinPath != [ ]) [
      "--prefix"
      "PATH"
      ":"
      ''"${lib.makeBinPath packagesToBinPath}"''
    ];

  checkPhase = ''
    # Check for "unsupported" string in yt-dlp -v output.
    output=$($out/bin/yt-dlp -v 2>&1 || true)
    if echo $output | grep -q "unsupported"; then
      echo "ERROR: Found \"unsupported\" string in yt-dlp -v output."
      exit 1
    fi
  '';

  postInstall = ''
    installManPage yt-dlp.1

    installShellCompletion \
      --bash completions/bash/yt-dlp \
      --fish completions/fish/yt-dlp.fish \
      --zsh completions/zsh/_yt-dlp

    install -Dm644 Changelog.md README.md -t "$out/share/doc/yt_dlp"
  '';

  passthru = {
    ejs = python3Packages.callPackage ./ejs.nix { };
    updateScript = nix-update-script {
      extraArgs = [
        "--commit"
        "--version=branch=master"
        "${pname}"
      ];
    };
  };

  meta = {
    changelog = "https://github.com/yt-dlp/yt-dlp/commits/${src.rev}";
    description = "Feature-rich command-line audio/video downloader - master branch";
    homepage = "https://github.com/yt-dlp/yt-dlp/";
    license = lib.licenses.unlicense;
    mainProgram = "yt-dlp";
    platforms = lib.platforms.all;
  };
}
