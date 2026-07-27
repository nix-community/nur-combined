{ stdenv, go_1_12, buildGoModule, fetchFromGitHub }:

let
  buildGoModule12 = buildGoModule.override { go=go_1_12; };
in buildGoModule12 rec {
  name = "minio-${version}";

  version = "2019-08-21T19-40-07Z";
  patches = [ ./go-mod.patch ];

  src = fetchFromGitHub {
    owner = "minio";
    repo = "minio";
    rev = "RELEASE.${version}";
    sha256 = "1snw86rcyjixlhzw2hixp3d03dfbry4wwqrngi6bam2k07k823l0";
  };
    
  modSha256 = "1348bkc9adkfi2jb5rc78ms83s0742vkyd58pwnnrwrad6xd9b90";

  goPackagePath = "github.com/minio/minio";

  subPackages = [ "." ];

  buildFlagsArray = [''-ldflags=
    -X github.com/minio/minio/cmd.Version=${version}
  ''];

  meta = with stdenv.lib; {
    homepage = https://www.minio.io/;
    description = "An S3-compatible object storage server";
    maintainers = with maintainers; [ eelco bachp ];
    platforms = platforms.unix;
    license = licenses.asl20;
  };
}
