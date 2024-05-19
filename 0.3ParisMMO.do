use "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\cleaned_MMO\cleaned_mmo1722.dta", clear

CP CP_Pref

rename annee_naissance birthyear 
destring birthyear, replace 
keep if birthyear > 1985 
keep if birthyear < 2008


global Path "C:\Users\Public\Documents\Nathan_Rui\"
cd "${Path}\Data"


* select Paris mmos 
cd "C:\Users\Public\Documents\Nathan_Rui\Data\MMO"


lab var  DebutCTT "Date de début du contrat"
lab var FinCTT "Date de fin du contrat"

lab var siret_AF "Siret de l'établissement d'affectation"
lab var siret_ut "Siret de l'établissement utilisateur if interim contrats"  // ???? 

lab var CP "Code postal residence of last declaration"
lab var CP_Pref "Code postal residence of last reference day"  // 

keep id_force DebutCTT FinCTT siret_AF birthyear siret_ut CP CP_Pref secteur_PUBLIC Salaire_Base //emploi_*
drop if id_force == ""
gen year = yofd(DebutCTT)
drop if year < 2017
drop if year > 2022

replace CP_Pref = CP if CP_Pref==""
replace CP = CP_Pref if CP == ""
drop CP_Pref 

destring CP,replace 
rename CP code_postal 


su code_postal
gen depr = int(code_postal/1000)

gen parisreg = 1 if inlist(depr,75,77,78,91,92,93,94,95) 
keep if parisreg == 1 


tab secteur_PUBLIC // maybe drop if too few public sector 

* merge de to get gender 
merge m:1 id_force using "${Path}\Data\Cleaned_data\DE_gender"
keep if _m == 3 
drop _m 
drop if female==. 
tab female 

/*
renvarlab emploi_bit_2017_*, subs(_0  _)

forvalues i = 1/12{
	list id_force emploi_bit_2017_`i' in 1/10 
	*by id_force: egen emp_`i' = sum(emploi_bit_2017_`i')
	replace emploi_bit_2017_`i' = 9 if emploi_bit_2017_`i' == 0
	replace emploi_bit_2017_`i' = 0 if emploi_bit_2017_`i' == 1 
	replace emploi_bit_2017_`i' = 1 if emploi_bit_2017_`i' == 9
	
	list id_force emploi_bit_2017_`i'  in 1/10 
	
	gegen emp_`i' = sum(emploi_bit_2017_`i') , by(id_force)
	list id_force emploi_bit_2017_`i' emp_`i' in 1/30 
	dis in red "-------------------" `i'
}

drop emploi_bit_2017_*
*/

gsort id_force DebutCTT FinCTT -Salaire_Base
duplicates drop id_force DebutCTT FinCTT  , force 

keep id_force birthyear code_commune_insee secteur_PUBLIC Salaire_Base DebutCTT FinCTT female

save MMOparis.dta, replace 




