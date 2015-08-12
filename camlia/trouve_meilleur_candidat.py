# coding: latin1

import sqlite3

bdd = "parametres_genetiques_camlia_global_normalise_6params.sqlite"

comparaison = [3,2,1,100,1]
comparaison = [7,7,1,4,4]

for i in range(24):
    conn = sqlite3.connect(bdd)
    c = conn.cursor()
    cmd = "SELECT param0,param1,param2,param3,param4,param5,pb{},MAX(pb{}) FROM execution".format(i,i)
    c.execute(cmd)
    rows = c.fetchall()
    if rows[0][-1] != None:
        tuple = [i] + comparaison + [i]
        cmd2 = "SELECT pb{} FROM execution WHERE param0={} AND param1={} AND param2={} AND param3={} AND param4={} AND pb{} NOT NULL".format(*tuple)
        c.execute(cmd2)
        rows2 = c.fetchall()
        au_lieu = '\tau lieu de {}\t'.format(rows2[0][0])
        string = '\t'.join([str(a) for a in rows[0][:6]])
        string+= '\tpb{}'.format(i) + '\tScore: {}'.format(rows[0][-1]) + au_lieu 
        print(string)
    conn.commit()
    conn.close()
