
tab qualif 

/*
qualif 
00 NON PRECISE
10 MANOEUVRES
20 OUVRIER SPECIALISES
30 OUVRIERS QUALIFIES (OP1-OP2)
40 OUVRIERS QUALIFIES (OP3-OHQ)
50 EMPLOYES NON QUALIFIES
60 EMPLOYES QUALIFIES
70 TECHNICIENS - DESSINATEURS
80 AGENTS DE MAITRISE
90 CADRES

*/
tab contrat 
rename contrat wishcontract
tab wishcontract
/*
1 CONTRAT DUREE INDETERMINEE
2 CONTRAT DUREE DETERM. OU TEMP.
3 CONTRAT SAISONNIER

*/

0.clean force:

label list 
/* for brest 17-21: 
ndispositif_details:
           1 AFC
           2 AFPR
           3 AIF
           4 AUTRES
           5 POEC
           6 POEI
ndispositif:
           1 AFC
           2 AFPR
           3 AIF
           4 Autre :Action subventionn�e PREPA Avenir
           5 Autre :Action subventionn�e QUALIF Emploi
           6 Autre :Action territoriale - PREPA Avenir
           7 Autre :Action territoriale - QUALIF Emploi
           8 Autre :COMP CLES 2018 MPS-REC 1
           9 Autre :Comp�tences Cl�s
          10 Autre :Dispositif int�gr�
          11 Autre :Formation professionnelle pacte
          12 Autre :GF_CARCERAL
          13 Autre :Langue bretonne
          14 Autre :PREPA Avenir Adultes
          15 Autre :PREPA Avenir FLE
          16 Autre :PREPA Avenir Jeunes
          17 Autre :PREPA Cl�s
          18 Autre :PREPA Projet
          19 Autre :Programme Bretagne Formation
          20 Autre :Programme Bretagne Formation (entrepreneuriat)
          21 Autre :QUALIF Emploi Programme � Distance
          22 Autre :QUALIF Emploi individuel
          23 Autre :QUALIF Emploi programme
          24 Autre :SOCLE_GF
          25 Autre :inc
          26 Non ventil�
          27 POEC
          28 POEI
nn_niv_diplome:
           1 1 
           2 2 
           3 3A 
nn_domaine_formation:
           1 A
           2 B
           3 C
           4 D
           5 E
           6 F
           7 G
           8 H
           9 I
          10 J
          11 K
          12 L
          13 M
          14 N
          15 O
mergetag:
           1 brest22
           2 brest1721
*/


lab list 


/*
debpar "DATE D ENTREE EN PARCOURS"

motann "MOTIF D'ANNULATION" 
motchgt "Motif de changement du parcours"  // 50% empty =  no change  
motins "Motif d'inscription de la demande"

*/