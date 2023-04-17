SERVER_PVKEY=$(cat serverprivatekey)
SERVER_PBKEY=$(cat serverpublickey)
SERVER_PORT=51820
ENDPOINT=vpn.annndruha.space:$SERVER_PORT


echo "\033[0;32mWelcome to andrey cool script!\033[0m"
sh backup_statistic.sh
mkdir "clients" 2> /dev/null

iplastdigit=$(grep -c Peer wg0.conf)
ld="$(($iplastdigit + 2))"
echo "\033[0;32mCurrent clients= ${iplastdigit}\033[0m"
echo New client ip is: 10.10.0.${ld}/32

read -r -p "New username: " name
client_conf="clients/${name}.conf"

if [ -e "$client_conf" ]; then
  echo "\033[0;31mUser with thi name already exist. Abort\033[0m"
  exit 1
fi
wg genkey | tee ${name}_privatekey | wg pubkey >${name}_publickey

pvkey=$(cat ${name}_privatekey)
pbkey=$(cat ${name}_publickey)
rm ${name}_publickey
rm ${name}_privatekey



echo [Interface] >>$client_conf
echo PrivateKey = ${pvkey} >>$client_conf
echo Address = 10.10.0.${ld}/32 >>$client_conf
echo DNS = 8.8.8.8, 1.1.1.1 >>$client_conf
echo >>$client_conf
echo [Peer] >>$client_conf
echo PublicKey = $SERVER_PBKEY >>$client_conf
echo AllowedIPs = 0.0.0.0/0 >>$client_conf
echo Endpoint = $ENDPOINT >>$client_conf
echo PersistentKeepalive = 20 >>$client_conf



#echo >>wg0.conf

#echo [Peer] >>wg0.conf
#echo PublicKey = ${pbkey} >>wg0.conf
#echo AllowedIPs = 10.10.0.${ld}/32 >>wg0.conf

PROFILE="wg0_test.conf"
rm $PROFILE 2> /dev/null

echo [Interface] >>$PROFILE
echo Address = 10.10.0.1/24 >>$PROFILE
echo Address = fd86:ea04:1115::1/64 >>$PROFILE
echo SaveConfig = true >>$PROFILE
echo "PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE; ip6tables -A FORWARD -i ens3 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o ens3 -j MASQUERADE" >>$PROFILE
echo "PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE; ip6tables -D FORWARD -i ens3 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o ens3 -j MASQUERADE" >>$PROFILE
echo ListenPort = $SERVER_PORT >>$PROFILE
echo PrivateKey = $SERVER_PVKEY >>$PROFILE

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
done

#wg-quick down wg0
#wg-quick up wg0
