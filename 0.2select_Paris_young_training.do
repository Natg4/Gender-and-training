
global Path "C:\Users\Public\Documents\Nathan_Rui\"
cd "${Path}\Data"

use "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\first_P2id.dta" , clear

tab region 
keep if region == "11"

rename p2_formacod formacod 

keep id_force formacod n_objform objform_lab siret p2_nivfor  p2_datdeb p2_datfin p2_nbheur workfirm workabroad 
renvarlab p2_*, subs(p2_  )

//  drop afte merging with MMO 
gen flagdrop = 1 if workabroad == 1 
replace flagdrop = 1 if workfirm == 1 

drop workabroad workfirm 

su 

rename datdeb date_entree
rename datfin date_fin

save "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\first_P2id_paris.dta", replace 


use "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\first_BRESTid.dta", clear 
keep id_force date_entree date_fin formacode duree_formation_heures_redressee public_pic annee_naissance handicape n_commanditaire commanditaire_lab n_objectif_stage objectif_stage_lab domaine_formation_lab n_type_remuneration niv_diplome_lab n_niv_diplome_tr niv_diplome_tr_lab female n_domaine_formation n_niv_diplome ndispositif ndispositif_details depr 

gen parisreg = 1 if inlist(depr,75,77,78,91,92,93,94,95) 

keep if parisreg == 1 

rename annee_naissance birthyear 
keep if birthyear > 1985 
keep if birthyear < 2008
sum birthyear 


gen flagdrop = 1 if commanditaire_lab == "POEC"
drop *commanditaire*
replace flagdrop = 1 if ndispositif== 27 

rename objectif_stage_lab objform_lab 
rename n_objectif_stage n_objform
rename duree_formation_heures_redressee nbheur 

/*
NIV_DIPLOME
Niveau de diplôme le plus élevé obtenu
1 ‐ AUCUN DIPLÔME obtenu (niveau VI)
2 ‐ CEP OU BEPC ou CAP / BAC non obtenu
3A ‐ BAC (Niveau IV) non obtenu
3 ‐ BAC (Niveau IV)
3B ‐ BAC (Niveau IV) obtenu
4 ‐ BAC +2 (niveau III)
5 ‐ BAC +3 ou plus (niveau II et I)
9 – NON RENSEIGNE
*/

 /*
 Mod. p2_nivfor 
Libellé
0 Inconnu ou non renseigné
1 Supérieur à BAC+2
2 De niveau BAC+2 à BAC+2
3 De niveau BAC, BP, BM à BAC
4 De CAP, BEP à 1ère achevé
5 De premier cycle professionnel, BEPC 3ème achevé
6 De sans formation, primaire à 4ème achevé

 */
 

keep id_force female date_entree date_fin formacod nbheur n_objform objform_lab  n_niv_diplome niv_diplome_lab public_pic flagdrop 

su 

replace nbheur = . if nbheur == 9999
replace n_objform = . if objform_lab == "X"
 

save "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\first_BRESTid_paris.dta", replace


use  "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\first_BRESTid_paris.dta", replace


* P2 Variables: id_force formacod objform_lab siret nivfor datdeb datfin nbheur n_objform flagdrop

merge m:1 id_force date_entree date_fin using  "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\first_P2id_paris.dta", update

sort id_force date_entree date_fin 
duplicates drop id_force, force 

gen lowerbac = 1 if inlist(n_niv_diplome,1,2,3) 
replace lowerbac = 1 if inlist(nivfor,4,5,6)
replace lowerbac = 0 if lowerbac == . // lower than bac 
replace lowerbac = 1 if public_pic == 1 
drop public_pic 

destring formacode formacod , replace 
replace formacode = formacod if formacode == . 
replace formacod = formacode if formacod == .   
su  formacode formacod
drop formacod 
replace formacode = . if formacode == 99999
su  formacode 


drop female 
drop _m 

*merge de to get gender 
merge m:1 id_force using "${Path}\Data\Cleaned_data\DE_gender"
keep if _m == 3 
drop _m 
drop if female==. 
tab female 

save "${Path}\Data\Cleaned_data\Training.dta", replace 



merge 1:m id_force using "${Path}\Data\Cleaned_data\DE_demande_paris.dta" , force update  // all hisotrical demande 
drop _m 

