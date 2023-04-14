echo Welcome to andrey cool script!
sh backup_statistic.sh

iplastdigit=$(grep -c Peer wg0.conf)
ld="$(($iplastdigit + 2))"
echo Current clients= ${iplastdigit}
echo New client ip is: 10.10.0.${ld}/32

read -p "New username: " name
wg genkey | tee ${name}_privatekey | wg pubkey > ${name}_publickey

wg-quick down wg0

pvkey=`cat ${name}_privatekey`
pbkey=`cat ${name}_publickey`
rm ${name}_publickey
rm ${name}_privatekey

echo [Interface] >> clients/${name}.conf
echo PrivateKey = ${pvkey} >> clients/${name}.conf
echo Address = 10.10.0.${ld}/32 >> clients/${name}.conf
echo DNS = 8.8.8.8, 1.1.1.1 >> clients/${name}.conf
echo  >> clients/${name}.conf
echo [Peer] >> clients/${name}.conf
echo PublicKey = 4jbwLjGgN84x+kyXLvvONgTktWZs099ZNVx5ssMjJBk= >> clients/${name}.conf
echo AllowedIPs = 0.0.0.0/0 >> clients/${name}.conf
echo Endpoint = 212.80.218.172:51820 >> clients/${name}.conf
echo PersistentKeepalive = 20 >> clients/${name}.conf

echo  >> wg0.conf
echo [Peer] >> wg0.conf
echo PublicKey = ${pbkey} >> wg0.conf
echo AllowedIPs = 10.10.0.${ld}/32 >> wg0.conf


wg-quick up wg0
