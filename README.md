# wireguard-console-ui

This shell scripts improve work experience with Wireguard VPN by easily user management

> Warning: this scripts actively using and rewriting wg0.conf

### Setup

* Clone this repo
* Make sure that's your network adapter named `ens3`, if not: change PostUp/PostDown in `restart.sh`
* In headers of `restart.sh` and `create_user.sh` replace `<PRIVATE_KEY_FILENAME>` and `<YOU_IP_OR_DOMAIN>` with you own server settings:

  ```shell
  # restart.sh
  SERVER_PORT=51820
  SERVER_PVKEY=$(cat <PRIVATE_KEY_FILENAME>)
  ```

  ```shell
  # create_user.sh
  SERVER_PORT=51820
  SERVER_PVKEY=$(cat <PRIVATE_KEY_FILENAME>)
  ENDPOINT=<YOU_IP_OR_DOMAIN>:$SERVER_PORT
  ```

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
