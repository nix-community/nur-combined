/*
based on
https://github.com/NixOS/nixpkgs/pull/217151
fetchTorrent: init

why fetchtorrent-aria?
because fetchtorrent does not show download progress every N seconds
because fetchtorrent does not allow to download only some files
*/

# FIXME aria2c has no manpage in nixpkgs
# https://aria2.github.io/manual/en/html/aria2c.html

{ lib
, stdenvNoCC
, fetchFromGitHub
, aria2
, cacert
, torrenttools
, jq
, unixtools
}:

{
  btih,
  #btmh, # TODO implement v2 torrent
  #torrentFile ? "", # TODO implement
  sha256 ? "",
  hash ? "",
  name ? "",
  file ? "", # single file -> flat hash
  files ? [], # one or more files -> recursive hash (default)
  singleFile ? false, # single file without file name # TODO implement
  trackers ? [],
  extraTrackers ? [],
  doUpload ? false,
  # https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-file-allocation
  # > If you are using newer file systems such as
  # > ext4 (with extents support), btrfs, xfs or NTFS(MinGW build only),
  # > falloc is your best choice. It allocates large(few GiB) files almost instantly.
  fileAllocation ? "falloc",
} @ attrs:

stdenvNoCC.mkDerivation rec {

  builder = ./builder.sh;

  # this is separate from builder.sh to make it easier to override
  ariaCommandFile = ./aria-command.sh;

  nativeBuildInputs = [
    aria2
    torrenttools
    jq
    unixtools.xxd
  ];

  files = attrs.files or (if (file != "") then [file] else []);
  name = attrs.name or (if (file != "") then (builtins.baseNameOf file) else "btih-${btih}");

  # TODO allow passing trackerslist as string
  trackerslistFile =
    if (trackers != [])
    then
    (builtins.writeFile "trackerslist.txt" (builtins.concatStringsSep "\n" trackers))
    else
    (fetchFromGitHub {
      # https://github.com/ngosang/trackerslist
      # using trackers by IP address
      # to avoid DNS blocking
      # to avoid DNS lookups to increase download speed
      owner = "ngosang";
      repo = "trackerslist";
      rev = "92ad8832eb62888764ceac85c787f269d7593d39"; # 2024-10-05
      hash = "sha256-67RcNLzckWKnNGPv7HBcX2773XjKzjAEwRV6eL+jikY=";
    }) + "/trackers_best_ip.txt"; # 16 trackers
    #}) + "/trackers_all_ip.txt"; # 97 trackers

  extraTrackerslistFile =
    if (extraTrackers != [])
    then
    (builtins.writeFile "trackerslist.txt" (builtins.concatStringsSep "\n" extraTrackers))
    else
    "";

  outputHashMode = if (singleFile == true || file != "") then "flat" else "recursive";
  outputHashAlgo = if (builtins.hasAttr "sha256" attrs) then "sha256" else builtins.head (builtins.split "[:-]" hash);
  outputHash = attrs.sha256 or (
    let hash2 = attrs.hash or (throw "sha256 or hash is required"); in
    if hash2 != "" then hash2 else (
        builtins.trace "warning: found empty hash, assuming '${lib.fakeHash}'"
      lib.fakeHash));

  inherit btih fileAllocation singleFile;

  caCertificate = "${cacert}/etc/ssl/certs/ca-bundle.crt";
  requestedFile = file;
  requestedFilesArray = lib.toShellVar "requestedFiles" files;
  passAsFile = [
    "requestedFilesArray"
  ];

  # todo: use impure envs for ports?
  listenPort = null; # use a random port
  dhtListenPort = null;
  summaryInterval = 10; # show progress every N seconds
  enableDHT = true;
}
