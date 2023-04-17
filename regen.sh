profile="wg0_test.conf"

cat wg0_header.conf >$profile

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

  echo >>$profile
  echo [Peer] >>$profile
  echo PublicKey = ${pubkey} >>$profile
  echo AllowedIPs = $address >>$profile
done
