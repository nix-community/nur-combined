{ lib, fetchgit, buildGoModule, ... }:

buildGoModule rec{
  pname = "hydra";
  version = "v1.11.7";
  vendorSha256 = "sha256-ick4KzIgUzHCexWWRpnyNhrHu4i4xX1GsGmzWqar6wA=";

  src = fetchgit {
    url = "https://github.com/ory/hydra.git";
    rev = "510615bcc66231f90c29c1186c28f61366da7e52";
    sha256 = "sha256-tVWFS35EQ8NgHkBzfbCrEszwUC2Uhw78wZwo93siKs4=";
  };

  tags = [
    "sqlite"
  ];

  ldflags = [
      "-s -w"
      "-X github.com/ory/hydra/driver/config.Version=${version}"
      "-X github.com/ory/hydra/driver/config.Commit=${src.rev}"
  ];
  buildPhase = ''
    go install \
      ''${tags:+-tags=${lib.concatStringsSep "," tags}} \
      ''${ldflags:+-ldflags="$ldflags"} \
      -v -p $NIX_BUILD_CORES \
      .

    getGoDirs() {
      local type;
      type="$1"
        if [ -n "$subPackages" ]; then
          echo "$subPackages" | sed "s,\(^\| \),\1./,g"
        else
          find . -type f -name \*$type.go -exec dirname {} \; | grep -v "/vendor/" | sort --unique | grep -v "$exclude"
        fi
    }
  '';

  # tries to connect to sqlite. nope
  doCheck = true;

  postInstall = ''
    find -L $out/bin -type f -not -name hydra -delete
  '';

  meta = with lib; {
    description = "OpenID Certified™ OpenID Connect and OAuth Provider written in Go - cloud native, security-first, open source API security for your infrastructure. SDKs for any language. Compatible with MITREid.";
    homepage = "https://www.ory.sh/hydra";
    licenses = licenses.apache2;
    maintainers = with maintainers; [ congee ];
    mainProgram = "hydra";
  };
}
