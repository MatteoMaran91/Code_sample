# This script performs the repeated measure anova on the RTs and prepares the figures for the plot
#
# 01 October 2020 (updated 17 December, color and font)
# 03 August used finally for paper
# Matteo Maran
# maran@cbs.mpg.de



# Clean workspace
rm(list = ls())

# Load the package
#library(extrafont)
#loadfonts()
library(car)
library(ez)
library(bestNormalize) # install.packages("bestNormalize")
library(ggplot2)
#library(doBy)  # install.packages("doBy")

#------- LOAD AND PREPARE DATA FOR ANALYSIS
# Load the data with all the trials for all the subjects
table_for_LMM_file = "/data/p_02142/data_analysis_2020/eeg_analysis_outputs/eeg_LMMbis_bkp/big_table_LMM_bis.txt"
orig_LMM_table = read.csv(table_for_LMM_file, header = T, sep = "\t")

# Preliminary check of the table
head(orig_LMM_table)
str(orig_LMM_table)  #useful to see what is factor and what is not, levels and type of data

# Make columns factors when necessary
orig_LMM_table$Subject = as.factor(orig_LMM_table$Subject)
orig_LMM_table$TMS     = as.factor(orig_LMM_table$TMS)
orig_LMM_table$Block   = as.factor(orig_LMM_table$Block)
orig_LMM_table$TrialNr = as.factor(orig_LMM_table$TrialNr)
orig_LMM_table$StemID  = as.factor(orig_LMM_table$StemID)
orig_LMM_table$ResponseCue = as.factor(orig_LMM_table$ResponseCue)

# Interestingly, some variables are numerical (e.g. trigger value) and some are int (e.g. RT).
# In what are they different?
# Some NaNs are expected in the EEG data if we have removed this trials because of trial rejection in the pre-processing
orig_LMM_table[is.na(orig_LMM_table$GivenResponse), ]
orig_LMM_table[is.na(orig_LMM_table$ExpectedResponse), ]
# We ensure that no RT is na:
orig_LMM_table[is.na(orig_LMM_table$RTs), ]
min(orig_LMM_table$RTs)

# We want to focus the analysis on the RTs of the trials which had a correct response
# First we remove the rows for which no given response is recorded
LMM_table_analysis = orig_LMM_table[!is.na(orig_LMM_table$GivenResponse), ]
# Then we remove the rows with an incorrect response
LMM_table_analysis = LMM_table_analysis[LMM_table_analysis$FilterCorrect ==
                                          1, ]
# Then we remove the rows with no RT
LMM_table_analysis = LMM_table_analysis[!is.na(LMM_table_analysis$RTs), ]
str(LMM_table_analysis)

# Check if all the columns of interest are coded as factors
LMM_table_analysis$Grammaticality = as.factor(LMM_table_analysis$Grammaticality)
str(LMM_table_analysis)

### DATA PREPARATION
# Preliminary cleaning of very fast responses and very long ones
LMM_table_analysis = LMM_table_analysis[LMM_table_analysis$RTs > 150 &
                                          LMM_table_analysis$RTs < 1000, ]
# Drop unsed levels
LMM_table_analysis = droplevels(LMM_table_analysis)

# Aggregate the data
ag_data = aggregate(LMM_table_analysis$RTs,
                    by=list(Subject = LMM_table_analysis$Subject,
                            TMS = LMM_table_analysis$TMS, Block = LMM_table_analysis$Block, Grammaticality = LMM_table_analysis$Grammaticality),
                    FUN=mean)
# Rename the column
colnames(ag_data)[5] = "RTs"
# Rename the levels of grammaticality for plot
levels(ag_data$Grammaticality)[levels(ag_data$Grammaticality)=="grammatical"] = "Grammatical"
levels(ag_data$Grammaticality)[levels(ag_data$Grammaticality)=="ungrammatical"] = "Ungrammatical"

