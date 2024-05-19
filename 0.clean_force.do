global Path "C:\Users\Public\Documents\Nathan_Rui\"
cd "${Path}\Data"

*import delimited using Cleaned_data\brest_cleaned.csv
*use BREST\brest2_1721_v12.dta, clear 
use BREST\brest2_22_v12.dta, clear 

merge m:1 id_force ID_BREST DATE_ENTREE using BREST\brest2_1721_v12.dta 

rename _m mergetag 
lab def mergetag 1 "brest22" 2 "brest1721"  
lab values mergetag mergetag 
tab mergetag 

renvarlab * , lower 

destring annee_entree annee_naissance, replace 

gen year_enter = yofd(date_entree)
gen year_exit = yofd(date_fin)
format %ty year_enter year_exit 
gen check_age_enter = year_enter - annee_naissance 
su year_enter year_exit age_entree_stage check_age_enter 
drop check_age_enter 


*#We decide here to keep only people that are in the public pic, i.e people that have less than a baccalaureate.
*brest1721<-subset(brest1721, PUBLIC_PIC==1)
keep if public_pic == 1 
*#Here, we will select under 30 people:
*brest1721<-subset(brest1721, AGE_ENTREE_STAGE<=30)

************** age filter ***********************************

keep if age_entree_stage <= 30 

************** age filter ***********************************

*#Supprimons des variables inutiles:
*brest1721<-subset(brest1721, select=-c(`VB_IDENT`,`CPF_autonome`))
drop vb_ident cpf_autonome 
drop qpv 

rename departement_habitation depr 
destring depr, replace force 
su year_enter depr 
drop if depr > 900 & depr != . // keep only mainland france 

tab travailleur_handicape
gen handicape = 0 if travailleur_handicape == "Non"
replace handicape = 1 if travailleur_handicape == "Oui"
drop travailleur_handicape


foreach v of varlist commanditaire objectif_stage domaine_formation type_remuneration niv_diplome niv_diplome_tr{
	split `v', p("-") limit(2)
	tab `v'1
	destring `v'1, replace 
	rename `v'1 n_`v'
	rename `v'2 `v'_lab
}

su n_* 


gen female = 0 if sexe == "M"
replace female = 1 if sexe =="F"

drop sexe 

foreach k of varlist n_domaine_formation n_niv_diplome{
	tab `k'
	encode `k', generate(n`k') 
	tab n`k'
	drop `k'
	rename n`k' `k'
}

drop commanditaire objectif_stage domaine_formation type_remuneration niv_diplome niv_diplome_tr

tab dispositif_tr 
tab dispositif

encode dispositif , generate(ndispositif)
encode dispositif_tr , generate(ndispositif_details)
drop dispositif dispositif_tr 


*save Cleaned_data\brest1721_cleaned.dta, replace  
*export delimited using "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\brest1721_cleaned.csv", replace
su 
format formacod %8.0g 
format cpf_pe %8.0g 
compress 

save Cleaned_data\brest1722_cleaned.dta, replace  

export delimited using "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\brest1722.csv", replace

* FH - DE D2 P2 E0 E3etE3-cons 
* FH - E3_action, E3CONS_advice, DE_demande_emploi, P2_formation, D2_indenistation, E0_part_time 

/*
DE (Demandes d'emploi) -
D2 (Indemnisabilité) - Code allocation (INDEM) ;
	 Code filière (FILINDEM) devenu non significatif depuis la mise en place en 2009 de la filière
unique ;
	 Durée maximale d'Indemnisabilité (ODDDMAX) depuis fin 2011.
P2 Formation
E0 (Activité réduites)
E3: actions
E3CONS : Table des actions conseillées
*/



* FH - E3action, E3CONS_advice, DE_demande_emploi, P2_formation, D2_indenistation, E0part_time 

*---------------------------  1. action --------------------------- 
*---------------------------  1. action --------------------------- 
*---------------------------  1. action --------------------------- 
*import delimited using FH\action.csv // E3 
use FH\e3action_selected.dta
renvarlab *, lower 

lab var datdeb "Date de début de la prestation"
lab var datstat "Mois statistique de création de l'enregistrement"
lab var numpres "Numéro de la prestation "

