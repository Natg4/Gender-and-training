#Package importation:
library(haven)
library(sqldf)
library(dplyr)
library(tidyr)
library(ggplot2)
library(fastDummies)
library(stargazer)

P2<-read.csv("C:\\Users\\Public\\Documents\\Nathan_Rui\\Data\\Cleaned_data\\Merge\\merged_P2_DE.csv")

mean(P2$sexe)
P2$female=P2$sexe-1
mean(P2$female)
ggplot(data=subset(P2, female==1), aes(x=domaine_formation_lab))+geom_bar(position="dodge")+labs(title="Fields of training for females ")+theme_classic()+theme(aspect.ratio=0.5, axis.text.x=element_text(angle=45) )
ggplot(data=subset(P2, female==0), aes(x=domaine_formation_lab))+geom_bar(position="dodge", position="fill")+labs(title="Fields of training for males ")+theme_classic()+theme(aspect.ratio=0.5, axis.text.x=element_text(angle=45) )

statdescriptive<-P2 %>%
  group_by(female) %>%
  summarise(
    average_global_cost=mean(coutglo),
    average_cout_sta=mean(coutsta),
    average_hour=mean(p2_nbheur)
    
  )
P2$p2_formacod<-ifelse(is.na(P2$p2_formacod),0,P2$p2_formacod)
P2$domaine<-0

#Let's filter: we keep under 30 and ile de france people
P2<-subset(P2, P2$age<=30)
P2<-subset(P2, ((P2$depcom>=75000 & P2$depcom<76000)|(P2$depcom>=77000 & P2$depcom<78000)|(P2$depcom>=91000 & P2$depcom<96000)))
P2<-subset(P2, is.na(p2_formacod)==FALSE)




for (i in 1:length(P2$p2_formacod)){
  print(i)
  if (P2$p2_formacod[i] >=15000 & P2$p2_formacod[i] < 16000) {
    P2$domaine[i]<-"Developement"
  }
  if (P2$p2_formacod[i] >=44500 & P2$p2_formacod[i] < 44600) {
    P2$domaine[i]<-"Developement"
  }
  if (P2$p2_formacod[i] >=13000 & P2$p2_formacod[i] < 13400) {
    P2$domaine[i]<-"Human Sciences"
  }
  if (P2$p2_formacod[i] >=15200 & P2$p2_formacod[i] < 15300) {
    P2$domaine[i]<-"Human Sciences"
  }
  if (P2$p2_formacod[i] >=14200 & P2$p2_formacod[i] < 14300) {
    P2$domaine[i]<-"Human Sciences"
  }
  if (P2$p2_formacod[i] >=11000 & P2$p2_formacod[i] < 12300) {
    P2$domaine[i]<-"Science"
  }
  if (P2$p2_formacod[i] >=23500 & P2$p2_formacod[i] < 23600) {
    P2$domaine[i]<-"Science"
  }
  if (P2$p2_formacod[i] >=45000 & P2$p2_formacod[i] < 46400) {
    P2$domaine[i]<-"Art & Communication"
  }
  if (P2$p2_formacod[i] >=30800 & P2$p2_formacod[i] < 31100) {
    P2$domaine[i]<-"Art & Communication"
  }
  if (P2$p2_formacod[i] >=24200 & P2$p2_formacod[i] < 24300) {
    P2$domaine[i]<-"Art & Communication"
  }
  if (P2$p2_formacod[i] >=31300 & P2$p2_formacod[i] < 31900) {
    P2$domaine[i]<-"Industry & Transport"
  }
  if (P2$p2_formacod[i] >=21000 & P2$p2_formacod[i] < 21400) {
    P2$domaine[i]<-"Agriculture"
  }
  if (P2$p2_formacod[i] >=12500 & P2$p2_formacod[i] < 12600) {
    P2$domaine[i]<-"Agriculture"
  }
  if (P2$p2_formacod[i] >=21500 & P2$p2_formacod[i] < 21900) {
    P2$domaine[i]<-"Transformation"
  }
  if (P2$p2_formacod[i] >=22800 & P2$p2_formacod[i] < 23100) {
    P2$domaine[i]<-"Transformation"
  }
  if (P2$p2_formacod[i] >=22000 & P2$p2_formacod[i] < 22500) {
    P2$domaine[i]<-"Construction"
  }
  if (P2$p2_formacod[i] >=24300 & P2$p2_formacod[i] < 24500) {
    P2$domaine[i]<-"Mecanic & Electronic"
  }
  if (P2$p2_formacod[i] >=23600 & P2$p2_formacod[i] < 23700) {
    P2$domaine[i]<-"Mecanic & Electronic"
  }
  if (P2$p2_formacod[i] >=31400 & P2$p2_formacod[i] < 31500) {
    P2$domaine[i]<-"Gestion"
  }
  if (P2$p2_formacod[i] >=32000 & P2$p2_formacod[i] < 33100) {
    P2$domaine[i]<-"Gestion"
  }
  if (P2$p2_formacod[i] >=35000 & P2$p2_formacod[i] < 35100) {
    P2$domaine[i]<-"Gestion"
  }
  if (P2$p2_formacod[i] >=34000 & P2$p2_formacod[i] < 34600) {
    P2$domaine[i]<-"Business"
  }
  if (P2$p2_formacod[i] >=41000 & P2$p2_formacod[i] < 42200) {
    P2$domaine[i]<-"Business"
  }
  if (P2$p2_formacod[i] >=42000 & P2$p2_formacod[i] < 44100) {
    P2$domaine[i]<-"Health"
  }
  if (P2$p2_formacod[i] >=42600 & P2$p2_formacod[i] < 42800) {
    P2$domaine[i]<-"Tourism"
  }
  if (P2$p2_formacod[i] >=15400 & P2$p2_formacod[i] < 15500) {
    P2$domaine[i]<-"Tourism"
  }
  if (P2$p2_formacod[i] >=24000 & P2$p2_formacod[i] < 24200) {
    P2$domaine[i]<-"Energy"
  }
  if (P2$p2_formacod[i] >=22600 & P2$p2_formacod[i] < 22700) {
    P2$domaine[i]<-"Energy"
  }
}

P2<-dummy_cols(P2, select_columns = "domaine", remove_first_dummy = TRUE)

#Let's try to run a regression on the fact of going out because of working:
model_job<-lm(P2$gap3_toUnemployed~P2$p2_nbheur+P2$domaine_Business+P2$domaine_Transformation+P2$domaine_Tourism+P2$domaine_Science+P2$domaine_Science+P2$`domaine_Mecanic & Electronic`+P2$`domaine_Industry & Transport`+P2$`domaine_Human Sciences`+P2$domaine_Health+P2$domaine_Gestion+P2$domaine_Energy+P2$domaine_Developement+P2$domaine_Construction+P2$`domaine_Art & Communication`+P2$female+P2$coutglo)
summary(model_job)
stargazer(model_job)
