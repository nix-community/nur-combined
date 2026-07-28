from scriptipy import *
import shlex
import pwd

if len(sys.argv) > 1:
    die("This script doesn't accept any arguments")

auto_roots = Path("/nix/var/nix/gcroots/auto")

# nixos profiles look like /nix/var/nix/profiles/system-309-link
profiles_dir = Path("/nix/var/nix/profiles")
nixos_profiles: list[Path] = []

nix_on_droid_alt_profiles_dir = Path("/nix/var/nix/profiles/per-user/nix-on-droid")
nix_on_droid_profiles: list[Path] = []

user_home_dirs: tuple[str, ...] = tuple(entry.pw_dir for entry in pwd.getpwall())

should_ignore: list[Path] = []

for d in user_home_dirs:
    p = Path(d)
    should_ignore.append(p / ".cache/nix/flake-registry.json")
    # should_ignore.append(p / "dev/nix-stuff/.generated")

did_ignore = 0

results: list[Path] = []
all_auto_roots: list[Path] = []

for link in auto_roots.iterdir():
    pointed = link.readlink()
    try:
        exists = pointed.exists(follow_symlinks=False)
    except PermissionError:
        eprint(f"Warn: no permission to check {pointed}")
        exists = False
    if not exists:
        continue
    assert pointed.is_absolute()
    all_auto_roots.append(pointed)

    if pointed.parent == profiles_dir and pointed.name.startswith("system-"):
        nixos_profiles.append(pointed)
    elif pointed.parent == profiles_dir and pointed.name.startswith("nix-on-droid-"):
        nix_on_droid_profiles.append(pointed)
    elif pointed.parent == nix_on_droid_alt_profiles_dir and pointed.name.startswith(
        "profile-"
    ):
        nix_on_droid_profiles.append(pointed)
    elif pointed in should_ignore:
        did_ignore += 1
    else:
        results.append(pointed)

print("List of auto nix gcroots:")
print()
for res in sorted(results):
    print(shlex.quote(str(res)))
if len(results) == 0:
    print("(none)")

print()
system_profile_count = len(nixos_profiles) + len(nix_on_droid_profiles)
print(f"and {system_profile_count} system profiles and {did_ignore} ignored")
print()
helpful_symlinks: list[str] = []
if len(nixos_profiles) > 0:
    helpful_symlinks.append("/run/booted-system")
    helpful_symlinks.append("/run/current-system")
if len(nix_on_droid_profiles) > 0:
    helpful_symlinks.append("~/.nix-profile")
for s in helpful_symlinks:
    p = Path(s).expanduser().resolve(strict=True)

    equivs = [str(x) for x in all_auto_roots if x.resolve(strict=True) == p]
    print(
        f"{shlex.quote(s):{max(len(s) for s in helpful_symlinks)}} == {shlex.join(equivs)}"
    )
