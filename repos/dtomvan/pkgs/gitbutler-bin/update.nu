#!/usr/bin/env nix-shell
#!nix-shell -i nu -p nushell nix-prefetch gnused gnutar curl

const gitbutler_dir = path self | path dirname

def setKV [key: string, value: string] {
    sed -i $'s|($key) = ".*"|($key) = "($value)"|' $'($gitbutler_dir)/package.nix'
}

cd (mktemp -d)
let releases = http get https://app.gitbutler.com/releases/release/
let meta = $releases.platforms."linux-x86_64"

curl -fSLo tarball.tar.gz $meta.url
mkdir extracted
tar -xzvf tarball.tar.gz -C extracted

setKV version $releases.version
setKV url $meta.url
setKV hash (nix hash path extracted)
