{ stdenv, callPackage, fetchFromGitHub, makeDesktopItem
, electron
, cacert, git, nix, nodejs, runCommand, stdenvNoCC, yarn
, strace
}:

let
  yarn2nixSrc = fetchFromGitHub {
    owner = "Profpatsch";
    repo = "yarn2nix";
    rev = "919012b32c705e57d90409fc2d9e5ba49e05b471";
    sha256 = "1f9gw31j7jvv6b2fk5h76qd9b78zsc9ac9hj23ws119zzxh6nbyd";
  };
  yarn2nix = import yarn2nixSrc { inherit nixpkgsPath; };
  yarn2nixLib = callPackage "${yarn2nixSrc}/nix-lib" { inherit yarn2nix; };

  baseName = "bitwarden-desktop";
  version = "1.14.0";
  baseSrc = fetchFromGitHub {
    owner = "bitwarden";
    repo = "desktop";
    fetchSubmodules = true;
    rev = "v${version}";
    sha256 = "09wxkpdhcsqslag59scpjd1jm54624n4zxnlnl9ig51cd9c54bw6";
  };

  # from fetchgit, ensures that Git package.json deps actually work
  gitCertAttrs = {
    GIT_SSL_CAINFO = "${cacert}/etc/ssl/certs/ca-bundle.crt";
    impureEnvVars = stdenvNoCC.lib.fetchers.proxyImpureEnvVars ++ [
      "GIT_PROXY_COMMAND" "SOCKS_SERVER"
    ];
  };

  yarnLock = stdenvNoCC.mkDerivation (gitCertAttrs // {
    name = "${baseName}-yarn-lock-${version}";
    src = baseSrc;
    nativeBuildInputs = [ git yarn ];

    buildPhase = ''yarn import'';
    installPhase = ''mkdir -p $out; mv yarn.lock $out'';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "0rn9xgyrrz7l7b68irb17idp4lgnyg65pn31zgfxy3km755qx2m7";
  });

  y2nDeps = stdenvNoCC.mkDerivation (gitCertAttrs // {
    name = "${baseName}-npm-deps-nix-${version}";
    src = yarnLock;

    buildPhase = ''
      # nix initialization necessary for nix-prefetch-git call in yarn2nix
      export NIX_DB_DIR=$TMPDIR
      export NIX_STATE_DIR=$TMPDIR
      export NIX_PATH=nixpkgs=$TMPDIR/barf.nix
      opts=(--option build-users-group "")
      ${nix.out}/bin/nix-store --init

      ${yarn2nix}/bin/yarn2nix yarn.lock > npm-deps.nix
    '';
    installPhase = ''mkdir -p $out; mv npm-deps.nix $out'';

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "0giw10n48avms65yqsc12pvfga9m5z0p1q64qx0f50l8xxf8l3ra";
  });

  y2nPackage = runCommand "${baseName}-npm-package-nix-${version}" {
    src = baseSrc;
  } ''
    cd $src; mkdir -p $out
    ${yarn2nix}/bin/yarn2nix --template package.json > $out/npm-package.nix
  '';

  node-bitwarden-desktop = yarn2nixLib.buildNodePackage (rec {
    key = { scope = ""; name = "bitwarden"; };
    inherit version;

    src = baseSrc;

    postPatch = ''
      cp ${yarnLock}/yarn.lock .
    '';
  } // yarn2nixLib.callTemplate "${y2nPackage}/npm-package.nix"
    (yarn2nixLib.buildNodeDeps (callPackage "${y2nDeps}/npm-deps.nix" { }))
  ) // { name = "${baseName}-${version}"; };

in stdenv.mkDerivation rec {
  name = "${baseName}-${version}";
  inherit version;

  src = node-bitwarden-desktop;

  nativeBuildInputs = [ nodejs ];

  postPatch = ''
    # deal with webpack not resolving webpack-cli properly
    substituteInPlace package.json \
      --replace 'webpack -' 'webpack-cli -'
  '';

    # npm run-script build
  buildPhase = ''
    ${strace}/bin/strace -fe trace=%process,%file -s 128 npm run-script build
  '';

  # desktopItem = makeDesktopItem {
  #   inherit name;
  # };

  meta = with stdenv.lib; {
    description =
      "A secure and free password manager for all of your devices";
    longDescription = ''
      Bitwarden is the easiest and safest way to store all of your logins and
      passwords while conveniently keeping them synced between all of your
      devices.

      Password theft is a serious problem. The websites and apps that you use
      are under attack every day. Security breaches occur and your passwords
      are stolen. When you reuse the same passwords across apps and websites
      hackers can easily access your email, bank, and other important
      accounts.

      Security experts recommend that you use a different, randomly generated
      password for every account that you create. But how do you manage all
      those passwords? Bitwarden makes it easy for you to create, store, and
      access your passwords.

      Bitwarden stores all of your logins in an encrypted vault that syncs
      across all of your devices. Since it's fully encrypted before it ever
      leaves your device, only you have access to your data. Not even the team
      at Bitwarden can read your data, even if we wanted to. Your data is
      sealed with AES-256 bit encryption, salted hashing, and PBKDF2 SHA-256.

      Bitwarden is 100% open source software. The source code for Bitwarden is
      hosted on GitHub and everyone is free to review, audit, and contribute
      to the Bitwarden codebase.
    '';
    homepage = "https://bitwarden.com/";
    downloadPage = "https://github.com/bitwarden/desktop";
    license = with licenses; gpl3;
    maintainers = with maintainers; [ bb010g ];
    platforms = platforms.unix;
    broken = true;
  };
}
