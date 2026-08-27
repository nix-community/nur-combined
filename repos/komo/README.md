# nur-packages

**My personal [NUR](https://github.com/nix-community/NUR) repository**

<table>
<tr>
  <td>Build and populate cache</td>
  <td>
    <a href="https://git.gay/kromfin/nur-pkgs/actions?workflow=build.yml">
      <img src="https://git.gay/kromfin/nur-pkgs/badges/workflows/build.yml/badge.svg">
    </a>
  </td>
</tr>
<tr>
  <td>Update packages</td>
  <td>
    <a href="https://git.gay/kromfin/nur-pkgs/actions?workflow=update.yml">
      <img src="https://git.gay/kromfin/nur-pkgs/badges/workflows/update.yml/badge.svg">
    </a>
  </td>
</tr>
</table>
<br>

To reduce the amount of time installing packages from here, add this following
to your `nix.conf`.
```ini
extra-substituters = https://den.krom.foo.ng
extra-trusted-public-keys = kromfin-nixcache:eb0zARxpXg9NaiR2g5TQFnj4z3DucJyj9PVMSZB02xA=
```
