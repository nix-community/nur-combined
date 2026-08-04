# override-utils

Convenience functions for defining package overrides

## Setup

Typical usage in an overlay:

```nix
resolved: stable:

with import ./override-utils.lib.nix { inherit stable; /* options… */ };

specify {
    # …
}
```

Options:

- Add channels to search: `search = [ "unstable" /* … */ ];`
- Add NUR export to search: `nur = ./nur.nix;`
- Configure path to local package library: `library = ./packages;`

## Package specification

### Repository selection

Search for any package named `hello`:

```nix
specify {
  hello = any;
}
```

Search by version:

```nix
specify {
  hello.version = "2.12"; # Exact
  hello.version = "≥2.12"; # Minimum
  hello.version = "≥2.12, <3"; # Range
  hello.version = "∞"; # Latest
}
```

Search for an arbitrary condition:

```nix
specify {
  hello.condition = hello: !hello.meta.unfree;
}
```

Search for a package from a specific release:

```nix
specify {
  hello.release = "25.11";
}
```

Target a repository other than `stable`:

```nix
specify {
  hello.target = unstable;
}
```

### Search space

Extend search to a pinned release:

```nix
specify {
  hello.search = pin "1715c13faa2632c0157435babda955fbc3e27cd7" "sha256-gLWmjLdk43pjagKnjOI/CgjKEVFgcOLNL0E0Kw7KasI=";
}
```

Extend search to a pull request:

```nix
specify {
  hello.search = pr 409463 "sha256-zzkI99DMgG1Vts+xLGyM9kxLPQdhFQ1rGiZ38Hgwdvs=";
}
```

### Modification

Configure package parameters:

```nix
specify {
  gimp-with-plugins.plugins = with resolved.gimpPlugins; [ resynthesizer /* … */ ];
}
```

Apply a patch:

```nix
specify {
  hello.patch = ./goodbye.patch;
}
```

Set runtime environment variables:

```nix
specify {
  hello.env.LANGUAGE = "es";
}
```

Add command-line arguments:

```nix
specify {
  hello.args = [ "--traditional" ];
}
```

Annotate broken packages:

```nix
specify {
  hello.broken = hello: ! elem "--enable-fix" hello.configureFlags;
}
```

Modify arbitrary attributes:

```nix
specify {
  hello.overlay = hello: {
    postInstall = hello.postInstall or "" + ''
      touch "$out/foo"
    '';
  };
}
```

Enable Ccache:

```nix
specify {
  hello.ccache = true;
}
```

### Python packages

Override a Python package [in all Python versions][pythonPackagesExtensions]:

```nix
specify {
  pythonPackages.requests = /* … */;
}
```

[pythonPackagesExtensions]: https://nixos.org/manual/nixpkgs/stable/#how-to-override-a-python-package-for-all-python-versions-using-extensions
