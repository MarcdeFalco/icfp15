# coding: latin1

"""
Petit algo génétique pour essayer d'optimiser les pondérations.

On va stocker les résultats dans une base de données pour pouvoir rechercher 
le meilleur de tous les temps facilement.

"""

import random # On va avoir besoin d'un peu d'aléatoire :o)

ANCETRE = [3,2,1,100,1,100] # La pondération "naturelle" de base
ANCETRE2= [10,7,1,349,3,10]
ANCETRE3= [7,7,1,4,4,4]
NOMBRE_DE_CYCLES = 10
NOMBRE_DE_CANDIDATS= 12
MAX_VAL = 10
NB_PARAMETRES = len(ANCETRE) # Le nombre de paramètres
NB_PROBLEMES = 24
PROBLEMES = [23]
#0,1,2,3,4,5,6,7,8,9,10,11,12,13,15,16,17,19,20,21,22,23]
BDD_FILE = 'parametres_genetiques_camlia_par_pb_6params.sqlite'

# Détermination des joueurs initiaux. On prend l'ancêtre et 11 autres pris 
# aléatoirement.

CANDIDATS = [ANCETRE,ANCETRE2,ANCETRE3]

def cree_candidat():
    """ Création d'un candidat aléatoire."""
    return [random.randint(0,MAX_VAL) for j in range(NB_PARAMETRES)]

for i in range(NOMBRE_DE_CANDIDATS-len(CANDIDATS)):
    CANDIDATS.append(cree_candidat())

# Il faut écrire quelques fonctions auxiliaires

def lance_tests(candidats):
    """Lance les tests sur tous les candidats"""
    resultats = []
    for i,c in enumerate(candidats):
        print('** Candidat {}'.format(i))
        res = applique_problemes(c)
        resultats.append(res)
    return resultats

def applique_problemes(c):
    """Applique tous les problèmes à un candidat et note les réponses"""
    tous_pb = []
    for pb in PROBLEMES:
        cmd = './ia.native ../problems/problem_{}.json '.format(pb)
        cmd+= ' '.join([str(a) for a in c])
        print(cmd)
        res = applique_cmd_et_recupere_score(cmd)
        tous_pb.append(res)
    entre_dans_BDD(c,tous_pb)
    return sum(tous_pb)

import subprocess
import numpy as np

def applique_cmd_et_recupere_score(cmd):
    """ Application effective de la commande et traitement de la chaîne de 
    caractère résultante pour en extraire les scores. """
    output = subprocess.getoutput(cmd)
    tout_pb = []
    for line in output.splitlines():
        if line[:4] == 'Mean':
            st,score = line.split(':')
            tout_pb.append(float(score))
    return int(np.array(tout_pb).mean())

import sqlite3


def entre_dans_BDD(candidat,tous_pb):
    """ On entre dans la BDD et on y inscrit le score de la combinaison de 
    paramètres choisie. """
    all_pb = ['NULL']*NB_PROBLEMES
    for i,num_pb in enumerate(PROBLEMES):
        all_pb[num_pb] = tous_pb[i]
    Ltot = candidat + all_pb + [sum(tous_pb)]
    Ltot = [str(a) for a in Ltot]
    conn = sqlite3.connect(BDD_FILE)
    c = conn.cursor()
    cmd = 'INSERT INTO execution VALUES (' + ','.join(Ltot) + ');'
    c.executescript(cmd)
    conn.commit()
    conn.close()

def nouveaux_joueurs(candidats,resultats):
    """Récupère la liste des nouveaux joueurs: on garde les quatre meilleurs 
    du lots. Chaque meilleur va faire des enfants avec chacun des 3 autres, on 
    a donc 6 enfants. Et finalement, on introduit deux nouveaux joueurs 
    aléatoire pour aider l'émergence de nouvelles caractéristiques. """
    meilleurs,resultats_meilleurs = trouve_meilleurs(candidats,resultats)
    nouveaux = [cree_candidat(),cree_candidat()]
    enfants = []
    n = len(meilleurs)
    for i in range(n):
        for j in range(i+1,n):
            m1,m2 = meilleurs[i],meilleurs[j]
            r1,r2 = resultats[i],resultats[j]
            enfants.append(reproduction(m1,r1,m2,r2))
    return meilleurs + nouveaux + enfants, resultats_meilleurs

def trouve_meilleurs(candidats,resultats):
    """ Récupère les 4 meilleurs d'une série. """
    classement = [i for i in zip(resultats,candidats)]
    classement.sort(reverse=True)
    print('CLASSEMENT pour cette generation:')
    for i in range(len(classement)):
        print(classement[i])
    return [classement[i][1] for i in range(4)],[classement[i][0] for i in range(4)]

def reproduction(p1,r1,p2,r2):
    """ Mélange des gènes pour p1 et p2. Renvoie un enfant. 
    r1 et r2 sont les résultats respectivement pour p1 et p2. """ 
    poids = r1/(r1+r2)
    enfant = []
    for i in range(NB_PARAMETRES):
        if random.randint(0,9) < 9: # 9 fois sur 10, c'est le mixage normal
            coeff = poids + (-1)**random.randint(0,1) * random.random()
            enfant.append(int(coeff*p1[i] + (1-coeff)*p2[i]))
        else: # Sinon, mutation aléatoire
            enfant.append(random.randint(0,MAX_VAL))
    return enfant

# Avant de lancer les générations

for gen in range(NOMBRE_DE_CYCLES):
    print('******** GENERATION {} **********'.format(gen))
    if gen == 0:
        resultats = lance_tests(CANDIDATS)
    else: 
        resultats = old_resultats + lance_tests(CANDIDATS[4:])
    CANDIDATS,old_resultats = nouveaux_joueurs(CANDIDATS,resultats)
    
