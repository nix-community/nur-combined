# Exemplo
```
terraform apply -var gcp_turbo_disk_size=50 -var gcp_turbo_stop=false
```

```
terraform apply -var gcp_turbo_disk_size=50 -var gcp_turbo_stop=false -var gcp_turbo_modo_turbo=true
```

```
terraform apply -var gcp_turbo_disk_size=20 -var gcp_turbo_stop=true -var gcp_instance_image=nixos -var gcp_turbo_modo_turbo=false
```
