

# Start from bootstrap

According the file @./mod/hosts/bootstrap , construct a new machine config, you needs to do following:

first of all, asking me about the hostname of new machine,
in mod/disko , create a new file with that hostname with nix suffix, reference to other files and strictly following the disko config that bootstrap.nix file defines.

modify mod/age.nix to add new machine vaultix config, add new host config to mod/hosts/* , mod/bird/* , mod/net.nix; reference to other files in same directory.

new machine needs to enable yggdrasil and vxlan-mesh (reference to existing config)
