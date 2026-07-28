new: old: {
  pythonPackagesExtensions = old.pythonPackagesExtensions ++ [
    (newpy: oldpy: {
      vacu-humanfriendly = newpy.humanfriendly.overrideAttrs (oldAttrs: {
        version = "11.0";

        src = new.fetchFromGitHub {
          owner = "shelvacu-forks";
          repo = "python-humanfriendly";
          rev = "f539d2824c844eb2ac7627005f20c01e3b61bb7a";
          hash = "sha256-CiMLgiM0Z0Lu3jGz4vWfE0MvzX5G7Zb8qh8QB3hjN+w=";
        };

        patches = [ ];
      });
    })
  ];
}
