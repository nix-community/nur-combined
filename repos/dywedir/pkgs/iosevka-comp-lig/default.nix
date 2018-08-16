{ iosevka }:

# https://gist.github.com/mrkgnao/49c7480e1df42405a36b7ab09fe87f3d
iosevka.overrideAttrs (old: {
  preConfigure = old.preConfigure + ''

    # append parameters
    cat ${./parameters.toml} >> parameters.toml
  '';
})
