filestat="stat_$(date +%F__%H-%M-%S).txt"
wg show >"${filestat}"

sed -i "s*peer: **" "${filestat}"

for filepath in clients/*.conf; do
  n=1
  while read -r line; do
    if [ $n = 2 ]; then
      key=$(echo "$line" | cut -c 14-)
      pubkey=$(echo "${key}" | wg pubkey)
      short_peer=$(echo "$filepath" | cut -c 9- | rev | cut -c 6- | rev)
      expression="s*$pubkey*$short_peer*"
      sed -i "$expression" "${filestat}"
    fi
    n=$((n + 1))
  done <"$filepath"
done