use "C:\Users\Public\Documents\Nathan_Rui\Output\Enter_training_paris.dta" , clear
gen nkids = nenf
replace nkids = 3 if nenf >= 3 
drop if totrain == 0 & tojob == 0 

tab DEtype totrain 

gen failtype = 1 if totrain == 1 
replace failtype = 2 if tojob == 1 
replace failtype = 3 if failtype == . 
tab failtype 

drop if failtype == 3 

stset duration, failure(totrain == 0) // totrain or censored
tab failtype 

*stcrreg female , compete(failtype == 2)
*su

sts graph if duration, by(female)

*stset duration, failure(tojob==0) 

streg  female,  dist(weibull) vce(robust) nohr 
est store w1 

streg  female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year,  dist(weibull) vce(robust) nohr 
est store w2

streg  female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year,  dist(weibull) vce(robust) nohr 
est store w3 

etable,  estimates(w1 w2 w3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_4:Duration Model (Weibull) ") titlestyle(font(bold)) column(dvlabel) export(Weibull_dropother.tex, replace) 

etable, replay column(index) note("Failure = totrain == 0 ") export(Weibull_dropother.tex, replace) 



stset duration, failure(tojob==0) 
streg  female ,  dist(weibull) vce(robust) nohr 
est store wj1 

streg  female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year,  dist(weibull) vce(robust) nohr 
est store wj2

streg  female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year,  dist(weibull) vce(robust) nohr 
est store wj3 

etable, estimates(wj1 wj2 wj3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_4b:Duration Model (Weibull) ") titlestyle(font(bold)) column(dvlabel) export(Weibull2_dropother.tex, replace)
etable, replay column(index) note("Failure : tojob == 0 ") export(Weibull2_dropother.tex, replace) 



/*
gen otherexit = (inlist(DEtype,1,4)&tojob==0)
stset duration, failure(otherexit==0) 

streg  female ,  dist(weibull) vce(robust) nohr 
est store wo1 

streg  female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year,  dist(weibull) vce(robust) nohr 
est store wo2

streg  female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year,  dist(weibull) vce(robust) nohr 
est store wo3 

etable, estimates(wo1 wo2 wo3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_4b:Duration Model (Weibull) ") titlestyle(font(bold)) column(dvlabel) export(Weibull3_dropother.tex, replace)
etable, replay column(index) note("Failure : other exit== 0 ") export(Weibull3_dropother.tex, replace) 
*/


stset duration, failure(trained==0) 

streg  female ,  dist(weibull) vce(robust) nohr 
est store wo1 

streg  female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year,  dist(weibull) vce(robust) nohr 
est store wo2

streg  female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year,  dist(weibull) vce(robust) nohr 
est store wo3 

etable, estimates(wo1 wo2 wo3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_4b:Duration Model (Weibull) ") titlestyle(font(bold)) column(dvlabel) export(Weibull4_dropother.tex, replace)
etable, replay column(index) note("Failure : trained == 0 ") export(Weibull4_dropother.tex, replace) 



