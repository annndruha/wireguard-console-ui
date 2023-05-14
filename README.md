# wireguard-console-ui

This shell scripts improve work experience with Wireguard VPN by easily user management

> Warning: this scripts actively using and rewriting wg0.conf

### Setup

* Clone this repo
* Make sure that's your network adapter named `ens3`, if not: change PostUp/PostDown in `restart.sh`
* In headers of `restart.sh` and `create_user.sh` replace values with you own server settings

### Usage
```bash
# Create user config in clients/
sh create_user.sh

# Delete user config and restart
# (if you delete config manually, it need to restart)
sh delete_user.sh

# Restart WG interface
sh restart.sh

# Show traffic statistics
sh statistics.sh
```
