{ buildGoModule }:

buildGoModule rec {
  name = "go-org-readwise";
  src = ./.;
  vendorHash = null;
}
