echo Enter username to delete
read -r -p "Username: " name

if [ -e clients/"${name}".conf ]; then
  rm clients/"${name}".conf
  echo "User \033[0;32m${name}\033[0m deleted"
  sh restart.sh
else
  echo "\033[0;31mUser not exist. Nothing to delete.\033[0m"
fi
