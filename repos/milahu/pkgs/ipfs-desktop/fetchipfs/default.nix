{ stdenv
, curl
}:

{ ipfs
, get ? false # get=false -> use /api/v0/cat/get, get=true -> use /api/v0/get
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
}:

# curl -X POST "http://localhost:5001/api/v0/tar/cat?arg=bafybeiflkjt66aetfgcrgvv75izymd5kc47g6luepqmfq6zsf5w6ueth6y" --verbose 
# *   Trying ::1:5001...
# * connect to ::1 port 5001 failed: Connection refused
# *   Trying 127.0.0.1:5001...
# * Connected to localhost (127.0.0.1) port 5001 (#0)
# > POST /api/v0/tar/cat?arg=bafybeiflkjt66aetfgcrgvv75izymd5kc47g6luepqmfq6zsf5w6ueth6y HTTP/1.1
# > Host: localhost:5001
# > User-Agent: curl/7.76.1
# > Accept: */*
# > 
# * Mark bundle as not supporting multiuse
# < HTTP/1.1 500 Internal Server Error
# < Access-Control-Allow-Headers: X-Stream-Output, X-Chunked-Output, X-Content-Length
# < Access-Control-Expose-Headers: X-Stream-Output, X-Chunked-Output, X-Content-Length
# < Content-Type: application/json
# < Server: go-ipfs/0.9.1
# < Trailer: X-Stream-Error
# < Vary: Origin
# < Date: Sat, 04 Sep 2021 11:29:56 GMT
# < Transfer-Encoding: chunked
# < 
# {"Message":"not an IPFS tarchive","Code":0,"Type":"error"}
# * Connection #0 to host localhost left intact

assert sha512 != "" -> builtins.compareVersions "1.11" builtins.nixVersion <= 0;

let

  hasHash = (outputHash != "" && outputHashAlgo != "")
    || md5 != "" || sha1 != "" || sha256 != "" || sha512 != "";

in

if (!hasHash)
then throw "Specify sha for fetchipfs fixed-output derivation"
else stdenv.mkDerivation {
  name = ipfs;
  builder = ./builder.sh;
  nativeBuildInputs = [ curl ];

  # New-style output content requirements.
  outputHashAlgo = if outputHashAlgo != "" then outputHashAlgo else
      if sha512 != "" then "sha512" else if sha256 != "" then "sha256" else if sha1 != "" then "sha1" else "md5";
  outputHash = if outputHash != "" then outputHash else
      if sha512 != "" then sha512 else if sha256 != "" then sha256 else if sha1 != "" then sha1 else md5;

  outputHashMode = "recursive"; # single file: sha256 is NOT the sha256 of the file
  #outputHashMode = "flat"; # useful for single files: sha256 is the sha256 of the file
  # https://nixos.wiki/wiki/Nix_Hash#What_exactly_is_hashed
  /* https://nixos.org/manual/nix/stable/#sec-advanced-attributes

    outputHashMode = "flat"
      The output must be a non-executable regular file. If it isn’t, the build fails. The hash is simply computed over the contents of that file (so it’s equal to what Unix commands like sha256sum or sha1sum produce).
      This is the default.

    outputHashMode = "recursive"
      The hash is computed over the NAR archive dump of the output
      (i.e., the result of nix-store --dump).
      In this case, the output can be anything, including a directory tree.
  */

  inherit curlOpts
          postFetch
          ipfs
          get
          url
          port
          meta;

  # Doing the download on a remote machine just duplicates network
  # traffic, so don't do that.
  inherit preferLocalBuild;
}
