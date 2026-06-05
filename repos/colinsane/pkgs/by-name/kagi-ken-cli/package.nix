# first-run/config:
# run `kagi-ken-cli help`; it prints:
# > Get your session token from https://kagi.com/settings/user_details
# > → Session Link → copy to clipboard → extract "token" parameter.
#
# use like:
# - `kagi-ken-cli search 'demo search' --token really_long_string_like_100_chars`
#
### judgements, limitations
# - `search` command outputs json listings
# - `summarize --url` just says "Failed to parse summary JSON response"
# - no other commands => no way to use natural language, e.g.
#
# meh, not worth using.
{
  fetchFromGitHub,
  fetchPnpmDeps,
  nix-update-script,
  lib,
  makeWrapper,
  nodejs,
  pnpm,
  pnpmConfigHook,
  stdenv,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kagi-ken-cli";
  version = "1.7.0";
  src = fetchFromGitHub {
    owner = "czottmann";
    repo = "kagi-ken-cli";
    rev = finalAttrs.version;
    hash = "sha256-qBLzraMLn0qTcHSIyor94+z7mbBzsudgT3b0MxD1M7g=";
  };

  # starting with kagi-ken-cli 1.7.0, the `kagi-ken` dependency actually pinned has an inner
  # package.json identifying itself as 1.3.0, but kagi-ken-cli's pnpm-lock.yaml mistakenly refers
  # to it as version 1.0.0.
  # >   specifiers in the lockfile don't match specifiers in package.json:
  # > * 1 dependencies are mismatched:
  # >   - kagi-ken (lockfile: github:czottmann/kagi-ken#1.0.0, manifest: github:czottmann/kagi-ken#1.3.0)
  postPatch = ''
    substituteInPlace pnpm-lock.yaml \
      --replace-fail 'kagi-ken#1.0.0' 'kagi-ken#1.3.0'
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname postPatch src version;
    inherit pnpm;
    # <https://nixos.org/manual/nixpkgs/stable/#javascript-pnpm-fetcherVersion-versionHistory>
    # latest version at time of writing is `3`, however anything past `1` fails fixupPhase.
    fetcherVersion = 1;
    hash = "sha256-gCQQw99D0nLOtflsEkag/9MJLKtYCWBboPdRGpmBK2Q=";
  };


  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm
    pnpmConfigHook
  ];

  # no build/install instructions; CLAUDE.md (or AGENTS.md) indicates you're supposed to run it from
  # PWD after `pnpm install`ing dependencies...
  # so, let's just copy the necessary parts of that environment to $out and manually wrap?
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/kagi-ken-cli
    cp -r {node_modules,package.json,src} $out/share/kagi-ken-cli

    makeWrapper ${nodejs}/bin/node $out/bin/kagi-ken-cli \
      --suffix NODE_PATH : $out/share/kagi-ken-cli/node_modules \
      --add-flags "$out/share/kagi-ken-cli/src/index.js"

    runHook postInstall
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };
  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/czottmann/kagi-ken-cli";
    description = "Unofficial CLI client for working with Kagi *without* API access";
    longDescription = ''
      A lightweight Node CLI wrapper around the kagi-ken package, providing
      command-line access to Kagi.com services using Kagi session tokens:

      - Search: Searches Kagi.com and returns structured JSON data matching
        Kagi's official search API schema
      - Summarizer: Uses Kagi's Summarizer to create summaries from URLs or text content

      Unlike the official Kagi API which requires API access, this CLI uses your
      existing Kagi session to access both search and summarization features.
      The CLI handles command-line parsing and authentication while the core
      kagi-ken package provides all the Kagi integration functionality.
    '';
    maintainer = with lib.maintainers; [ colinsane ];
  };
})
