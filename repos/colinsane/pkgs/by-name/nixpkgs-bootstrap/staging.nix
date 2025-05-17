{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "be8530bd408782b69aa28c7b67326668240fff9a";
  sha256 = "sha256-54R2R4dzeTAjOpcUQj6ai13LQwtYgRgS98xAGGc2wgs=";
  version = "unstable-2025-05-15";
  branch = "staging";
}
