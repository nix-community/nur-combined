# credit to Nixpkgs' helix package for providing copy-pastable snippets for the mdbook+tree-sitter stuff
{
  lib,
  rustPlatform,
  fetchFromGitHub,
  fetchzip,
  steel,
  git,
  mdbook,
  makeWrapper,
  installShellFiles,
}:

let
  upstreamVersion = "25.07.1";
  upstreamSrc = fetchzip {
    url = "https://github.com/helix-editor/helix/releases/download/${upstreamVersion}/helix-${upstreamVersion}-source.tar.xz";
    hash = "sha256-Pj/lfcQXRWqBOTTWt6+Gk61F9F1UmeCYr+26hGdG974=";
    stripRoot = false;
  };
in
rustPlatform.buildRustPackage rec {
  pname = "helix-steel";
  version = "0-unstable-2026-02-03";
  outputs = [
    "out"
    "doc"
  ];

  src = fetchFromGitHub {
    owner = "mattwparas";
    repo = "helix";
    rev = "63fb23413a9710297cabb37d87f60b402329838f";
    hash = "sha256-6t8BKnLMdvkUqjcyC1F8UmfrJ9tBPJq2YoBCHxTrYSo=";
  };

  patches = [
    # Support mdbook 0.5.x: escape HTML tags in command descriptions
    ./mdbook-0.5-support.patch
  ];

  postPatch = ''
    # mdbook 0.5 uses asset hashing for CSS/JS files
    # Remove custom theme to use default mdbook theme with correct asset references
    rm -f book/theme/index.hbs
    # disable fetching grammars, but do build them
    sed -i -e '/fetch_grammars()/d' helix-term/build.rs
  '';

  nativeBuildInputs = [
    git
    mdbook
    makeWrapper
    installShellFiles
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "steel-core-0.7.0" = "sha256-QHLXHvV/VG+gehwFveaAhGUtaGOL+FJM7qlh+4L208w=";
    };
  };

  buildAndTestSubdir = "helix-term";
  buildFeatures = [
    "steel"
    "git"
  ];

  env = {
    HELIX_DEFAULT_RUNTIME = "${placeholder "out"}/lib/runtime";
  };

  # patch in upstream released grammars sources
  # sync languages.toml
  preBuild = ''
    cp -r ${upstreamSrc}/runtime/grammars/sources runtime/grammars
    chmod -R +w runtime/grammars
    cp ${upstreamSrc}/languages.toml .
  '';

  postBuild = ''
    mdbook build book -d ../book-html
  '';

  doCheck = false; # I don't want to build the tests when it's a draft PR

  postInstall = ''
    # not needed at runtime
    rm -rf runtime/grammars/sources

    mkdir -p $out/lib $doc/share/doc
    cp -r runtime $out/lib
    installShellCompletion contrib/completion/hx.{bash,fish,zsh}
    mkdir -p $out/share/{applications,icons/hicolor/256x256/apps}
    cp contrib/Helix.desktop $out/share/applications
    cp contrib/helix.png $out/share/icons/hicolor/256x256/apps
    cp -r ../book-html $doc/share/doc/$name

    wrapProgram $out/bin/hx \
      --prefix PATH : "${lib.makeBinPath [ steel ]}"
  '';

  meta = {
    description = "A post-modern modal text editor";
    homepage = "https://github.com/mattwparas/helix";
    changelog = "https://github.com/mattwparas/helix/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "helix-steel";
  };
}
