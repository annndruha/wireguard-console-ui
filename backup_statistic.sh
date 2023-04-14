filestat="stat_$(date +%F__%H-%M-%S).txt"

wg show > ${filestat}

sed -i "s*peer: **" $filestat

for filename in $(ls clients/)
do
n=1
while read line; do
	if [ $n = 2 ]; then
		key=$(echo $line | cut -c 14-)
		pubkey=$(echo ${key} | wg pubkey)

		shortpeer=$(echo $filename | rev | cut -c 6- | rev) 
		expression="s*$pubkey*$shortpeer*"
		sed -i $expression $filestat
	fi
	n=$((n+1))
done < clients/$filename
done