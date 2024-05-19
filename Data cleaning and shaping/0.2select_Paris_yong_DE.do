
* paris, birthyear>1985 DE 
use "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\DE_demande_cleaned.dta" 

keep id_force depcom nenf nation nivfor diplome sitmat contrat temps qualif motann datann motins datins age mobdist mobunit zus

gen depr = substr(depcom, 1,2)
destring depr, replace force

gen parisreg = 1 if inlist(depr,75,77,78,91,92,93,94,95) 

keep if parisreg == 1 

gen birthyear = yofd(datins) - age 
keep if birthyear > 1985 
keep if birthyear < 2008
sum birthyear 

foreach v of varlist qualif nenf temps{
	destring `v', replace 
}




keep id_force depcom nenf nation nivfor diplome sitmat contrat temps qualif motann datann motins datins age mobdist mobunit zus


save "C:\Users\Public\Documents\Nathan_Rui\Data\Cleaned_data\DE_demande_paris.dta", replace 



