# Resolve a Go toolchain from a go.mod or go.work file, or from an explicit
# release version.
#
# This mirrors `rust-bin.fromRustupToolchainFile` and `rust-bin.fromRustcRev`
# from oxalica/rust-overlay: the requested version is matched against the
# tracked release database, and nothing is downloaded during evaluation.
# Unknown or unreproducible toolchains fail loudly instead of silently
# building with a different one.
{
  lib,
  versions,
  hashes,
  mkToolchain,
}:

let
  inherit (builtins)
    compareVersions
    concatStringsSep
    convertHash
    elemAt
    head
    isString
    length
    match
    readFile
    split
    ;

  # versions.json also carries a "next" key for prereleases.
  tracked = removeAttrs versions [ "next" ];

  trackedMinors = concatStringsSep ", " (lib.attrNames tracked);

  # `go1.25.3` and `go1.28rc1` are toolchains we can supply. `go1.25.3+custom`
  # and bare custom names refer to something installed on the machine, which
  # this overlay cannot reproduce.
  standardToolchain = "go1\\.[0-9]+(\\.[0-9]+)?((rc|beta)[0-9]+)?";

  atOrNull = list: index: if length list > index then elemAt list index else null;

  minorOf = version: atOrNull (match "([0-9]+\\.[0-9]+).*" version) 0;

  # Hashes may be SRI, or the bare `sha256` hex value that https://go.dev/dl/
  # publishes, so a hash can be copied from the download page without a
  # conversion step.
  normalizeHash =
    hash:
    if match "[0-9a-fA-F]{64}" hash != null then
      convertHash {
        hash = "sha256:${hash}";
        toHashFormat = "sri";
      }
    else
      hash;

  # go.mod is line oriented: one directive per line, `//` starts a comment,
  # and `directive ( ... )` blocks wrap several directives. Only the first
  # occurrence of a directive counts; `go` rejects duplicates anyway.
  parseLine =
    line:
    let
      tokens = lib.filter isString (split "[ \t]+" (lib.trim (head (split "//" line))));
      name = atOrNull tokens 0;
    in
    if name == null then
      null
    else
      {
        inherit name;
        value = atOrNull tokens 1;
      };

  parseDirectives =
    content:
    lib.foldl' (
      acc: line:
      let
        directive = parseLine line;
      in
      if directive == null || acc ? ${directive.name} then
        acc
      else
        acc // { ${directive.name} = directive.value; }
    ) { } (lib.filter isString (split "\n" content));

  parseToolchain =
    path: name:
    if match standardToolchain name == null then
      throw ''
        go-bin: ${toString path} selects toolchain `${name}`, which is not a standard Go toolchain.
        Only `toolchain goVERSION` can be resolved, for example `toolchain go1.25.3`.
        Remove the custom name or the `+suffix` from the toolchain directive.''
    else
      lib.removePrefix "go" name;

  throwUntracked =
    requested:
    throw ''
      go-bin: Go ${requested} is not a tracked release.
      Tracked minor versions: ${trackedMinors}.
      Either run `just update go-bin` to refresh pkgs/go-bin/versions.json, or
      pin the release and its hashes with pkgs.go-bin.fromGoRelease.'';
in
{
  # Read a go.mod (or go.work) file and return the matching toolchain.
  #
  # The `toolchain` directive wins when present, because it is what cmd/go
  # actually builds with. Otherwise the `go` directive states a minimum
  # version, and the newest tracked patch of that minor is used, which is what
  # Go itself does when a newer patch is installed.
  fromGoMod =
    path:
    let
      directives = parseDirectives (readFile path);

      requested =
        if directives ? toolchain then
          if directives.toolchain == null then
            throw "go-bin: ${toString path} has a malformed `toolchain` directive"
          else
            parseToolchain path directives.toolchain
        else if directives ? go && directives.go != null then
          directives.go
        else
          throw "go-bin: ${toString path} has no `go` or `toolchain` directive";

      minor = minorOf requested;
      latest = if minor == null then null else tracked.${minor} or null;
    in
    if hashes ? ${requested} then
      mkToolchain { version = requested; }
    else if latest == null then
      throwUntracked requested
    else if compareVersions latest requested < 0 then
      throw ''
        go-bin: ${toString path} requires Go ${requested}, but the newest tracked Go ${minor}.x is ${latest}.
        Run `just update go-bin` to refresh pkgs/go-bin/versions.json.''
    else
      mkToolchain { version = latest; };

  # Build any release published at https://go.dev/dl/, tracked or not, as long
  # as a hash is supplied for each platform that gets evaluated. This is the
  # escape hatch for releases the updater has not recorded yet, and for old
  # releases that dropped out of versions.json.
  #
  #   pkgs.go-bin.fromGoRelease {
  #     version = "1.26.9";
  #     hashes."linux-arm64" = "sha256-Spc3PUn8rNzzaU/qNopQCwDuPpY5dPPnUUEycXYy8FI=";
  #   }
  #
  # Platform keys are the same as in pkgs/go-bin/hashes.json: linux-amd64,
  # linux-arm64, darwin-amd64, darwin-arm64. A tracked version does not need
  # hashes, because the database already has them.
  fromGoRelease =
    {
      version,
      hashes ? { },
    }:
    let
      release = lib.removePrefix "go" version;
    in
    if match "1\\.[0-9]+(\\.[0-9]+|(rc|beta)[0-9]+)" release == null then
      throw ''
        go-bin: `${version}` is not a Go release version.
        Expected a form like "1.26.9" or "1.28rc1", as published at https://go.dev/dl/.''
    else
      mkToolchain {
        version = release;
        hashes = lib.mapAttrs (_: normalizeHash) hashes;
      };
}
