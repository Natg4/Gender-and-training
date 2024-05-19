*0.4Analysis_enter_T
ssc install asdoc, replace 


global Path "C:\Users\Public\Documents\Nathan_Rui\"
cd "${Path}\Data"
use ${Path}Output\Enter_training_paris, clear 
replace qualif= . if qualif == 0 
drop if wishcontract == 3 
drop if qualif == . 

drop if duration > 1080
su duration 
tab trained 
tab totrain 
tab tojob 

gen failtype = totrain
replace failtype = 2 if tojob ==1 
replace failtype = 3 if failtype == 0
lab def failtype 1 "totrain" 2 "tojob" 3 "other"
lab values failtype failtype 

tab failtype 
tab failtype female , cell 

*egen nid = group(id_force)
*rename nbheur hourT
*gen duration = datann - datins 
cap drop year 
gen year= yofd(datins)
gen nkids = nenf
replace nkids = 3 if nenf >= 3 & nenf!= . 

su nid year datins datann date_entree date_fin gap1_enterTrain hourT birthyear age qualif nenf female foreign rzus  mobdist  nodip depr  duration 


asdoc su  nid year datins datann date_entree date_fin gap1_enterTrain hourT birthyear age qualif nenf female foreign rzus nodip  mobdist  depr  duration failtype , title(Table 1: Summary Statistics) save(T1_summary.rtf) , replace 

asdoc su lowerbac nsitmat wishcontract wishfulltime qualif trained tojob nodip nformaco  failtype , title(Table 1b: Summary Statistics discrete variables) save(T1_summary.rtf) , append

asdoc tab year female , cell nofreq save(T2_tab.rtf) replace

foreach v of varlist lowerbac sitmat wishcontract wishfulltime qualif trained tojob nodip formacode1_lab nkids foreign rzus topict failtype{
	asdoc tab `v', nofreq save(T1_summary.rtf) append
	tab `v' female , cell nofreq
	asdoc tab `v' female , cell nofreq save(T2_tab.rtf) append
}

asdoc tab nformaco topict , cell nofreq save(T1_summary.rtf) append

****************** regressions *********************
su duration 
gen dey = int(duration / 365)
tab dey 

gen de6m = int(duration / 180)
tab de6m 


local Dfaillist "totrain tojob"  
foreach Dfail in `Dfaillist' {
probit `Dfail' female , vce(robust) 
est store `Dfail'1 
probit `Dfail' female i.year i.dey dey##female , vce(robust) 
est store `Dfail'6 
probit `Dfail' female i.year i.de6m de6m##female, vce(robust) 
est store `Dfail'7 
probit `Dfail' female age age2 mobdist wishfulltime i.nkids i.nsitmat i.qualif  i.rzus i.year, vce(robust) 
est store `Dfail'2
probit `Dfail' female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year, vce(robust) 
est store `Dfail'3 
probit `Dfail' female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year i.dey dey##female, vce(robust) 
est store `Dfail'4
probit `Dfail' female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year i.de6m de6m##female, vce(robust) 
est store `Dfail'5
etable, estimates(`Dfail'1 `Dfail'2 `Dfail'3 `Dfail'4 `Dfail'5  `Dfail'6 `Dfail'7) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_2:Probit Regression Model ") titlestyle(font(bold)) column(dvlabel)  export(Probit_`Dfail'.xlsx, replace)
}

preserve 
keep if failtype < 3 
local Dfaillist "totrain tojob"  
foreach Dfail in `Dfaillist' {
probit `Dfail' female , vce(robust) 
est store `Dfail'1 
probit `Dfail' female i.year i.dey dey##female , vce(robust) 
est store `Dfail'6 
probit `Dfail' female i.year i.de6m de6m##female, vce(robust) 
est store `Dfail'7 
probit `Dfail' female age age2 mobdist wishfulltime i.nkids i.nsitmat i.qualif  i.rzus i.year, vce(robust) 
est store `Dfail'2
probit `Dfail' female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year, vce(robust) 
est store `Dfail'3 
probit `Dfail' female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year i.dey dey##female, vce(robust) 
est store `Dfail'4
probit `Dfail' female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year i.de6m de6m##female, vce(robust) 
est store `Dfail'5
etable, estimates(`Dfail'1 `Dfail'2 `Dfail'3 `Dfail'4 `Dfail'5  `Dfail'6 `Dfail'7) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_2:Probit Regression Model ") titlestyle(font(bold)) column(dvlabel)   export(Probit_`Dfail'_dropothers.xlsx, replace)
}
restore 

ssc install estout, replace 


