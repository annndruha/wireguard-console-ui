# ===================================================================================================================
# Set Server metadata
SERVER_PORT=51820                              # Wireguard port
SERVER_PVKEY=$(cat serverprivatekey)           # Read file with server private key
ENDPOINT=vpn.annndruha.space:$SERVER_PORT      # This address will write to clients configs

# ===================================================================================================================

# Get available local ip last digits (ld): (10.10.0.ld)
# Yes. It's a python in shell script. Sorry for this.
get_new_ip="get_new_ip.py"
echo \
"import glob
files = glob.glob('clients/*.conf')
allocated = []
for file in files:
    with open(file, 'r') as f:
        lines = f.readlines()
    ip = lines[2].replace('Address = ', '').split('/')[0]
    last_number = int(ip.split('.')[3])
    allocated.append(last_number)
available = list(set(range(2, 256)) - set(allocated))
print(available[0])" \ >>$get_new_ip
ld=$(python3 $get_new_ip)
rm $get_new_ip

# ===================================================================================================================
# Read new username
echo "\033[0;32mWelcome to andrey cool script!\033[0m "
mkdir "clients" 2>/dev/null

read -r -p "New username: " name
client_conf="clients/${name}.conf"

if [ -e "$client_conf" ];
then
  echo "\033[0;31mUser with this name already exist. Abort.\033[0m"
  exit 1
fi
# ===================================================================================================================
# Generate new client
SERVER_PBKEY=$(echo $SERVER_PVKEY | wg pubkey) # Calculate server publickey for clients configs

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
