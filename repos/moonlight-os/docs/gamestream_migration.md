# GameStream Migration
Nvidia announced that their GameStream service for Nvidia Games clients will be discontinued in February 2023.
Luckily, Helios performance is now equal to or better than Nvidia GameStream.

## Migration
There is no supported automatic migration tool for the Moonlight OS fork. Recreate the applications you want to
publish in Helios; their working directory, command, and artwork are stored in `apps.json`.

## Internet Streaming
If you are using the Moonlight Internet Hosting Tool, you can remove it from your system when you migrate to Helios.
To stream over the Internet with Helios and a UPnP-capable router, enable the UPnP option in the Helios Web UI.

> [!NOTE]
> Running Helios together with versions of the Moonlight Internet Hosting Tool prior to v5.6 will cause UPnP
> port forwarding to become unreliable. Either uninstall the tool entirely or update it to v5.6 or later.

## Limitations
Helios does have some limitations, as compared to Nvidia GameStream.

* Automatic game/application list.
* Changing game settings automatically to optimize streaming.

<div class="section_buttons">

| Previous                                        |              Next |
|:------------------------------------------------|------------------:|
| [Third-party Packages](third_party_packages.md) | [Legal](legal.md) |

</div>

<details style="display: none;">
  <summary></summary>
  [TOC]
</details>
