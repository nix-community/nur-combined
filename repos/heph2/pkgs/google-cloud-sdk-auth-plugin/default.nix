{ stdenv
, lib
, fetchurl
, autoPatchelfHook
}:

stdenv.mkDerivation rec {
  pname = "google-cloud-sdk-auth-plugin";
  version = "403.0.0";

  src = fetchurl {
    url = "https://storage.googleapis.com/cloud-sdk-release/for_packagers/linux/google-cloud-cli-gke-gcloud-auth-plugin_${version}.orig_amd64.tar.gz";
    sha256 = "1fgcl8vfkb2462lv78y157pmcx1kxl6d29bwaa7gf1kyig929a9r";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  sourceRoot = ".";

  installPhase = ''
    install -m755 -D google-cloud-sdk/bin/gke-gcloud-auth-plugin $out/bin/gke-gcloud-auth-plugin
  '';

  meta = with lib; {
    homepage = "https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke";
    description = "Google Cloud SDK Auth Plugin";
    platforms = platforms.linux;
  };
}
