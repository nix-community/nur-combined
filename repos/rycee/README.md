# rycee's NUR expressions

These are my NUR expressions, use them as you please. Don't blame me
if things break.

To make use of the things defined in this repository it is best to
first [install NUR][].

## Firefox Add-ons

### Usage

This NUR repository provides a package set of Firefox extensions that
is updated daily. To list the available add-ons and see their
attribute names you can run

    $ nix-env -f '<nixpkgs>' -qaP -A nur.repos.rycee.firefox-addons

If you use one or more add-on that is not listed here then feel free
to open an issue. In the issue include links to the add-ons at
<https://addons.mozilla.org/>.

[install NUR]: https://github.com/nix-community/NUR/#installation

### Permission Allow Lists

If you manage extensions via Nix then Firefox no longer
[prompts you for permissions][permission-req]
on installations/upgrades. To allow list permissions, write a
[NixOS assertion][module-assert] against the `meta.mozPermissions`
value on each extension. For example:

``` nix
let extensions = {
  "{45d4d1a3-4faa-42b7-9747-bcf2153310cd}" = {
    name = "boring-rss";
    permissions = [
      "activeTab"
    ];
  };
} in {
  # truncated other config

  assertions = lib.mapAttrsToList (k: v: let
    unaccepted = lib.subtractLists
        v.permissions
        config.nur.repos.rycee.firefox-addons.${v.name}.meta.mozPermissions;
    in {
      assertion = unaccepted == [];
      message = ''
        Extension ${v.name} has unaccepted permissions: ${builtins.toJSON unaccepted}'';
    }) extensions;
}
```

Now, if an extension upgrade uses a new permission, the NixOS
assertion will fail with a message letting you know which permission
it's requesting.

To understand what each permission does, see the
[list of Firefox permissions][firefox-permissions].

[permission-req]: https://support.mozilla.org/en-US/kb/permission-request-messages-firefox-extensions
[module-assert]: https://nixos.org/manual/nixos/stable/#sec-assertions
[firefox-permissions]: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/manifest.json/permissions
