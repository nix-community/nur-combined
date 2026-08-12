{ pkgs
, fetchFromGitHub
,
}: { version }:
with import ../swift-builders { inherit pkgs; };
mkPackage rec {
  inherit version;
  name = "TOMLDecoder";
  src = fetchFromGitHub {
    owner = "dduan";
    repo = "TOMLDecoder";
    rev = "${version}";
    sha256 = "sha256-Vk1ALdwjgV/fsep2NwEOYj+rSByeMXj58vf89dGjFK4=";
  };
  targets = [
    {
      name = "Deserializer";
      type = TargetType.Library;
    }
    {
      name = "TOMLDecoder";
      type = TargetType.Library;
      deps = [ "Deserializer" ];
    }
  ];
}
