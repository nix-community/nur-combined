{ stdenv, go_1_12, buildGoModule, fetchFromGitHub }:

let
  buildGoModule12 = buildGoModule.override { go=go_1_12; };
in buildGoModule12 rec {
  name = "minio-client-${version}";

  version = "2019-08-29T00-40-57Z";
  patches = [ ./go-mod.patch ];

  src = fetchFromGitHub {
    owner = "minio";
    repo = "mc";
    rev = "RELEASE.${version}";
    sha256 = "11h3z1ss1zraxiznngk0gyq3ad9awvw5kx501h5jcxi1q4d8i95q";
  };
    
  modSha256 = "17814acsqav4r39v2bpj3cd4gas622826l93q8n14aj2g0znjnry";

  goPackagePath = "github.com/minio/mc";

  subPackages = [ "." ];

  buildFlagsArray = [''-ldflags=
    -X github.com/minio/mc/cmd.Version=${version}
  ''];

  meta = with stdenv.lib; {
    homepage = https://www.minio.io/;
    description = "A replacement for ls, cp, mkdir, diff and rsync commands for filesystems and object storage";
    maintainers = with maintainers; [ eelco bachp ];
    platforms = platforms.unix;
    license = licenses.asl20;
  };
}
