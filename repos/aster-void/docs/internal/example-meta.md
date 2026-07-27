# Example meta fields

## CLI tool example

```nix
{ lib, stdenv }:
stdenv.mkDerivation {
  pname = "my-cli";
  version = "0.1.0";

  # ...

  meta = with lib; {
    # Required
    description = "A CLI tool that does something useful"; # copy GitHub's About if appropriate
    license = licenses.mit; # omit if upstream doesn't specify
    mainProgram = "my-cli"; # required for executables

    # Common optional
    homepage = "https://github.com/owner/my-cli";
    changelog = "https://github.com/owner/my-cli/blob/main/CHANGELOG.md";
    longDescription = ''
      A longer description of the package.
      Can span multiple lines and use markdown.
    '';
    maintainers = [];
    platforms = platforms.linux; # or platforms.all

    # Less common optional
    # broken = true;                    # mark as broken
    # priority = 10;                    # conflict resolution (lower = higher priority)
    # timeout = 3600;                   # build timeout in seconds
    # badPlatforms = [ "aarch64-linux" ]; # platforms that fail to build
    # hydraPlatforms = platforms.linux; # platforms for Hydra CI
    # sourceProvenance = [ sourceTypes.binaryNativeCode ]; # for binary distributions
  };
}
```

## Common licenses

```nix
licenses.mit
licenses.asl20      # Apache 2.0
licenses.gpl3Only
licenses.bsd3
licenses.unfree     # proprietary
```

## Common platforms

```nix
platforms.all       # all supported platforms
platforms.linux     # Linux only
platforms.darwin    # macOS only
platforms.unix      # Linux + macOS
```
