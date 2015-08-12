# coding: latin1

"""
Initialisation de la BDD pour les tests pour créer la bonne table avec les bonnes colonnes.

"""

NB_PARAMETRES = 5
NB_PROBLEMES  = 24
BDD_FILE = 'parametres_genetiques_camlia_par_pb.sqlite'

import sqlite3

params = []
for i in range(NB_PARAMETRES):
    params.append('param{}'.format(i))
pbs = []
for i in range(NB_PROBLEMES):
    pbs.append('pb{}'.format(i))

tot = params + pbs + ['tot']

cmd = 'CREATE TABLE execution ('  + ','.join(tot) + ');'



conn = sqlite3.connect(BDD_FILE)
c = conn.cursor()
c.executescript(cmd)

conn.commit()
conn.close()  

