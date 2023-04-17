mkdir "statistic" 2> /dev/null
filestat="statistic/stat_$(date +%F__%H-%M-%S).txt"
sh statistic.sh > "$filestat"