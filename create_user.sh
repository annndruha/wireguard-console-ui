# ===================================================================================================================
# Read Server metadata
SERVER_PORT=51820
ENDPOINT=vpn.annndruha.space:$SERVER_PORT
SERVER_PVKEY=$(cat serverprivatekey) # Read file with server private key
SERVER_PBKEY=$(echo $SERVER_PVKEY | wg pubkey) # Calculate server publickey for clients configs


echo "\033[0;32mWelcome to andrey cool script!\033[0m"
mkdir "clients" 2> /dev/null

#iplastdigit=$(grep -c Peer wg0.conf)
#ld="$(($iplastdigit + 2))"
#echo "\033[0;32mCurrent clients= ${iplastdigit}\033[0m"
#echo New client ip is: 10.10.0.${ld}/32
ld=$(python3 get_new_ip.py)

# ===================================================================================================================
# Read new username
read -r -p "New username: " name
client_conf="clients/${name}.conf"

if [ -e "$client_conf" ]; then
  echo "\033[0;31mUser with thi name already exist. Abort\033[0m"
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

# ===================================================================================================================
# Regenerate wg0.conf based on clients folder
PROFILE="wg0.conf"
rm $PROFILE 2> /dev/null

# Create a header of wg0.conf
echo [Interface] >>$PROFILE
echo Address = 10.10.0.1/24 >>$PROFILE
echo Address = fd86:ea04:1115::1/64 >>$PROFILE
echo "PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE; ip6tables -A FORWARD -i ens3 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o ens3 -j MASQUERADE" >>$PROFILE
echo "PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE; ip6tables -D FORWARD -i ens3 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o ens3 -j MASQUERADE" >>$PROFILE
echo ListenPort = $SERVER_PORT >>$PROFILE
echo PrivateKey = $SERVER_PVKEY >>$PROFILE

# Parce files in clients folder an add data to wg0.conf
for filepath in clients/*.conf; do
  n=1
  while read -r line; do
    if [ $n = 2 ]; then
      key=$(echo "$line" | cut -c 14-)
      pubkey=$(echo "${key}" | wg pubkey)
    fi
    if [ $n = 3 ]; then
      address=$(echo "$line" | cut -c 11-)
    fi
    n=$((n + 1))
  done <"$filepath"

  echo >>$PROFILE
  echo [Peer] >>$PROFILE
  echo PublicKey = ${pubkey} >>$PROFILE
  echo AllowedIPs = $address >>$PROFILE
  echo "$filepath"
done

sh backup_statistic.sh
wg-quick down wg0
wg-quick up wg0
rm $PROFILE 2> /dev/null
