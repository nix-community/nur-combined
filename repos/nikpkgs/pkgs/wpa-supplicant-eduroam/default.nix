{ pkgs }: pkgs.wpa_supplicant.overrideAttrs (old: {
  patches = (old.patches or []) ++ [
    (pkgs.fetchpatch {
      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/8ac0502e07fc51cc6a39fb9c984feb500c0fd273/pkgs/os-specific/linux/wpa_supplicant/0002-Lower_security_level_for_tls_1.patch";
      sha256 = "sha256-ESL7OZhVZz+YhDqZSQzRyh8ZX9RmZi2EO8o7aLRODHY=";
    })
  ];
})
