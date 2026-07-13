# How to deploy to DigitalOcean Droplet

```bash
$ nix develop
$ terraform init # 初回だけ必要
$ terraform plan
$ terraform apply
$ cd nix/ && nix run github:serokell/deploy-rs ./flake.nix
```