mlogit failtype female , vce(robust) 
est store ml1 
mlogit  failtype female  i.year i.dey dey##female, vce(robust) 
est store ml2
mlogit  failtype female i.de6m de6m##female, vce(robust) 
est store ml3 
mlogit  failtype female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year, vce(robust) 
est store ml4
mlogit  failtype female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year, vce(robust) 
est store ml5
mlogit  failtype female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year i.dey dey##female, vce(robust) 
est store ml6
mlogit  failtype female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year i.de6m de6m##female, vce(robust) 
est store ml7
estout ml1 ml2 ml3 ml4 ml5 ml6 ml7 using mlogit_failtype.xlsx, stats(r2 r2_a r2_p N, labels("R2" "R2_adjusted" "Pseudo R2" )) cells(b(star fmt(%9.2f)) t(par)  label unstack noomitted )  replace 

 


preserve 
drop if (gap1_enterTrain > 1) & (gap1_enterTrain != . )
tab topic
su de6m dey female 
mlogit topict female , vce(robust) baseoutcome(0)
est store mlf1

mlogit topict female i.year , vce(robust) baseoutcome(0)
est store mlf2

mlogit topict female i.year i.de6m de6m#female , vce(robust) baseoutcome(0)
est store mlf3

mlogit topict female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year, vce(robust)  baseoutcome(0) 
est store mlf4

mlogit topict female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female nkids##female nsitmat##female rzus##female qualif##female i.year  , vce(robust) baseoutcome(0)
est store mlf5 

mlogit topict female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year i.dey dey#female, vce(robust) baseoutcome(0)
est store mlf6

mlogit topict female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year  i.de6m de6m#female, vce(robust) baseoutcome(0)
est store mlf7 

estout mlf1 mlf2 mlf3 mlf4 mlf5 mlf6 mlf7 using mlogit_topic.xlsx, stats(r2 r2_a r2_p N, labels("R2" "R2_adjusted" "Pseudo R2" )) cells(b(star fmt(%9.2f)) t(par)  label unstack noomitted ) replace 
restore 


preserve 
drop if gap1_enterTrain > 1 & gap1_enterTrain != . 

local Dfaillist "trained"  
foreach Dfail in `Dfaillist' {
probit `Dfail' female , vce(robust) 
est store `Dfail'1 
probit `Dfail' female i.year i.dey dey##female , vce(robust) 
est store `Dfail'6 
probit `Dfail' female i.year i.de6m de6m##female, vce(robust) 
est store `Dfail'7 
probit `Dfail' female age age2 mobdist wishfulltime i.nkids i.nsitmat i.qualif  i.rzus i.year, vce(robust) 
est store `Dfail'2
probit `Dfail' female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year, vce(robust) 
est store `Dfail'3 
probit `Dfail' female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year i.dey dey##female, vce(robust) 
est store `Dfail'4
probit `Dfail' female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year i.de6m de6m##female, vce(robust) 
est store `Dfail'5
etable, estimates(`Dfail'1 `Dfail'2 `Dfail'3 `Dfail'4 `Dfail'5  `Dfail'6 `Dfail'7) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_2:Probit Regression Model ") titlestyle(font(bold)) column(dvlabel)   export(Probit_`Dfail'.xlsx, replace)
}
restore 

************ Duration models 

local vlist "dox dob doe  "
foreach v in `vlist' {
	cap drop `v'
}

gen dox = datann - datins  // end DE

su do*
su trained totrain 


* 1
/*
*gen reasonunclear = (inlist(DEtype,1,4))
stset duration, failure(tojob==0)

sts graph 
sts graph, by(female)

sts graph, by(trained)
sts graph, by(female trained)
sts graph, by(female tojob)


graph drop _all 
forvalues i = 2017/2022{
	sts graph if year == `i', by(female) name(stf_`i')
} 

forvalues i = 2017/2022{
	sts graph if year == `i', by(trained) name(stj_`i')
} 

forvalues i = 2017/2022{
	sts graph  if year == `i', by(female trained ) name(st_jf_`i')
} 

*/

* 2

drop otjs OTJS otjt OTJT 
drop _est_*


stset durDE, failure(totrain==0) 
stdes 

graph drop _all 

sts graph 
sts graph, by(female)
sts graph, by(nkids)
sts graph, by(nsitmat)

sts graph, by(female foreign)


