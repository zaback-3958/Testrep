##Produce the top n spending values by country, spending category in a given province


# SET VARIABLES #{{{
#base_path<<-'//fld8filer/ttrs/Tourism Program/22-Clients/TRPF/NTS-VTS tables for TRPF/Production/VTS'

#(path.libraries<<-gsub('////','///',Sys.getenv('R_LIBS_USER')))
path.libraries<<-'//fld5filer/CCTTS-CCSTT/Utilities'
#path.libraries<<-'//fld8filer/tcesd-diss/Surveys/TOURISM/Working'

(username<-basename(Sys.getenv('userprofile')))

version<-R.Version()
version<-paste(version$major,version$minor,sep='.')
(version<-gsub('//.//d$','',version))
(path.libraries<<-file.path(path.libraries,'R','win-library',version))
#dir.create(path.libraries,recursive=TRUE)

path.utilities<<-file.path('//fld5filer/CCTTS-CCSTT/Utilities')
#path.utilities<<-file.path('//fld8filer/tcesd-diss/Surveys/TOURISM/Working/Antoine/utilities')
cat(path.utilities,'/n')
#}}}

# LIST OF PACKAGES AND DEPENDENCIES THAT NEED TO BE INSTALLED #{{{
cat('CHECKING WHETHER LIBRARIES ARE INSTALLED ... IF NOT, WILL INSTALL THEM.../n')
packages.to.load<-c('haven','readxl' , 'plyr' , 'dplyr')


# Set repository
myrep<-'https://artifactory.statcan.ca:8443/artifactory/cran'

# Get list of installed packages
ip<-rownames(installed.packages(lib.loc=path.libraries))

# Get the packages from the packages to install vector that do not occur in the installed package list
(not.there<-which(is.na(match(packages.to.load,ip))))

# If there are not installed packages, install them
if(length(not.there)>0){
  # For each not installed package, install it
  for(ii in 1:length(not.there)){
    install.packages(packages.to.load[not.there[ii]],repos=myrep,
                     lib=path.libraries,dependencies=TRUE)
  }
}
#}}}

# NOW LOAD LIBRARIES #{{{
cat('LOADING LIBRARIES .../n')
pb<-txtProgressBar(min=1,max=length(packages.to.load),style=3)
for(ii in 1:length(packages.to.load)){
  setTxtProgressBar(pb,ii)
  try(eval(parse(text=paste0('suppressWarnings(suppressMessages(',
                             'suppressPackageStartupMessages(require(package="',
                             packages.to.load[ii],'",lib.loc=path.libraries,quietly=TRUE,',
                             'warn.conflicts=FALSE))))'))))
}
close(pb)
#}}}

library(dplyr)
require(plyr)

#########Provider Y

dt <- read.csv("//fld5filer/CCTTS-CCSTT/Projects/DataScience/SaifAhmed/Pre-process Validation CC and PP/proportion_pr_cat_new_y.csv" ,stringsAsFactors = FALSE)
dt1 <- dt
dt1[,"prcode"] <- as.character(dt1[,"prcode"])

str(dt1)
#& its_spending_categories == "Clothes&gifts"

data_new2 <- dt1 %>%
  dplyr::filter(share_2021 > 0)%>%
  dplyr::group_by(prcode,ITS_spending_categories) %>%
  dplyr::arrange(desc(share_2021)) %>% 
  dplyr::slice_max(share_2021 ,n=3 )

data_new2 <- as.data.frame(data_new2)

  

data_new2[,"province"] <- mapvalues (
  x    = unlist(data_new2 [,"prcode"]),
  from = c("10","11","12","13","24","35","46","47","48","59","63"),
  to   = c("NF","PE","NS","NB","QC","ON","MB","SK","AB","BC","North"))


dt.to.save <- data_new2 %>%
  dplyr::select(Quarter,prcode,province,country_name,ITS_spending_categories,net_value_2020,share_2020,net_value_2021,
                share_2021,net_value_2022,share_2022,change_2020_2021,change_2021_2022)

write.csv(
  file = "//fld5filer/CCTTS-CCSTT/Projects/DataScience/SaifAhmed/Pre-process Validation CC and PP/top_proportion_pr_cat_y.csv",
  x    = dt.to.save,
  row.names = FALSE
)

table(data_new2[,"prcode"],data_new2[,"province"])

###################
#########Provider S

dt <- read.csv("//fld5filer/CCTTS-CCSTT/Projects/DataScience/SaifAhmed/Pre-process Validation CC and PP/propotion_pr_cat_new_s.csv" ,stringsAsFactors = FALSE)
dt1 <- dt
dt1[,"prcode"] <- as.character(dt1[,"prcode"])

str(dt1)
#& its_spending_categories == "Clothes&gifts"

data_new2 <- dt1 %>%
  dplyr::filter(Quarter == 2)%>%
  dplyr::filter(share_2021 > 0)%>%
  dplyr::group_by(prcode,its_spending_categories) %>%
  dplyr::arrange(desc(share_2021)) %>% 
  dplyr::slice_max(share_2021 ,n=3 )

data_new2 <- as.data.frame(data_new2)



data_new2[,"province"] <- mapvalues (
  x    = unlist(data_new2 [,"prcode"]),
  from = c("10","11","12","13","24","35","46","47","48","59","63"),
  to   = c("NF","PE","NS","NB","QC","ON","MB","SK","AB","BC","North"))


dt.to.save <- data_new2 %>%
  dplyr::select(Quarter,prcode,province,country_name,its_spending_categories,net_value_2020,share_2020,net_value_2021,
                share_2021,net_value_2022,share_2022,change_2020_2021,change_2021_2022)


write.csv(
  file = "//fld5filer/CCTTS-CCSTT/Projects/DataScience/SaifAhmed/Pre-process Validation CC and PP/top_propotion_pr_cat_s.csv",
  x    = dt.to.save,
  row.names = FALSE
)

table(data_new2[,"prcode"],data_new2[,"province"])
