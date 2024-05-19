
*******************************************************************


*              Enter training or not 

*********************************************************************
use  "${Path}\Data\Cleaned_data\Paris_DE_Training_1entertraining.dta", clear 
tab trained 
tab totrain 
tab totrain trained 

su nenf nation diplome sitmat temps qualif mobdist mobunit zus age
gen nodip = (diplome == "N")
drop diplome 
tab sitmat
/*
C CELIBATAIRE
D (or S) DIVORCE OU SEPARE
M (or K) MARIE OU VIE MARITALE
V VEUF
*/

tab temps 
replace temps = 2-temps
lab def temps 1 "fulltime" 0 "partime"
lab values temps temps 

*1 TEMPS COMPLET
*2 TEMPS PARTIEL

tab qualif 


tab contrat 
rename contrat wishcontract
tab wishcontract

destring wishcontract, replace 
lab def wishcontract 1 "Open-ended" 2 "Fixed Dur" 3 "Saisonal", replace 
lab values wishcontract wishcontract 

tab trained 
tab trained totrain , row
tab trained tojob , row

gen formacode3 = int(formacod/100)
merge m:1 formacode3 using  "C:\Users\Public\Documents\Nathan_Rui\Passage\formacod_label.dta" 
drop _m 
rename digit1 formacode1
rename lab1 formacode1_lab
tab formacode1_lab

bys mobunit : sum mobdist 
replace mobdist = . if mobdist == 999 
replace mobdist = mobdist / 60 if mobunit == "MN"
replace mobdist = mobdist / 50 if mobunit == "KM"
replace mobdist = 300 if mobunit == "MT"
bys mobunit : sum mobdist 


cap drop check
gen check = date_entree - datins 
su check 
drop check

drop if datann ==. 
drop if datins == . 

*merge de to get gender 
cap drop female
merge m:1 id_force using "${Path}\Data\Cleaned_data\DE_gender"
keep if _m == 3 
drop _m 
drop if female==. 
tab female 


keep id_force date_entree date_fin nbheur n_objform objform_lab lowerbac female depcom nenf nation sitmat datins motins wishcontract temps qualif motann datann age mobdist mobunit zus depr birthyear trained gap1_enterTrain totrain tojob year nodip formacode1 formacode1_lab 

rename temps wishfulltime

replace nbheur = 0 if nbheur ==.
cap drop *_female

gen age2 = age^2 
foreach v of varlist age age2 mobdist {
	gen `v'_female = `v' * female 
}

destring wishcontract, replace 
encode sitmat, generate(nsitmat)
encode zus, generate(nzus)

encode formacode1_lab, generate(nformaco)
tab nformaco
replace nformaco = 0 if nformaco == . 


/*
mlogit nformaco female i.year , baseoutcome(0) vce(robust)
mlogit nformaco female age age2 mobdist  wishfulltime wishcontract i.nkids  i.nsitmat i.nzus i.qualif i.year , baseoutcome(0) vce(robust)
mlogit nformaco female age* mobdist*  wishfulltime##female wishcontract##female nkids#female nsitmat##female nzus##female qualif##female , baseoutcome(0) vce(robust)
mlogit exittype female age* mobdist*  wishfulltime wishcontract, baseoutcome(0) vce(robust)
mlogit exittype female age* mobdist*  wishfulltime wishcontract wishfulltime#female wishcontract#female nkids#female , baseoutcome(0) vce(robust)
*/


gen ZUS = (zus == "ZU")
drop nzus 
rename ZUS rzus
tab nformaco
lab list
lab def nformaco 0 "No training", add 
lab values nformaco nformaco

tab totrain 
tab trained 

merge 1:m id_force using "C:\Users\Public\Documents\Nathan_Rui\Data\MMO\MMOparis.dta", keepusing(id_force code_commune_insee secteur_PUBLIC Salaire_Base DebutCTT FinCTT) update 
drop if _m == 2 
su
drop _m 
gen otjs = 1 if( datins <=DebutCTT) & (datann >=FinCTT)
egen OTJS = sum(otjs), by(id_force year)
tab OTJS 
drop if OTJS != 0 
tab female 

gen otjt = 1 if( datins <=date_entree) & (datann >=date_fin)
egen OTJT = sum(otjt), by(id_force year)
tab OTJT 
drop if OTJT != 0 
tab female 


sort trained id_force date_entree date_fin  datins datann 
duplicates drop trained id_force, force 



gen durDE =  datann - datins 
cap drop DEtype 
gen DEtype = 2 if trained == 1 
replace DEtype = 3 if tojob == 1 
replace DEtype = 4 if secteur_PUBLIC == . // no MMO info after DE or Training 
replace DEtype = 1 if DEtype == .
tab DEtype