* for trained people, keep only te demande before training 
gen trained =(date_entree! = .)
tab trained 

cap drop gap* 
cap drop rk_* 
* DE: datins datann 
* Training: date_entree date_fin 
gen gap1_enterTrain = (date_entree - datins )/365 // gap 1 
replace gap1_enterTrain = . if gap1_enterTrain  < 0  // keep spells that first started DE then started Training, i.e. the efficiency of being assinged to training after open account in DE 

gen gap2_toEmployed = (datann - date_fin)/365 // gap2  
replace gap2_toEmployed = . if gap2_toEmployed < 0  // keep positive ones, i.e. the effect of training, how long after training finished you exit from unemployment spell in DE 

gen gap3_toUnemployed = (datins - date_fin )/365 // gap3 : start unemployment again status, check reasons
replace gap3_toUnemployed = . if gap3_toUnemployed < 0  
su gap*  age

su gap* age if trained == 0 

sort id_force gap1 
list id_force datins gap1 date_entree in 1/30

egen rk_gap1 = rank(gap1) if gap1!= .  , field by(id_force)
list id_force datins gap1 date_entree rk_gap1 in 1/50

egen rk_gap2 = rank(gap2) if gap2!=. ,  by(id_force)
list id_force datann date_fin gap2 rk_gap2 in 1/50

egen rk_gap3 = rank(gap3) if gap3!=., by(id_force)
list id_force datins date_fin gap3 rk_gap3 in 1/50

gen flag = 1 if inrange(rk_gap1,1,1)

replace flag = 1 if inrange(rk_gap2,1,1)
replace flag = 1 if inrange(rk_gap3,1,1)
replace flag =1 if trained == 0 
su if flag == 1 
  
keep if flag ==1 
tab trained 
su gap* rk*


replace motann = "0" if motann == "XX"
destring motann, replace 
cap drop totrain
gen totrain = 1 if (motann==2) 
replace totrain = 0 if totrain == . 
tab totrain 
tab female 
tab totrain female , col 
su 

gen tojob = 1 if (motann>=11 & motann<=16) 
replace tojob = 1 if (motann>=18 & motann<=26)
replace tojob = 0 if tojob == . 
tab tojob 
tab totrain 

tab totrain tojob , col

gen tojobnoT = (tojob == 1 & trained == 0 )
tab tojobnoT 

tab tojob trained , col 


sort id_force datins datann totrain 
br id_force date_* datins datann totrain

drop if flagdrop == 1 
save "${Path}\Data\Cleaned_data\Paris_DE_Training.dta", replace 

cap drop trainedbeforeX 
gen trainedbeforeX = (date_entree <= datann & date_entree >= datins & date_entree != . )
tab trainedbeforeX // ??? DEs_T_DEe

preserve 
gen fkeep = (rk_gap1 ==1 & trained == 1) //DE spell before T
replace fkeep  = 1 if (trained == 0 )// existing spells for no training people 
drop rk_gap2 rk_gap3 gap2 gap3 
keep if fkeep == 1 
su rk_gap1 trained 
tab trained 
save "${Path}\Data\Cleaned_data\Paris_DE_Training_1entertraining.dta",replace 
restore 

preserve 
keep if (rk_gap2 ==1 & trained == 1) |(trained == 0 )
drop rk_gap1 rk_gap3 gap1 gap3 
su rk_gap 
tab trained 
save "${Path}\Data\Cleaned_data\Paris_DE_Training_2exitDE.dta",replace 
restore 



use  "${Path}\Data\Cleaned_data\Paris_DE_Training_1entertraining.dta", clear 

duplicates report id_force date_entree
duplicates tag id_force date_entree if trained == 1 , generate(dup_t)
br if dup_t ==2  

duplicates drop id_force date_entree if trained == 1 , force 

gen year = yofd(datins)
tab year 

keep if inrange(year,2017,2022)
duplicates report id_force trained 

duplicates drop id_force , force 
sort trained id_force  
duplicates drop id_force trained, force 
tab year 
duplicates report id_force 
save  "${Path}\Data\Cleaned_data\Paris_DE_Training_1entertraining.dta", replace 