drop if id_force == ""
drop if datmajac == . 

* datstat :YYYYMM 
* datdeb: YYYY-MM-DD
su datmajac datpreco datinsac datdeb datstat

list datmajac datpreco datinsac datdeb datstat in 1/30 
gen ymstat = date(datstat,"YM")

format %td ymstat 

list datmajac datpreco datinsac datdeb datstat ymstat in 1/30 

gen check1 = qofd(datmajac) - qofd(ymstat)  
su check1 
drop ymstat check1 datstat 

renvarlab codact numpres datpreco datinsac datdeb , prefix(E3_)
*renvarlab E3_*, subs(E3_  )

gen datpreco =E3_datpreco

su *dat* 

tab E3_codact
gen flag = 0 
replace flag = 1 if inlist(E3_codact, "A21","A21","EFA", "EFO" ,"S20","T06","T07") // formation-related 

sort id_force datmajac E3_datpreco E3_datinsac 
list id_force datmajac E3_datpreco E3_datinsac in 1/30
by id_force: gen rk_e3 = sum(1)
by id_force : egen ne3 = sum(1)
list id_force datmajac E3_datpreco E3_datinsac  rk_e3 ne3 in 1/30

keep if flag == 1 
*id_force codact numpres datmajac datpreco datdeb datstat 
* id_force datmajac datpreco
save Cleaned_data\FH_E3action_cleaned.dta, replace 

*---------------------------  2. advice ; select variables ------------------
* --------------------------- 2. advice ; select variables ---------------
* --------------------------- 2. advice ; select variables -----------

*import delimited using FH\advice.csv
use FH/e3cons_advice_selected.dta, clear 
renvarlab *, lower 
lab var codact "Code action conseillée et/ou réalisée "
lab var datstat "Mois statistique de création de l'enregistrement" 
lab var datmajac "Date de mise à jour du statut de l'action" // renseignée based on CODSTATU

lab var datpreco "DATE DE PRECONISATION de l'action" //Cette date ne signifie pas que l'action préconisée a réellement eu lieu. Elle est non renseignée dans un peu plus de 1% des cas (dans la table E3). Elle est toujours renseignée dans la table E3cons.
lab var formacod  "Besoin en formation du demandeur" 

*************
* No datinsac in this dataset 
* idx region id_force codact datmajac datpreco formacod datstat
*************
*renvarlab E3cons_*, subs(E3cons_  )
drop if id_force == ""
drop if datmajac == . 

gen ymstat = date(datstat,"YM")
format %td ymstat 
list datmajac datpreco datstat ymstat in 1/30 
gen check1 = qofd(datmajac) - qofd(ymstat)  
su check1 
drop ymstat check1 datstat 

duplicates report id_force datmajac datpreco
sort  id_force datmajac datpreco 

renvarlab codact datmajac datpreco formacod datstat, prefix(E3cons_)
gen datmajac = E3cons_datmajac
gen datpreco = E3cons_datpreco 

*save "${Path}\Data\Cleaned_data\E3Cons_advice_cleaned.dta", replace 

*--------------------------- 3.demande_emploi ------------------------ 3 
*--------------------------- 3.demande_emploi ------------------------ 3 
*--------------------------- 3.demande_emploi ------------------------ 3 

* import delimited using FH\demande_emploi.csv, clear 

* Select & Export in SAS 

use  FH/DE_demande_selected, clear 
renvarlab * , lower 
lab var nenf "Nombre d'enfants à charge du demandeur"
lab var nation "Nationalité du demandeur"
lab var nivfor "Niveau de formation atteint par le demandeur"
lab var diplome "Diplôme obtenu par le demandeur lors de son inscription"
*replace age = "" if age == "**"
*destring age, replace 
su age 

*----------------------- FILTER AGE ---------------------------
keep if inrange(age, 9,36)
*----------------------- FILTER AGE ---------------------------

save Cleaned_data/DE_demande_cleaned.dta, replace  

lab var expeunit "UNITE DUREE EXPERIENCE DANS LE ROME"


*CE1: DE positionné sur un métier en tension/porteur
*CE2: DE non positionnésur un métier en tension/porteur

