{
  name = "jay";
  isNormalUser = true;
  initialHashedPassword =
    "$6$LRvlOuUlmWfOtbKW$JuSDUvL0ykqAhFi80rMdWrc89wDz/uJ1Mt6WuHpsa/7kxSTWlz5O0f7xRvFvJ6nxEePUkxx/52FuHHl3rEhj61";
  extraGroups =
    [ "audio" "docker" "input" "libvirtd" "networkmanager" "video" "wheel" ];
  openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMO6FTToBOIByP9uVP2Ke2jGD/ESxPcXEMhvR7unukNGAAAABHNzaDo= jay@rovacsek.com"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINNGQz3ekO1q/DrxuhP7Ck3TnP9V4ooF5vo8ibFWKKqFAAAABHNzaDo= jay@rovacsek.com"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDuG5e8MReihLwtKk3/rbXcZKNfiapcqAhWu//fC0aMKAAAABHNzaDo= jay@rovacsek.com"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAILDjbVDfVzpcxnx9fl4pBr6eKAJdSyX4JLyBK02N9YeFAAAABHNzaDo= jay@rovacsek.com"
  ];
}