lab def DEtype 1 "Other" 2 "DE+Training" 3 "DE+Job" 4 "DE+NoJobinfo", replace 
lab values DEtype DEtype
tab DEtype tojob 
tab DEtype totrain 
tab DEtype trained 

gen foreign = (nation!=1 & nation != .)
cap drop topict 

encode formacode1_lab, generate(nformaco)
gen topict = 1 if inlist(nformaco,4,5,6,12,14)
replace topict = 2 if inlist(nformaco,2,3,11)
replace topict = 3 if inlist(nformaco,7,10,13)  
replace topict = 0 if inlist(nformaco,8,9)

tab nformaco topict 
lab def topict 1 "Manufac" 2 "Service" 3 "Other" 0 "Science", replace 
lab values topict topict 

gen depr = substr(code_commune_insee,1,2)
destring depr, replace 

save  ${Path}Output\Enter_training_paris, replace
export delimited using  ${Path}Output\Enter_training_paris, replace  





save  ${Path}Output\Enter_training_paris, replace 























* match mmo for untrained, match mmo for trained 

gen gap_signed= (DebutCTT - datann )/365 // how long you get signed a contract in MMO after finished BREST training 
gen days_signed =DebutCTT - datann
replace gap_signed = . if gap_signed < 0
replace days_signed = . if days_signed <0
su gap_signed days_signed
gen year = yofd(DebutCTT)

sort id_force gap_signed 
list id_force gap_signed DebutCTT datann in 1/30

egen rk_signed= rank(gap_signed)  , by(id_force)
list id_force DebutCTT datann gap_signed rk_signed in 1/50

reg gap_signed rk_signed

cap drop flag 
gen flag = 1 if rk_signed == 1 


keep if flag == 1 
tab year

duplicates report id_force datins  datann 
drop OTJS rk_signed flag

merge m:1 id_force datins datann using ${Path}\Output\Enter_training_paris
tab _m 
keep if _m == 3
drop _m 
tab trained female 


rename gap_signed gap_signed_no
rename days_signed days_signed_no 
su gap_signed_no if trained == 0 

foreach v of varlist  secteur_PUBLIC Salaire_Base DebutCTT FinCTT{
	replace `v' = . if trained == 1
}
replace code_commune_insee = "" if trained == 1 


preserve // ---------------------
keep if trained == 1 
drop gap_signed_no year
merge 1:m id_force  using "C:\Users\Public\Documents\Nathan_Rui\Data\MMO\MMOparis.dta", keepusing(id_force code_commune_insee secteur_PUBLIC Salaire_Base DebutCTT FinCTT female) update 
drop if _m == 2
gen gap_signed= (DebutCTT - date_fin )/365 // how long you get signed a contract in MMO after finished BREST training 
gen days_signed =DebutCTT - date_fin
replace gap_signed = . if gap_signed < 0
replace days_signed = . if days_signed <0
su gap_signed days_signed

gen year = yofd(DebutCTT)
gen otjt = 1 if( date_entree <=DebutCTT) & (date_fin >=FinCTT)
egen OTJT = sum(otjt), by(id_force year)
tab OTJT
drop if OTJT != 0 
tab otjt 
drop otjt

sort id_force gap_signed 
list id_force gap_signed DebutCTT date_fin in 1/30
egen rk_signed= rank(gap_signed)  , by(id_force)
list id_force DebutCTT date_fin gap_signed rk_signed in 1/50
reg gap_signed rk_signed
cap drop flag 
gen flag = 1 if rk_signed == 1 

keep if flag == 1 
tab year
duplicates report id_force date_entree date_fin

cap drop OTJT rk_signed flag
renvarlab *_signed , subs(_signed _signed_afterTrain)
drop _m 
save "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\AfterTP_trained.dta", replace 
restore // ---------------------

bys trained: su  secteur_PUBLIC Salaire_Base DebutCTT FinCTT code_commune_insee gap_signed* days_signed*

merge m:1 id_force trained using "${Path}\Data\Cleaned_data\AfterTP_trained.dta", keepusing( secteur_PUBLIC Salaire_Base DebutCTT FinCTT code_commune_insee gap_signed_afterTrain days_signed_afterTrain) update 

drop _m 

bys trained: su gap* days*


foreach v of varlist gap_signed_no days_signed_no {
	replace `v' = . if trained == 1 
}

su gap_signed_no  gap_signed_afterTrain

local vlist " gap_signed days_signed"
foreach v in `vlist'{
	gen `v'= `v'_no
	replace `v' = `v'_afterTrain if trained == 1
}

bys trained: su  *_signed_afterTrain *_signed_no 
bys trained : su gap_signed days_signed age
su gap_signed days_signed age trained Salaire_Base date_entree DebutCTT

foreach v of varlist  Salaire_Base nbheur {
	replace `v' = 0 if `v' == . 
}