replace cemploi = "1" if cemploi == "CE1"
replace cemploi = "2" if cemploi == "CE2"
destring cemploi, replace 

lab define catregr 1 "immediately available for fulltime CDI" 2  "immediately available for parttime CDI", replace 
lab def catregr  3  "immediately available for CDD, mission d'intérim, vacation", add
lab def catregr  4  "not immediately available (en formation, en arrêt maladie, en congé maternité, en CRP…)", add
lab def catregr  5  "Personnes pourvues d'un emploi, à la recherche d'un autre emploi donc non immédiatement disponibles. Figurent ici les personnes en contrat emploi solidarité (CES, CIE ou autres contrat aidés…)", add

lab list 

*gen regidx = reg+idx 


replace nation = "" if inlist(nation, "99", "XX")
destring nation , replace 
compress 
describe 
format age ancien %8.0g 

save "${Path}/Data/Cleaned_data/DE_demande_cleaned.dta", replace 

use Cleaned_data/DE_demande_cleaned, clear 

export delimited using "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\DE_demande_cleaned.csv", replace



*------------------------4.P2_formation ------------------------ 4
*------------------------4.P2_formation ------------------------ 4
*------------------------4.P2_formation ------------------------ 4
*import delimited using FH\formation.csv, clear
use FH\p2_formation.dta, clear 

renvarlab *, lower 

label var numais "Numéro d'Attestation d'Inscription au Stage"

rename perentre workfirm 
rename peretran workabroad 

foreach workfirm of varlist workfirm workabroad decaffd{
	replace `workfirm' = "1" if `workfirm' == "O"
	replace `workfirm' = "0" if `workfirm' == "N"
	destring `workfirm',replace 
}

destring numais objform p2nivfor typvalid p2nbheur catfin orgcat, replace 

encode fortype1, generate(n_fortype1)
encode objform, generate(n_objform)
rename fortype1 fortype1_lab
rename objform objform_lab 

lab def n_fortype1 1 "A CONVENTION AFPE" 2 "C CONVENTIONNEE" 3 "N NON HOMOLOGUEE" , replace 
lab values n_fortype1 n_fortype1 


rename formacod p2formacod 
renvarlab p2*, subs(p2 p2_)

drop if id_force == ""
drop if p2_datdeb == . 
drop if p2_datfin== . 


save FH\p2_formation.dta, replace 



*5.indenistation ------------------------ 5


*6.part_time ------------------------ 6 
lab var nbheur "Nombre d'heures d'activités réduites exercées par le demandeur au cours du mois (variable MOIS)"






*******************************************************

*                       IMILO 

*******************************************************













*******************************************************

*                         MMO 

*******************************************************
*import delimited using Cleaned_data\MMO18_cleaned.csv
* SAS  

* id_force idsismmo debutctt predsn derdsn finctt nature siret_af modeexercice mois_naissance annee_naissance siret_ut cp localite cp_pref secteur_public salaire_base salaire_base_mois_complet emploi_bit_2018_02 emploi_bit_2018_01 emploi_bit_2018_03 emploi_bit_2018_04 emploi_bit_2018_05 emploi_bit_2018_06 emploi_bit_2018_07 emploi_bit_2018_08 emploi_bit_2018_09 emploi_bit_2018_10 emploi_bit_2018_11 emploi_bit_2018_12
*renvarlab *, lower 
use "C:\Users\Public\Documents\Nathan_Rui\Data\MMO\MMO_2017.dta", clear 

lab var  DebutCTT "Date de début du contrat"
lab var FinCTT "Date de fin du contrat"

lab var PreDSN "Première déclaration en DSN"
lab var DerDSN "Dernière déclaration en DSN"


lab var Nature "Nature du contrat au dernier jour de la période de référence"
lab var siret_AF "Siret de l'établissement d'affectation"
lab var siret_ut "Siret de l'établissement utilisateur if interim contrats"  // ???? 
lab var ModeExercice "Modalité d'exercice de temps de travail (disponible à partir de la vague 10)"  // ????

lab var Localite "comr of last declaration"
lab var CP "Code postal residence of last declaration"
lab var CP_Pref "Code postal residence of last reference day"  // ????? 
 














