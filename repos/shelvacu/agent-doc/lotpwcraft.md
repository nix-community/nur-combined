# LOTPWCraft modpack

`nix build .#lotpwcraft` builds a MultiMC/Prism instance zip of the LOTPWCraft
(Halloween) pack: Minecraft 1.20.1, Forge 47.4.10. `.#lotpwcraft.instance` is
the unzipped instance; its jars are symlinks into the store.

The source was Ring's "mod bundle of suffering" 7z, plus three later
additions: All-in-One VeinMiner & TreeFeller 1.1.8.1, Twilight Forest
4.3.2508 and Twilight Delight 2.2.9. The jars are pinned in `lock.json`. 92
were matched on Modrinth by sha512 (`POST /v2/version_files`). The other 26 were
matched on CurseForge by murmur2 fingerprint. The unauthenticated
`api.curse.tools/v1/cf` proxy answers the fingerprint lookup, but only with
`curl --post302`. Every built jar is byte-identical to the archive's copy.

Resource packs:
- Golden Days Base is upstream 16.2 with 68 files removed (`remove`).
- Golden Days Mod Compat is upstream 1.4.0 with only some asset namespaces kept
  (`keepNamespaces`).
- The contents of both match Ring's copies; the zips themselves differ.
- "very important textures.zip" is CurseForge's "Fox Girl.zip".
- Portal Compat (by pelloish) isn't on Modrinth or CurseForge, so it comes
  from the 7z.

The 7z is fetched from the Dropbox share link in Flandre's install post.

`config/` is extracted from the 7z. Per-world JEI/forgematica data, backups,
quickskin preferences and the embeddium fingerprint are left out.
`openloader/data` holds a Classic Villages (Gravel Paths) datapack. Modrinth has
no 1.20 release of it.

`options.txt` sets the resource pack order seen in a player's log. It also
rebinds quickstack's deposit key to Ctrl+C, because C conflicts with the
ok_zoomer zoom key. Its other settings are the ones shelvacu's manually set-up
instance changed from the 1.20.1 defaults. The last server address and the
platform-dependent `syncChunkWrites` were left out. `version` must be set;
otherwise the options datafixers run. The instance overrides memory to 2–8 GiB.

The pack hasn't been launched from this build.
