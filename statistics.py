import glob

files = glob.glob('statistic/stat_*.txt')

convert = {
    'B': 1,
    'KiB': 2 ** 10,
    'MiB': 2 ** 20,
    'GiB': 2 ** 30,
    'TiB': 2 ** 40
}


def parce(transfer_line):
    data = transfer_line.split('received,')
    text_r = data[0].replace('transfer:', '').strip()
    text_s = data[1].replace('sent', '').strip()
    r = float(text_r.split(' ')[0]) * convert[text_r.split(' ')[1]]
    s = float(text_s.split(' ')[0]) * convert[text_s.split(' ')[1]]
    return s, r


sent = dict()
received = dict()
for file in files:
    with open(file, 'r') as f:
        lines = f.readlines()

    new_lines = []
    for i, line in enumerate(lines):
        if line == '\n':
            new_lines.append('#%$^&@#')
        else:
            new_lines.append(line)
    text = ''.join(new_lines)
    users_texts = text.split('#%$^&@#')

    for i, user_text in enumerate(users_texts[1:]):
        user = user_text.split('\n')[0]
        userdata = user_text.split('\n')
        for line in userdata:
            if line.strip().startswith('transfer'):
                s, r = parce(line)
                if user not in sent:
                    sent[user] = s
                    received[user] = r
                else:
                    sent[user] += s
                    received[user] += r


# sum_traffic = dict()
# for user in sent.keys():
#     sum_traffic[user] = (sent[user], received[user], sent[user] + received[user])


for name, s, r in zip(sent.keys(), sent.values(), received.values()):
    tail = ' ' * (27 - len(name))
    if tail == '':
        name = name[:24] + '...'
    s_text = f"{s / (2 ** 30):.2f}"
    s_text = ' ' * (6 - len(s_text)) + s_text
    r_text = f"{r / (2 ** 30):.2f} "
    r_text = ' ' * (8 - len(r_text)) + r_text
    print(f"{name}{tail}{s_text} GiB{r_text} GiB")