foreach v of varlist nkids nsitmat {
sts graph if female == 0, by(`v') legend(pos(3) cols(1)) name(`v'm)
sts graph if female == 1, by(`v') legend(pos(3) cols(1)) name(`v'f)
graph combine `v'm `v'f, name(`v'_gender)
}


/*
cap drop duration 
gen durDE = datann - datins 
gen duration = durDE
replace duration = date_entree - datann if (date_entree ! = .) &  (datann < date_entree )
su duration durDE
reg duration durDE if date_entree != . 
binscatter duration durDE
stset duration , failure(totrain==0)


graph drop _all 
sts graph 
sts graph, by(female)
sts graph, by(nkids)
sts graph, by(nsitmat)

sts graph, by(female foreign)
sts graph, by(nsitmat )

foreach v of varlist nkids nsitmat {
sts graph if female == 0, by(`v') legend(pos(3) cols(1)) name(`v'm)
sts graph if female == 1, by(`v') legend(pos(3) cols(1)) name(`v'f)
graph combine `v'm `v'f, name(`v'_gender)
}
*/

/*
graph drop _all 
forvalues i = 2017/2022{
	sts graph if year == `i', by(female) name(stf_`i')
} 

forvalues i = 2017/2022{
	sts graph if year == `i', by() name(stj_`i')
} 
*/

stset duration, failure(totrain==0) 
streg  female ,  dist(weibull) vce(robust) nohr 
est store wj1 

streg  female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year,  dist(weibull) vce(robust) nohr 
est store wj2

streg  female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year,  dist(weibull) vce(robust) nohr 
est store wj3 

etable, estimates(wj1 wj2 wj3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_4b:Duration Model (Weibull) ") titlestyle(font(bold)) column(dvlabel) //export(Weibull2.xlsx, replace)
etable, replay column(index) note("Failure : tojob == 0 ") export(Weibull_totrain.xlsx, replace) 



stset duration, failure(tojob==0) 
streg  female ,  dist(weibull) vce(robust) nohr 
est store wj1 

streg  female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year,  dist(weibull) vce(robust) nohr 
est store wj2

streg  female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year,  dist(weibull) vce(robust) nohr 
est store wj3 

etable, estimates(wj1 wj2 wj3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_4b:Duration Model (Weibull) ") titlestyle(font(bold)) column(dvlabel) //export(Weibull2.xlsx, replace)
etable, replay column(index) note("Failure : tojob == 0 ") export(Weibull_tojob.xlsx, replace) 



preserve 
drop if totrain ==1
stset duration, failure(tojob==0) 
streg  female ,  dist(weibull) vce(robust) nohr 
est store wj1 

streg  female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year,  dist(weibull) vce(robust) nohr 
est store wj2

streg  female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year,  dist(weibull) vce(robust) nohr 
est store wj3 

etable, estimates(wj1 wj2 wj3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_4b:Duration Model (Weibull) ") titlestyle(font(bold)) column(dvlabel) //export(Weibull2.xlsx, replace)
etable, replay column(index) note("Failure : tojob == 0 ") export(Weibull_tojob_only.xlsx, replace) 
restore 

preserve 
drop if tojob == 1 
tab failtype
stset duration, failure(totrain==0) 

streg  female ,  dist(weibull) vce(robust) nohr 
est store w1 

streg  female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year,  dist(weibull) vce(robust) nohr 
est store w2

streg  female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year,  dist(weibull) vce(robust) nohr 
est store w3 

etable,  estimates(w1 w2 w3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_4:Duration Model (Weibull) ") titlestyle(font(bold)) column(index) //export(Weibull.xlsx, replace) 
etable, replay column(index) note("Failure = totrain == 0 ") export(Weibull_totrain_only.xlsx, replace) 
restore 



cap drop duration 
gen duration = durDE
replace duration = date_entree - datann if (date_entree ! = .) &  (datann < date_entree )
su duration durDE
reg duration durDE if date_entree != . 

preserve 
drop if gap1_enterTrain > 1 & gap1_enterTrain != . 
stset duration, failure(trained==0) 

streg  female ,  dist(weibull) vce(robust) nohr 
est store wo1 

streg  female age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year,  dist(weibull) vce(robust) nohr 
est store wo2

streg  female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year,  dist(weibull) vce(robust) nohr 
est store wo3 

etable, estimates(wo1 wo2 wo3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_4b:Duration Model (Weibull) ") titlestyle(font(bold)) column(dvlabel) // export(Weibull_trained.xlsx, replace)
etable, replay column(index) note("Failure : trained == 0 ")  export(Weibull_trained.xlsx, replace) 
restore 




tab failtype 

stset durDE , failure(failtype == 3)
stcrreg female , compete(failtype == 2) noshr vce(robust)
est store cr1
stcrreg female  age age2 mobdist wishfulltime i.nkids i.nsitmat i.rzus i.qualif i.year, compete(failtype == 2) noshr vce(cluster depr)
est store cr2
stcrreg female age age2 age_f age2_f mobdist mobdist_f wishfulltime##female i.nkids##female i.nsitmat##female i.rzus##female i.qualif##female i.year, compete(failtype == 2) noshr vce(robust)
est store cr3
etable, estimates(cr1 cr2 cr3) showstars showstarsnote mstat(N) mstat(F) mstat(r2, nformat(%5.4f) label("R2")) mstat(r2_a, nformat(%5.4f) label("R2_adjusted")) mstat(r2_p, nformat(%5.4f) label("Pseudo R2"))  mstat(aic)  title("Table_5: Competing risks ") titlestyle(font(bold)) column(dvlabel) //export(CR.xlsx, replace)
etable, replay column(index) note("Failure : failtype == other; risk = tojob ")  export(CR.xlsx, replace) 












sts test female  , logrank
stcox female age, nohr 


streg female , dist(exp) nohr 
streg female , dist(weibull) nohr 

streg female##trained , dist(exp) nohr 
streg female##trained , dist(weibull) nohr 
















