#Package importation:
library(haven)
library(sqldf)
library(dplyr)
library(tidyr)
library(ggplot2)
library(fastDummies)
library(stargazer)

#We import the last version of the dataset, with only trained people that were unemployed before:
BREST<-read.csv("C:\\Users\\Public\\Documents\\Nathan_Rui\\Output\\onlyunemp_BREST_DEMMO_Paris_gap2.csv")
DE<-read.csv("C:\\Users\\Public\\Documents\\Nathan_Rui\\Output\\kids.csv")
kids<-select(DE, id_force='id_force',nkids="NENF")
BREST<-merge(BREST, kids, on='id_force', how='left')

BREST=BREST %>%
  group_by(id_force) %>%
  slice(which.min(nkids))
##################################### DESCRIPTIVE STATISTICS ####################################################

mean(BREST$female)
mean(BREST$duree_formation_heures_redressee)
mean(BREST$temps)
BREST<-subset(BREST, BREST$age<=30)
ggplot(BREST, aes(x=domaine_formation_lab, fill=female))+geom_bar(position="dodge")+labs(title="Type of formation per gender")+theme_classic()

ggplot(data=subset(BREST, female==0), aes(x=domaine_formation_lab))+geom_bar()+labs(title="Fields of training for males")+theme_classic()+theme(aspect.ratio=0.5, axis.text.x=element_text(angle=45) )

ggplot(data=subset(BREST, female==1), aes(x=domaine_formation_lab))+geom_bar(position="dodge")+labs(title="Fields of training for females ")+theme_classic()+theme(aspect.ratio=0.5, axis.text.x=element_text(angle=45) )
ggplot(data=subset(BREST, female==0), aes(x=domaine_formation_lab))+geom_bar(position="dodge", position="fill")+labs(title="Fields of training for males ")+theme_classic()+theme(aspect.ratio=0.5, axis.text.x=element_text(angle=45) )
BREST


statdescriptive<-BREST %>%
  group_by(female) %>%
  summarise(
    average_hours=mean(duree_formation_heures_redressee),
    average_age=mean(age_entree_stage),
    average_unemployment_spell=mean(gap2_toEmployed, na.rm=TRUE)
  )

prop.table(table(BREST$domaine_formation_lab, BREST$female),margin=2)*100
prop.table(table(BREST$objectif_stage_lab, BREST$female),margin=2)*100
prop.table(table(BREST$type_remuneration_lab, BREST$female),margin=2)*100
prop.table(table(BREST$niv_diplome_lab, BREST$female),margin=2)*100
prop.table(table(BREST$commanditaire_lab, BREST$female),margin=2)*100
prop.table(table(BREST$duree_formation_heures_redressee, BREST$female),margin=2)*100
prop.table(table(BREST$region, BREST$female),margin=2)*100
prop.table(table(BREST$age_entree_stage, BREST$female),margin=2)*100

####################################### WORK ON THE DATA:#############################################



#We create dummys for controls:
BREST<-dummy_cols(BREST, select_columns = "objectif_stage_lab", remove_first_dummy = FALSE)
BREST<-dummy_cols(BREST, select_columns = "niv_diplome_lab", remove_first_dummy = FALSE)

#We change the format of variables:
BREST$age_interval<-cut(BREST$age, breaks=c(16,18,20,25,30),include.lowest = TRUE)
BREST<-dummy_cols(BREST, select_columns = "age_interval", remove_first_dummy = FALSE)
BREST$duree_interval<-cut(BREST$durtain, breaks=c(0,500,1000,2000),include.lowest = TRUE)
#Then, we do dummies again:
BREST<-dummy_cols(BREST, select_columns = "domaine_formation_lab", remove_first_dummy = TRUE)
BREST<-dummy_cols(BREST, select_columns = "duree_interval", remove_first_dummy = TRUE)


#################################################Econometric part:###########################################


