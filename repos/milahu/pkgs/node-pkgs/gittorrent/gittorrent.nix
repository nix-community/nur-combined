{ lib
, stdenv
, fetchFromGitHub
, npmlock2nix
}:

npmlock2nix.build rec {
  pname = "gittorrent";
  version = "unstable-2023-09-07";

  # fix: Error: EACCES: permission denied, open 'ed25519.key'
  src = fetchFromGitHub {
    owner = "milahu";
    repo = "GitTorrent";
    rev = "416e8e1d2905899598b86ba7a4575f5db7536a38";
    hash = "sha256-dcKeYVYGyJzoIdCwFT3VBMWz8zms5ZnWov7OrVSFCk4=";
  };

  /*
  # https://github.com/dzdidi/GitTorrent/tree/update
  # Error: EACCES: permission denied, open 'ed25519.key'
  src = fetchFromGitHub {
    owner = "dzdidi";
    repo = "GitTorrent";
    rev = "bd147996829e2e130884109513e9354f902aa217";
    hash = "sha256-sEiXi5IA6RXR7cN2vMfGvKErMvAwZpq503FzeTPyR+s=";
  };

  # too old
  src = fetchFromGitHub {
    owner = "cjb";
    repo = "GitTorrent";
    rev = "7b25402100059692b7161f05a8a23e872bf1f3dc";
    hash = "sha256-sS4Lk4W5u0Mny8wxe/0AtOtA9Z4mZEyHnLg40Y7PvU8=";
  };
  */

  # there is nothing to build
  buildCommands = [ ];

  installPhase = ''
    cd ..
    mkdir -p $out/opt
    cp -r $sourceRoot $out/opt/gittorrent
    mkdir -p $out/bin
    ln -sr $out/opt/gittorrent/git-remote-gittorrent.js $out/bin/git-remote-gittorrent
    ln -sr $out/opt/gittorrent/gittorrentd.js $out/bin/gittorrentd
  '';

  node_modules_attrs = {

    # fix: error: path '/nix/store/ccc5plqjf5fc8dg7077azhm58is9q4yq-source.drv' is not valid
    # pkgs/development/tools/npmlock2nix/src/npmlock2nix/internal.nix
    # packageLockJson ? src + "/package-lock.json"
    # this works locally, but fails at update NUR in github CI
    # nix fails to parse the package version from the lockfile
    packageJson = ./package.json;
    packageLockJson = ./package-lock.json;

    symlinkNodeModules = true;
    githubSourceHashMap = {
      dzdidi.ut_gittorrent."38b17be0fd02c62d3574a8158e6fabe123852d23" = "sha256-cKuFv1ErmskatAt/Ja796ppnlTQz2KMcJnU3sL2wgNw=";
    };
  };

  meta = with lib; {
    description = "A decentralization of GitHub using BitTorrent and Bitcoin";
    homepage = "https://github.com/dzdidi/GitTorrent/tree/update";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
