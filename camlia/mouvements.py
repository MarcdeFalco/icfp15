def normalize_phrase(s):
    v = [ "p'!.03", "bcefy2", "aghij4",
            "lmno 5", "dqrvz1", "kstuwx" ]
    s2 = ''
    for c in s:
        for sv in v:
            if c in sv:
                s2 += sv[0]
    return s2

def to_moves(s):
    s = normalize_phrase(s)
    cc = {
            'p' : '\\sW', 'b' : '\\sE',
            'a' : '\\sSW', 'l' : '\\sSE',
            'd' : '\\sCW', 'k' : '\\sCCW'
        }
    s2 = ''
    for c in s:
        s2 += cc[c]
    return s2

for line in open('phrases.txt'):
    phrase = line.strip()
    phrase_moves = to_moves(phrase)

    print('{\\tt ' + phrase + '} & $' + phrase_moves + '$ \\\\')

