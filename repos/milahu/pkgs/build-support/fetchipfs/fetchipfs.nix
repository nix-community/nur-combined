{ stdenv
, lib
, fetchurl
, curl
}:

{ ipfs
, url            ? ""
, curlOpts       ? ""
, outputHash     ? ""
, outputHashAlgo ? ""
, md5            ? ""
, sha1           ? ""
, sha256         ? ""
, sha512         ? ""
, meta           ? {}
, port           ? "8080"
, postFetch      ? ""
, preferLocalBuild ? true
# https://github.com/NixOS/nixpkgs/pull/136688
, useGetApi ? false # false -> use /api/v0/cat/get, true -> use /api/v0/get
, useFlatHash ? false # aka "isFile"
, gateways ? [
  # https://ipfs.github.io/public-gateway-checker/
  "ipfs.io"
  "gateway.ipfs.io"
  "dweb.link"
  "4everland.io"
  "ipfs.jpu.jp"
  "w3s.link"
  "konubinix.eu"
  "cf-ipfs.com"
  "nftstorage.link"
  "ipfs.runfission.com"
  "cloudflare-ipfs.com"
  "ipfs.eth.aragon.network"
  "gateway.pinata.cloud"
  "gw3.io"
  "ipfs.fleek.co"
  "dweb.eu.org"
  "permaweb.eu.org"
]
}:

let

  hasHash = (outputHash != "" && outputHashAlgo != "")
    || md5 != "" || sha1 != "" || sha256 != "" || sha512 != "";

in

if true then
fetchurl ({
  urls =
    #lib.traceValSeqN 2
    (builtins.map (g: "http://${g}/ipfs/${ipfs}") gateways)
  ;
} // (
  if outputHash != "" then { hash = outputHash; } else
  if sha256 != "" then { inherit sha256; } else
  if sha512 != "" then { inherit sha512; } else
  if sha1 != "" then { inherit sha1; } else
  if md5 != "" then { inherit md5; } else
  {}
))
else

#if (!hasHash) then throw "Specify hash for fetchipfs fixed-output derivation" else

stdenv.mkDerivation {
  name = ipfs;
  builder = ./builder.sh;
  nativeBuildInputs = [ curl ];

  # New-style output content requirements.
  outputHashAlgo =
    if !hasHash then "sha256" else
    if outputHashAlgo != "" then outputHashAlgo else
    if sha512 != "" then "sha512" else
    if sha256 != "" then "sha256" else
    if sha1 != "" then "sha1" else
    "md5"
  ;

  outputHash =
    if !hasHash then "" else
    if outputHash != "" then outputHash else
    if sha512 != "" then sha512 else
    if sha256 != "" then sha256 else
    if sha1 != "" then sha1 else
    md5
  ;

  outputHashMode = if useFlatHash then "flat" else "recursive";

  inherit curlOpts
          postFetch
          ipfs
          useGetApi
          url
          port
          meta;

  # Doing the download on a remote machine just duplicates network
  # traffic, so don't do that.
  inherit preferLocalBuild;
}