keep id_force female age age2 datins datann code_commune_insee lowerbac nenf nation sitmat motins wishcontract wishfulltime qualif motann  mobdist mobunit zus birthyear totrain trained  gap1_enterTrain date_entree date_fin nbheur n_objform objform_lab formacode1 formacode1_lab  gap_signed_afterTrain gap_signed_no tojob  secteur_PUBLIC Salaire_Base DebutCTT FinCTT  days_signed nsitmat rzus nodip 

gen durDE =  datann - datins 
cap drop DEtype 
gen DEtype = 2 if trained == 1 
replace DEtype = 3 if tojob == 1 
replace DEtype = 4 if secteur_PUBLIC == . // no MMO info after DE or Training 
replace DEtype = 1 if DEtype == .
tab DEtype

lab def DEtype 1 "Other" 2 "DE+Training" 3 "DE+Job" 4 "DE+NoJobinfo", replace 
lab values DEtype DEtype
tab DEtype tojob 

gen yearDE= yofd(datins) 
lab var yearDE "year of starting DE demande"

gen durTrain = date_fin - date_entree 
replace durTrain=0 if durTrain ==.  
gen nkids = nenf
replace nkids = 3 if nenf >= 3 

gen yearCT= yofd(DebutCTT)
tab yearCT 


save "${Path}Output\AfterTrainingParis.dta", replace 
export delimited using  ${Path}\Output\AfterTrainingParis, replace 

cap drop status* 
gen status0 = datins

gen status1 = datann 
replace  status1 = date_entree if DEtype == 2
replace  status1 = DebutCTT if DEtype == 3

su status* datins datann 

/*
keep id_force datins datann DebutCTT code_commune_insee gap_signed_no date_entree date_fin nbheur n_objform objform_lab lowerbac nenf nation sitmat motins wishcontract wishfulltime qualif motann age mobdist mobunit zus birthyear trained gap1_enterTrain totrain tojob age2 formacode1 formacode1_lab female nsitmat rzus days_signed durDE DEtype yearDE durTrain nkids yearCT status0 status1 nodip 

gen noinfo = (DEtype == 4)


gen foreign = (nation!=1 & nation != .)
cap drop topict 

encode formacode1_lab, generate(nformaco)
gen topict = 1 if inlist(nformaco,4,5,6,12,14)
replace topict = 2 if inlist(nformaco,2,3,11)
replace topict = 3 if inlist(nformaco,7,10,13)  
replace topict = 0 if inlist(nformaco,8,9)

tab nformaco topict 
lab def topict 1 "Manufac" 2 "Service" 3 "Other" 0 "Science", replace 
lab values topict topict 

gen depr = substr(code_commune_insee,1,2)
destring depr, replace 

save  ${Path}Output\Enter_training_paris, replace
export delimited using  ${Path}Output\Enter_training_paris, replace  

*/













reghdfe Salaire_Base female //, absorb(year)  
reghdfe Salaire_Base female , absorb(yearCT)  
reghdfe Salaire_Base female##trained , absorb(yearCT) 

gen lns = log(Salaire_Base) 
reghdfe lns female //, absorb(year)  
reghdfe lns female , absorb(yearCT)  
reghdfe lns female##trained , absorb(yearCT) 

foreach v of varlist age age2 mobdist {
	gen `v'_female = `v' * female 
}


reghdfe Salaire_Base female trained age age2 mobdist  i.wishfulltime i.nkids  i.nsitmat  i.qualif  , absorb(yearCT) 


reghdfe lns female trained age age2 mobdist  i.wishfulltime i.nkids  i.nsitmat  i.qualif  , absorb(yearCT) 

reghdfe lns female female##trained female##( c.age c.age2 i.wishfulltime i.nkids  i.nsitmat  i.qualif)  , absorb(yearCT) 



reghdfe lns female female##trained female##( c.age c.age2  i.wishfulltime i.nkids  i.nsitmat  i.qualif)  , absorb(yearCT depr) 

encode formacode1_lab, generate(nformaco)
tab nformaco
replace nformaco = 0 if nformaco == . 

reghdfe lns female female##trained female##( c.nbheur c.age c.age2  i.wishfulltime i.nkids  i.nsitmat  i.qualif i.nformaco)  , absorb(yearCT depr) 
 



*reghdfe durDE female //, absorb(yearCT) 
*reghdfe durDE female , absorb(yearCT) 
*reghdfe durDE female##trained , absorb(yearCT) 
*reghdfe durDE female i.DEtype female#DEtype, absorb(yearCT) 



*MMOparis: id_force birthyear code_commune_insee secteur_PUBLIC Salaire_Base DebutCTT FinCTT female




*******************************************************


********** Putpdf 


******************************************************


