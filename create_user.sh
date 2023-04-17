# ===================================================================================================================
# Read Server metadata
SERVER_PORT=51820
ENDPOINT=vpn.annndruha.space:$SERVER_PORT
SERVER_PVKEY=$(cat serverprivatekey)           # Read file with server private key
SERVER_PBKEY=$(echo $SERVER_PVKEY | wg pubkey) # Calculate server publickey for clients configs

# ===================================================================================================================
# Read new username
echo "\033[0;32mWelcome to andrey cool script!\033[0m "
mkdir "clients" 2>/dev/null
ld=$(python3 get_new_ip.py)

read -r -p "New username: " name
client_conf="clients/${name}.conf"

if [ -e "$client_conf" ]; then
  echo "\033[0;31mUser with this name already exist. Abort.\033[0m"
  exit 1
fi

# ===================================================================================================================
# Generate new client

echo [Interface] >>$client_conf
echo PrivateKey = "$(wg genkey)" >>$client_conf
echo Address = 10.10.0.${ld}/32 >>$client_conf
echo DNS = 8.8.8.8, 1.1.1.1 >>$client_conf
echo >>$client_conf
echo [Peer] >>$client_conf
echo PublicKey = $SERVER_PBKEY >>$client_conf
echo AllowedIPs = 0.0.0.0/0 >>$client_conf
echo Endpoint = $ENDPOINT >>$client_conf
echo PersistentKeepalive = 20 >>$client_conf

echo "Profile created: \033[0;32m$client_conf\033[0m"
# ===================================================================================================================
# Regenerate peers with new .conf included
sh restart.sh
