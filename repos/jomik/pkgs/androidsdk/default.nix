{ callPackage, lib }:

let
  platformVersions = {
    "28" = { rev = 6; sha256 = "1gg752gw1i0mk9i2g9ncycxahyivjhmg1i23namji938jszxnll4"; };
    "27" = { rev = 3; sha256 = "0sc1sb3jzr63y11zm3y70cfrmcr15s91lpdfp9zfhb681c4lq302"; };
    "26" = { rev = 2; sha256 = "0ammfjnxszxgkgdyz0w3kvvw57gqbvcf7bg67rj4p72ykk8sgbra"; };
    "25" = { rev = 3; sha256 = "1f66bm9dwdra1d7r57wx7354c67vrxg86d4y4avkzrqgb4s2sx4v"; };
    "24" = { rev = 2; sha256 = "1jfviggqf0kjwhmf49591nid4m0851kj098wbjlpxkkfbjagas7j"; };
    "23" = { rev = 3; sha256 = "0v07s3nz76dmlpqk8zkn7nasmgq78wlpck65fn17069kmpgcsjsb"; };
  };

  buildToolsVersions = {
      "28.0.3" = "16klhw9yk8znvbgvg967km4y5sb87z1cnf6njgv8hg3381m9am3r";
      "26.0.3" = "1nx46xhvw267q6dk01xp4r2p3r81krg94y301b3w8mqn5dh0q9aw";
      "26.0.1" = "1sp0ir1d88ffw0gz78zlbvnxalz02fsaxwdcvjfynanylwjpyqf8";
      "25.0.3" = "0r9d0iwfa21nvx9kwch6c48cq7ij82fjg2xgcl6d3va7g4c1nb0m";
      "25.0.2" = "1c04m6rf85x02l1s4lik0w46k7yx09f16g629qjv0vzivsvcjyhx";
      "23.0.2" = "1dnrgrpr3i3abc939qfih6gx3k7hbz4h1pgv2vsyldkf39alyxc2";
      "23.0.1" = "1kzfms03lnw4z1bm7ypdxkf36cgllwmxbcp9rskhdbb0nzvkwsz5";
    };

  buildToolsBuilder = callPackage ./build-tools.nix {};
  platformBuilder = callPackage ./platform.nix {};
in rec {
  recurseForDerivations = true;
  inherit buildToolsBuilder platformBuilder;
  tools = callPackage ./tools.nix {};
  platformTools = callPackage ./platform-tools.nix {};
  environment = callPackage ./environment.nix {};
} // (with lib; listToAttrs
    (map
    (api: nameValuePair "platform${api}" (with platformVersions.${api}; platformBuilder { inherit api rev sha256; }))
    (attrNames platformVersions)))
  // (with lib; listToAttrs
    (map
    (ver: nameValuePair "buildTools${ver}" (buildToolsBuilder { version = ver; sha256 = buildToolsVersions.${ver}; }))
    (attrNames buildToolsVersions)))
