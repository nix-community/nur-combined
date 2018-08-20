{ stdenv, fetchurl, kubectl }:

let
  isLinux = stdenv.isLinux;
  arch = if isLinux
         then "linux-amd64"
         else "darwin-amd64";
  checksum = if isLinux
             then "1zig6ihmxcaw2wsbdd85yf1zswqcifw0hvbp1zws7r5ihd4yv8hg"
             else "1l8y9i8vhibhwbn5kn5qp722q4dcx464kymlzy2bkmhiqbxnnkkw";
  pname = "helm";
in

stdenv.mkDerivation rec {
  name = "${pname}-${version}";
  inherit (meta) version;

  src = fetchurl {
    url = "https://kubernetes-helm.storage.googleapis.com/helm-v${version}-${arch}.tar.gz";
    sha256 = checksum;
  };

  preferLocalBuild = true;

  buildInputs = [ ];

  propagatedBuildInputs = [ kubectl ];

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    mkdir -p $out/bin
  '';

  installPhase = ''
    tar -xvzf $src
    cp ${arch}/helm $out/bin/${pname}
    chmod +x $out/bin/${pname}
    mkdir -p $out/share/bash-completion/completions
    mkdir -p $out/share/zsh/site-functions
    $out/bin/helm completion bash > $out/share/bash-completion/completions/helm
    $out/bin/helm completion zsh > $out/share/zsh/site-functions/_helm
  '';

  meta = with stdenv.lib; {
    version = "2.10.0";
    description = "A package manager for kubernetes";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ rlupton20 yurrriq ];
    platforms = [ "x86_64-linux" ] ++ platforms.darwin;
  };
}