#Let's try to run a regression on the fact of going out because of working:
model_job<-lm(BREST$tojob~ BREST$female+BREST$nkids+ BREST$`domaine_formation_lab_ Echange et gestion`+BREST$`domaine_formation_lab_ Electricité, Electronique `+BREST$`domaine_formation_lab_ Génie civil, Construction, bois`+BREST$`domaine_formation_lab_ Information, communication `+BREST$`domaine_formation_lab_ Langues, développement personnel `+BREST$`domaine_formation_lab_ Manutention, génie industriel`+BREST$`domaine_formation_lab_ Production industrielle, transport, logistique`+BREST$`domaine_formation_lab_ Santé, social, sécurité`+BREST$`domaine_formation_lab_ Sciences`+BREST$`domaine_formation_lab_ Service aux personnes`+BREST$`domaine_formation_lab_ Services à la collectivité`+BREST$`domaine_formation_lab_ Sport, loisirs, tourisme`+BREST$`domaine_formation_lab_ Transformation`+BREST$`domaine_formation_lab_ Non renseigné`+BREST$`duree_interval_(500,1e+03]`+BREST$`duree_interval_(1e+03,2e+03]`+BREST$`niv_diplome_lab_ BAC (Niveau IV) non obtenu`+BREST$`niv_diplome_lab_ CEP OU BEPC ou CAP (niveau VBIS et V)`+BREST$`age_interval_[16,18]`+BREST$`age_interval_(18,20]`+BREST$`age_interval_(25,30]`)
summary(model_job)
stargazer(model_job)


# regression of the time spent in unemployment for people that left unemployment because they found a new job:
test<-subset(BREST, tojob==1)
test$log_time=log(test$gap_signed+1)

model_time<-lm(test$gap_signed~ test$female+ test$nkids + test$`domaine_formation_lab_ Echange et gestion`+test$`domaine_formation_lab_ Electricité, Electronique `+test$`domaine_formation_lab_ Génie civil, Construction, bois`+test$`domaine_formation_lab_ Information, communication `+test$`domaine_formation_lab_ Langues, développement personnel `+test$`domaine_formation_lab_ Manutention, génie industriel`+test$`domaine_formation_lab_ Production industrielle, transport, logistique`+test$`domaine_formation_lab_ Santé, social, sécurité`+test$`domaine_formation_lab_ Sciences`+test$`domaine_formation_lab_ Service aux personnes`+test$`domaine_formation_lab_ Services à la collectivité`+test$`domaine_formation_lab_ Sport, loisirs, tourisme`+test$`domaine_formation_lab_ Transformation`+test$`domaine_formation_lab_ Non renseigné`+test$`duree_interval_(500,1e+03]`+test$`duree_interval_(1e+03,2e+03]`+test$`niv_diplome_lab_ BAC (Niveau IV) non obtenu`+test$`niv_diplome_lab_ CEP OU BEPC ou CAP (niveau VBIS et V)`+test$`age_interval_[16,18]`+test$`age_interval_(18,20]`+test$`age_interval_(25,30]`)
summary(model_time)
stargazer(model_time)
#same in log:
model_time_log<-lm(test$log_time~ test$female +test$nkids+ test$`domaine_formation_lab_ Echange et gestion`+test$`domaine_formation_lab_ Electricité, Electronique `+test$`domaine_formation_lab_ Génie civil, Construction, bois`+test$`domaine_formation_lab_ Information, communication `+test$`domaine_formation_lab_ Langues, développement personnel `+test$`domaine_formation_lab_ Manutention, génie industriel`+test$`domaine_formation_lab_ Production industrielle, transport, logistique`+test$`domaine_formation_lab_ Santé, social, sécurité`+test$`domaine_formation_lab_ Sciences`+test$`domaine_formation_lab_ Service aux personnes`+test$`domaine_formation_lab_ Services à la collectivité`+test$`domaine_formation_lab_ Sport, loisirs, tourisme`+test$`domaine_formation_lab_ Transformation`+test$`domaine_formation_lab_ Non renseigné`+test$`duree_interval_(500,1e+03]`+test$`duree_interval_(1e+03,2e+03]`+test$`niv_diplome_lab_ BAC (Niveau IV) non obtenu`+test$`niv_diplome_lab_ CEP OU BEPC ou CAP (niveau VBIS et V)`+test$`age_interval_[16,18]`+test$`age_interval_(18,20]`+test$`age_interval_(25,30]`)
summary(model_time_log)
stargazer(model_time_log)

#model to study the salary of these people:


#We do it on testsince these are people who found a job:
test<-subset(test,test$salary>0)
model_logsalary1<-lm(log(test$salary)~ test$log_time+test$nkids+ test$female + test$`domaine_formation_lab_ Echange et gestion`+test$`domaine_formation_lab_ Electricité, Electronique `+test$`domaine_formation_lab_ Génie civil, Construction, bois`+test$`domaine_formation_lab_ Information, communication `+test$`domaine_formation_lab_ Langues, développement personnel `+test$`domaine_formation_lab_ Manutention, génie industriel`+test$`domaine_formation_lab_ Production industrielle, transport, logistique`+test$`domaine_formation_lab_ Santé, social, sécurité`+test$`domaine_formation_lab_ Sciences`+test$`domaine_formation_lab_ Service aux personnes`+test$`domaine_formation_lab_ Services à la collectivité`+test$`domaine_formation_lab_ Sport, loisirs, tourisme`+test$`domaine_formation_lab_ Transformation`+test$`domaine_formation_lab_ Non renseigné`+test$`duree_interval_(500,1e+03]`+test$`duree_interval_(1e+03,2e+03]`+test$`niv_diplome_lab_ BAC (Niveau IV) non obtenu`+test$`niv_diplome_lab_ CEP OU BEPC ou CAP (niveau VBIS et V)`+test$`age_interval_[16,18]`+test$`age_interval_(18,20]`+test$`age_interval_(25,30]`)
summary(model_logsalary1)
stargazer(model_logsalary1)


model_logsalary2<-lm(log(test$salary)~  test$female+ test$nkids + test$`domaine_formation_lab_ Echange et gestion`+test$`domaine_formation_lab_ Electricité, Electronique `+test$`domaine_formation_lab_ Génie civil, Construction, bois`+test$`domaine_formation_lab_ Information, communication `+test$`domaine_formation_lab_ Langues, développement personnel `+test$`domaine_formation_lab_ Manutention, génie industriel`+test$`domaine_formation_lab_ Production industrielle, transport, logistique`+test$`domaine_formation_lab_ Santé, social, sécurité`+test$`domaine_formation_lab_ Sciences`+test$`domaine_formation_lab_ Service aux personnes`+test$`domaine_formation_lab_ Services à la collectivité`+test$`domaine_formation_lab_ Sport, loisirs, tourisme`+test$`domaine_formation_lab_ Transformation`+test$`domaine_formation_lab_ Non renseigné`+test$`duree_interval_(500,1e+03]`+test$`duree_interval_(1e+03,2e+03]`+test$`niv_diplome_lab_ BAC (Niveau IV) non obtenu`+test$`niv_diplome_lab_ CEP OU BEPC ou CAP (niveau VBIS et V)`+test$`age_interval_[16,18]`+test$`age_interval_(18,20]`+test$`age_interval_(25,30]`)
summary(model_logsalary2)
stargazer(model_logsalary2)


#without log:
model_salary1<-lm(test$salary~  test$female+ test$nkids + test$`domaine_formation_lab_ Echange et gestion`+test$`domaine_formation_lab_ Electricité, Electronique `+test$`domaine_formation_lab_ Génie civil, Construction, bois`+test$`domaine_formation_lab_ Information, communication `+test$`domaine_formation_lab_ Langues, développement personnel `+test$`domaine_formation_lab_ Manutention, génie industriel`+test$`domaine_formation_lab_ Production industrielle, transport, logistique`+test$`domaine_formation_lab_ Santé, social, sécurité`+test$`domaine_formation_lab_ Sciences`+test$`domaine_formation_lab_ Service aux personnes`+test$`domaine_formation_lab_ Services à la collectivité`+test$`domaine_formation_lab_ Sport, loisirs, tourisme`+test$`domaine_formation_lab_ Transformation`+test$`domaine_formation_lab_ Non renseigné`+test$`duree_interval_(500,1e+03]`+test$`duree_interval_(1e+03,2e+03]`+test$`niv_diplome_lab_ BAC (Niveau IV) non obtenu`+test$`niv_diplome_lab_ CEP OU BEPC ou CAP (niveau VBIS et V)`+test$`age_interval_[16,18]`+test$`age_interval_(18,20]`+test$`age_interval_(25,30]`)
summary(model_salary1)
stargazer(model_salary1)



