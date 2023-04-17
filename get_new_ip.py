# This script need for find free ip address
# in users config files
# Return last number of minimal available ip
import glob

files = glob.glob('clients/*.conf')
allocated = []
for file in files:
    with open(file, 'r') as f:
        lines = f.readlines()
    ip = lines[2].replace('Address = ', '').split('/')[0]
    last_number = int(ip.split('.')[3])
    allocated.append(last_number)

available = list(set(range(2, 256)) - set(allocated))
print(available[0])