# Check that aggregate worked
mean(LMM_table_analysis[LMM_table_analysis$Subject == 1 &
                          LMM_table_analysis$Block == 1 &
                          LMM_table_analysis$Grammaticality == "grammatical" &
                          LMM_table_analysis$TMS == "BA44",]$RTs)
ag_data[ag_data$Subject == 1 & ag_data$Block == 1 & ag_data$Grammaticality == "Grammatical" & ag_data$TMS == "BA44",]$RTs

############## REPEATED MEASURES ANOVA WITH BASIC FUNCTION

ezDesign(data = ag_data,x = Subject,y = TMS, row = Grammaticality, col = Block)
contrasts(ag_data$TMS) = contr.treatment(3, base = 2);
contrasts(ag_data$Grammaticality) = contr.sum
contrasts(ag_data$Block) = contr.sum

my_aov = aov(RTs ~ Grammaticality*TMS*Block + Error(Subject/(Grammaticality*TMS*Block)), ag_data)
summary(my_aov)


############## REPEATED MEASURES ANOVA WITH EZANOVA
my_ez_ANOVA = ezANOVA(data = LMM_table_analysis, dv = RTs, wid = Subject, within = .(Grammaticality, TMS, Block))
RT_Table = ezANOVA(data = LMM_table_analysis, dv = RTs, wid = Subject, within = .(Grammaticality, TMS, Block))

my_posthoc = pairwise.t.test(ag_data$RTs, interaction(ag_data$Grammaticality, ag_data$Block), 
                paired=T, p.adjust.method = "bonferroni") 

save.image(file = "/data/p_02142/data_analysis_2020/beh_analysis_outputs/final_scripts_RT_Acc_paper_20220803/RTs_RData.RData") 

#apa.ezANOVA.table(RT_Table, 
#                    table.number = 1,
 #                   filename="RT_APA_table_final.doc")
############## GGPLOT RTs

library("ddply") #install.packages("ddply")
library("plyr") #install.packages("plyr")

# Function for data summary
data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun=summary_func,
                  varname)
  data_sum <- rename(data_sum, c("mean" = varname))
  return(data_sum)
}
# Get the stats
df2 <- data_summary(ag_data, varname="RTs", 
                    groupnames=c("TMS", "Grammaticality", "Block"))

# Convert to factors
df2$Grammaticality=as.factor(df2$Grammaticality)
df2$TMS=as.factor(df2$TMS)
df2$Block=as.factor(df2$Block)

# Calculate the standard error of the mean
df2$sem = df2$sd/sqrt(length(levels(ag_data$Subject)))

# Define labels for facets
panel_labels <- c("1" = "Block 1", "2" = "Block 2")

# nice reds= firebrick2
# nice blue = royalblue4

# Start plot
p<- ggplot(df2, aes(x=TMS, y=RTs, fill=Grammaticality)) + 
  geom_bar(stat="identity", color="black", 
           position=position_dodge()) +
  geom_errorbar(aes(ymin=RTs-sem, ymax=RTs+sem), width=.2,
                position=position_dodge(.9)) + ylab ("RTs (ms)")
# Add the facet wraps and change the theme
p + facet_wrap(~Block, labeller = labeller(Block = panel_labels))   + theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        strip.background = element_blank(),
        panel.border = element_rect(colour = "black"))+ 
  scale_fill_manual("", values = c("Grammatical" = "cornsilk2", "Ungrammatical" = "gray24")) +
  theme(axis.text = element_text(size = 13, color = "black", family = "Calibri"),axis.title.x=element_blank(), 
        axis.title.y = element_text(size = 14,margin = margin(t = 0, r = 10, b = 0, l = 0), family = "Calibri"), axis.ticks.x=element_blank(),strip.text.y = element_text(size = 14, family = "Calibri"),strip.text.x = element_text(size = 14, family = "Calibri"))+  theme(legend.text=element_text(size=rel(1.2), family = "Calibri"))
# Good size for exporting: width = 856,height = 450