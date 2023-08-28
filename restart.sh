# ===================================================================================================================
# Set Server metadata
SERVER_PORT=51820                              # Wireguard port
SERVER_PVKEY=$(cat serverprivatekey)           # Read file with server private key

# ===================================================================================================================
# Regenerate wg0.conf based on clients folder
rm $PROFILE 2>/dev/null
PROFILE="wg0.conf"

# Create a header of wg0.conf
echo [Interface] >>$PROFILE
echo Address = 10.10.0.1/24 >>$PROFILE
echo Address = fd86:ea04:1115::1/64 >>$PROFILE
echo "PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE; ip6tables -A FORWARD -i ens3 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o ens3 -j MASQUERADE" >>$PROFILE
echo "PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE; ip6tables -D FORWARD -i ens3 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o ens3 -j MASQUERADE" >>$PROFILE
echo ListenPort = $SERVER_PORT >>$PROFILE
echo PrivateKey = $SERVER_PVKEY >>$PROFILE

# Parce files in clients folder an add data to wg0.conf
total_files=0
for filepath in clients/*.conf;
do
  n=1
  while read -r line;
  do
    if [ $n = 2 ];
    then
      key=$(echo "$line" | cut -c 14-)
      pubkey=$(echo "${key}" | wg pubkey)
    fi
    if [ $n = 3 ];
    then
      address=$(echo "$line" | cut -c 11-)
    fi
    n=$((n + 1))
  done <"$filepath"

  echo >>$PROFILE
  echo [Peer] >>$PROFILE
  echo PublicKey = ${pubkey} >>$PROFILE
  echo AllowedIPs = $address >>$PROFILE
  total_files=$((total_files + 1))
done

echo "Total clients: \033[0;32m$total_files\033[0m"

# ===================================================================================================================
# Backup statistics
mkdir "_statistic" 2> /dev/null
filestat="_statistic/stat_$(date +%F_%H-%M-%S).txt"
wg show > "${filestat}"

sed -i "s*peer: **" "${filestat}"
for filepath in clients/*.conf;
do
  n=1
  while read -r line;
  do
    if [ $n = 2 ];
    then
      key=$(echo "$line" | cut -c 14-)
      pubkey=$(echo "${key}" | wg pubkey)
      short_peer=$(echo "$filepath" | cut -c 9- | rev | cut -c 6- | rev)
      expression="s*$pubkey*$short_peer*"
      sed -i "$expression" "${filestat}"
    fi
    n=$((n + 1))
  done <"$filepath"
done

# ===================================================================================================================
# Restart interface
wg-quick down ./$PROFILE
wg-quick up ./$PROFILE
rm $PROFILE 2>/dev/null
