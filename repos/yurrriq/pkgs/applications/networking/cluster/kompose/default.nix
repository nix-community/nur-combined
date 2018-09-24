{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "kompose-${version}";
  version = "1.16.0";

  goPackagePath = "github.com/kubernetes/kompose";

  src = fetchFromGitHub {
    rev = "v${version}";
    owner = "kubernetes";
    repo = "kompose";
    sha256 = "026k5yx3nfbwrf2p741xicjmlpllfscwadd0lfgiwb049lwwdy6p";
  };

  meta = with stdenv.lib; {
    description = "Go from Docker Compose to Kubernetes";
    longDescription = ''
      kompose is a convenience tool to go from local Docker development to
      managing your application with Kubernetes. Transformation of the Docker
      Compose format to Kubernetes resources manifest may not be exact, but it
      helps tremendously when first deploying an application on Kubernetes.
    '';
    homepage = https://github.com/kubernetes/kompose;
    license = licenses.asl20;
    maintainers = with maintainers; [ thpham yurrriq ];
    platforms = platforms.unix;
  };
}
