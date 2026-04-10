# Openning

## migrate to dendritic pattern

# Solved

## fix podman with read-only overlayfs /etc

config:
```
   virtualisation.containers.containersConf.settings = {
     network = {
       network_config_dir = "/var/lib/containers/storage/networks";
     };
   };
```
results reporting error while non-priviledged user executing `podman` cmd:
```
Error: open /var/lib/containers/storage/networks/netavark.lock: open /var/lib/containers/storage/networks/netavark.lock: permission denied
```

but without this,`docker-compose up` will failed with

```
 ✘ Network ollama-intel-arc_default           Error Error response from daemon: open /etc/containers/networks/ollama-intel-arc_default.json: read-only file system                   0.0s
failed to create network ollama-intel-arc_default: Error response from daemon: open /etc/containers/networks/ollama-intel-arc_default.json: read-only file system
```

due to my `/etc` is read only filesystem.
