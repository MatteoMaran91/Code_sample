# This script analyzes the data without the Item "Bader", as pointed out by the reviewer, and potential control 
# over predictive processes during the course of the task.
# Matteo Maran
# 23 August, 2022
# Contrasts fixed on 01 September
# maran@cbs.mpg.de

rm(list = ls())

# Load/Install the packages
#install.packages("dplyr")
#install.packages("tidyr")
#install.packages("stringr")
#install.packages("lmerTest")
#install.packages("emmeans")
#install.packages("ez")
#install.packages("multcomp")
#install.packages("nlme")
#install.packages("reshape")
library(ggplot2)
library(lme4) #install.packages("lme4")
library(dplyr)
library(stringr)
library(tidyr)
library(lmerTest)
library(emmeans)
library(ez)
library(multcomp)
library(reshape)
#library(nlme)

#------- LOAD AND PREPARE DATA FOR ANALYSIS
# Load the data with all the trials for all the subjects
table_for_LMM_file = "/data/p_02142/data_analysis_2020/bader_analysis/For_Reviewer_big_table_LMM.txt"
orig_LMM_table = read.csv(table_for_LMM_file, header = T, sep = "\t")

# 1 ------------------------- Did "Bader" create problems??
# We run the model on the dataset including and excluding Bader/badet
# Create a dataframe with First and Second word columns
new_LMM_df = orig_LMM_table
new_LMM_df[] <- lapply(new_LMM_df, gsub, pattern = "_607_cp.wav", replacement = "", fixed = TRUE) # remove ending to allow splitting by "_"
#new_LMM_df$Item <- lapply(new_LMM_df$Item, gsub, pattern = "_", replacement = " ", fixed = TRUE) # remove ending to allow splitting by "_"

new_LMM_df = new_LMM_df %>%
  separate(Item, c("FirstWord", "SecondWord"), "_") # split the variable Item

# Remove trials with incorrect response or with NaN in the EEG signal (trial rej)
new_LMM_df = new_LMM_df[new_LMM_df$FilterCorrect == 1,]
RTs_LMM = new_LMM_df # make a copy for fure RTs analysis
new_LMM_df = new_LMM_df[new_LMM_df$AmpNegativity != "NaN",]

# Prepare for LMM
new_LMM_df$Subject = as.factor(new_LMM_df$Subject)
new_LMM_df$TMS = as.factor(new_LMM_df$TMS)
new_LMM_df$Grammaticality = as.factor(new_LMM_df$Grammaticality)
new_LMM_df$SecondWord = as.factor(new_LMM_df$SecondWord)
new_LMM_df$AmpNegativity = as.numeric(new_LMM_df$AmpNegativity)
new_LMM_df$AmpPositivity = as.numeric(new_LMM_df$AmpPositivity)
# ADD CONTRASTS!

# Setup simple LMM
# lmm on Neg
# full_LMM_neg = lmer(AmpNegativity ~ Grammaticality*TMS + (1+TMS|Subject) + (1+Grammaticality|SecondWord), data = new_LMM_df)
# anova(full_LMM_neg) # obtain p values with LmerTest
# 
# # emmeans(full_LMM_neg, list(pairwise ~ TMS), adjust = "tukey")
# # lmm on Pos
# full_LMM_pos = lmer(AmpPositivity ~ Grammaticality*TMS + (1+TMS|Subject) + (1+Grammaticality|SecondWord), data = new_LMM_df)
# anova(full_LMM_pos) # obtain p values with LmerTest

# ANOVAs
ezANOVA_Neg_All = ezANOVA(data = new_LMM_df, dv = AmpNegativity, wid = Subject, within = .(Grammaticality, TMS))
ezANOVA_Pos_All = ezANOVA(data = new_LMM_df, dv = AmpPositivity, wid = Subject, within = .(Grammaticality, TMS))

# Remove Bader item
new_LMM_bader_df = new_LMM_df[new_LMM_df$SecondWord != "bader",]
new_LMM_bader_df = new_LMM_df[new_LMM_df$SecondWord != "badet",]
new_LMM_bader_df = droplevels(new_LMM_bader_df)
# Code factors
new_LMM_bader_df$Subject    = as.factor(new_LMM_bader_df$Subject)
new_LMM_bader_df$TMS        = as.factor(new_LMM_bader_df$TMS)
new_LMM_bader_df$Grammaticality = as.factor(new_LMM_bader_df$Grammaticality)
new_LMM_bader_df$SecondWord     = as.factor(new_LMM_bader_df$SecondWord)
new_LMM_bader_df$AmpNegativity = as.numeric(new_LMM_bader_df$AmpNegativity)
new_LMM_bader_df$AmpPositivity = as.numeric(new_LMM_bader_df$AmpPositivity)

# lmm on Neg no Bader
#noBader_full_LMM_neg = lmer(AmpNegativity ~ Grammaticality*TMS + (1+TMS|Subject) + (1+Grammaticality|SecondWord), data = new_LMM_bader_df)
#anova(noBader_full_LMM_neg) # obtain p values with LmerTest

# lmm on Pos no Bader
#noBader_full_LMM_pos = lmer(AmpPositivity ~ Grammaticality*TMS + (1+TMS|Subject) + (1|SecondWord), data = new_LMM_bader_df)
#anova(noBader_full_LMM_pos) # obtain p values with LmerTest

# ezANOVAs
ezANOVA_Neg_NoBader = ezANOVA(data = new_LMM_bader_df, dv = AmpNegativity, wid = Subject, within = .(Grammaticality, TMS))
ezANOVA_Pos_NoBader = ezANOVA(data = new_LMM_bader_df, dv = AmpPositivity, wid = Subject, within = .(Grammaticality, TMS))


# 2 ------------------------- Did participants stop predicting?
# To check whether participants stopped predicting after some occurrences of ungrammatical items, we compare the response to the first
# and last 20 items of the first blocks.

# Import the list of randomizations
rand_df = read.csv("/data/p_02142/STUDY_FOLDER_SynPredTMSEEG/SynTMSEEG_13042019/28032019_presentation_randomizations_tms.txt", header = T, sep = "\t")
colnames(rand_df)[1] = "Subject"
rand_df = rand_df[rand_df$Subject < 34,] # removes values larger than 33
rand_df$Subject = as.factor(rand_df$Subject)
rand_df = rand_df[rand_df$Subject != "9" & rand_df$Subject!= "29" & rand_df$Subject!= "31" & 
                    rand_df$Subject!= "32",] # removes excluded subj or not tested (e.g.,32)
rand_df = droplevels(rand_df)
# Add session info
RTs_LMM = merge(rand_df, RTs_LMM, by = "Subject", all.x=TRUE, all.y=TRUE)
RTs_LMM$FilterFirstSession = 0;
RTs_LMM[RTs_LMM$TMS == RTs_LMM$First_TMS,"FilterFirstSession"] = 1

#  Filter trials
RTs_LMM$TrialNr = as.numeric(RTs_LMM$TrialNr) # convert RTs to numeric
RTs_LMM_analysis = RTs_LMM[RTs_LMM$TrialNr < 21 | RTs_LMM$TrialNr > 108,] # filter the number of trials of interest
RTs_LMM_analysis = RTs_LMM_analysis[RTs_LMM_analysis$Block == 1,] # select first block

# Add a factor coding for position in block
RTs_LMM_analysis$PositionInBlock = "Nan" # create a column for factor
RTs_LMM_analysis = droplevels(RTs_LMM_analysis)
RTs_LMM_analysis[RTs_LMM_analysis$TrialNr < 21,"PositionInBlock"] = "First20"
RTs_LMM_analysis[RTs_LMM_analysis$TrialNr > 108,"PositionInBlock"] = "Last20"
RTs_LMM_analysis$RTs = as.numeric(RTs_LMM_analysis$RTs)
RTs_LMM_analysis$LogRTs = log(RTs_LMM_analysis$RTs)
# Usual trial removal
RTs_LMM_analysis = RTs_LMM_analysis[RTs_LMM_analysis$RTs > 150 & RTs_LMM_analysis$RTs < 1000, ] # filter RTs
# Make a copy with only session 1 for future use
RTs_LMM_analysis_S01 = RTs_LMM_analysis[RTs_LMM_analysis$FilterFirstSession ==1,]

# check how many observations included
length(RTs_LMM_analysis[RTs_LMM_analysis$PositionInBlock == "First20" & RTs_LMM_analysis$Grammaticality == "grammatical", "RTs"])
length(RTs_LMM_analysis[RTs_LMM_analysis$PositionInBlock == "First20" & RTs_LMM_analysis$Grammaticality == "ungrammatical", "RTs"])
length(RTs_LMM_analysis[RTs_LMM_analysis$PositionInBlock == "Last20" & RTs_LMM_analysis$Grammaticality == "grammatical", "RTs"])
length(RTs_LMM_analysis[RTs_LMM_analysis$PositionInBlock == "Last20" & RTs_LMM_analysis$Grammaticality == "ungrammatical", "RTs"])

# Make factors
RTs_LMM_analysis$Subject = as.factor(RTs_LMM_analysis$Subject)
RTs_LMM_analysis$Grammaticality = as.factor(RTs_LMM_analysis$Grammaticality)
RTs_LMM_analysis$PositionInBlock = as.factor(RTs_LMM_analysis$PositionInBlock)
# Drop unused levels
RTs_LMM_analysis = droplevels(RTs_LMM_analysis)

# Contrasts
contrasts(RTs_LMM_analysis$PositionInBlock) = contr.sum
contrasts(RTs_LMM_analysis$Grammaticality) = contr.sum

# Run the model including all sessions
model_prediction = lmer(RTs ~ Grammaticality*PositionInBlock + (1|Subject), data = RTs_LMM_analysis)
anova(model_prediction)

ezANOVA_PosInBlock = ezANOVA(data = RTs_LMM_analysis, dv = RTs, wid = Subject, within = .(Grammaticality, PositionInBlock))


# First session only  <---------------
RTs_LMM_analysis_S01 = droplevels(RTs_LMM_analysis_S01)

RTs_LMM_analysis_S01$Subject = as.factor(RTs_LMM_analysis_S01$Subject)
RTs_LMM_analysis_S01$Grammaticality = as.factor(RTs_LMM_analysis_S01$Grammaticality)
RTs_LMM_analysis_S01$PositionInBlock = as.factor(RTs_LMM_analysis_S01$PositionInBlock)
RTs_LMM_analysis_S01$SecondWord = as.factor(RTs_LMM_analysis_S01$SecondWord)

# Contrasts
contrasts(RTs_LMM_analysis_S01$PositionInBlock) = contr.sum
contrasts(RTs_LMM_analysis_S01$Grammaticality) = contr.sum

#This down did not converge
#model_prediction_S01 = lmer(LogRTs ~ Grammaticality*PositionInBlock + (1+Grammaticality*PositionInBlock|Subject) + (1+Grammaticality*PositionInBlock|SecondWord), lmerControl(optimizer = "bobyqa"), data = RTs_LMM_analysis_S01, REML=T)

# This converged:
model_prediction_S01 = lmer(LogRTs ~ Grammaticality*PositionInBlock + (1+Grammaticality*PositionInBlock|Subject) + (1+Grammaticality+PositionInBlock|SecondWord), lmerControl(optimizer = "bobyqa"), data = RTs_LMM_analysis_S01, REML=T)
anova(model_prediction_S01)
ezANOVA_PosInBlock_S01 = ezANOVA(data = RTs_LMM_analysis_S01, dv = RTs, wid = Subject, within = .(Grammaticality, PositionInBlock))


# 3 ------------------------- DP and S interacted with the findings?
# Create a new factor
new_LMM_df$StructureType = "nan"
new_LMM_df[startsWith(new_LMM_df$TrialID, "d"), "StructureType"] = "DP"
new_LMM_df[startsWith(new_LMM_df$TrialID, "p"), "StructureType"] = "VP"
new_LMM_df$StructureType = as.factor(new_LMM_df$StructureType)

# Run LMM
#structure_full_LMM_neg = lmer(AmpNegativity ~ Grammaticality*StructureType*TMS + (1|Subject) + (1|SecondWord), data = new_LMM_df)
#anova(structure_full_LMM_neg)
#emm = emmeans(structure_full_LMM_neg, ~ StructureType*TMS, pbkrtest.limit = 20989) # https://stats.stackexchange.com/questions/331238/post-hoc-pairwise-comparison-of-interaction-in-mixed-effects-lmer-model
#pairs(emm)

# ANOVAS on ESN
# NegEzAnovaStruc = ezANOVA(data = new_LMM_df, dv = AmpNegativity, wid = Subject, within = .(Grammaticality, StructureType, TMS), return_aov = TRUE)
# 
# ag_data_neg = aggregate(new_LMM_df$AmpNegativity, 
#                         by=list(Subject = new_LMM_df$Subject, TMS = new_LMM_df$TMS, StructureType = new_LMM_df$StructureType, Grammaticality = new_LMM_df$Grammaticality),
#                             FUN=mean)
# colnames(ag_data_neg)[5] = "AmpNegativity"
# my_aov_NegStruct = aov(AmpNegativity ~ Grammaticality*TMS*StructureType + Error(Subject/(Grammaticality*TMS*StructureType)), ag_data_neg)
# summary(my_aov_NegStruct) # equivalent to ezANOVA
# 
# 
# 
# # ANOVAS on Positivity
# ag_data_pos = aggregate(new_LMM_df$AmpPositivity, 
#                         by=list(Subject = new_LMM_df$Subject, TMS = new_LMM_df$TMS, StructureType = new_LMM_df$StructureType, Grammaticality = new_LMM_df$Grammaticality),
#                         FUN=mean)
# colnames(ag_data_pos)[5] = "AmpPositivity"
# my_aov_PosStruct = aov(AmpPositivity ~ Grammaticality*TMS*StructureType + Error(Subject/(Grammaticality*TMS*StructureType)), ag_data_pos)
# summary(my_aov_PosStruct)
# ezANOVA(data = new_LMM_df, dv = AmpPositivity, wid = Subject, within = .(Grammaticality, StructureType, TMS))
# 

#save.image(file = "/data/p_02142/data_analysis_2020/bader_analysis/LMM_analysis_for_Reviewer1_RData.RData")

# convert to wide

#post_df_long = cast(ag_data_pos,  Subject ~ Grammaticality*TMS*StructureType, value = "AmpPositivity")
#write.table(post_df_long,"/data/p_02142/data_analysis_2020/bader_analysis/ag_pos_long.csv", row.names = FALSE, sep="\t")
# 
# 
# emm = emmeans(my_aov_PosStruct, ~ StructureType:TMS, adjust = "bonferroni")
# pairs(emm)
# boxplot(AmpPositivity~ TMS*StructureType, ag_data_pos)
# 
# 
# glht(structure_full_LMM_neg, linfct = mcp(StructureType:TMS= "Tukey"))
# TukeyHSD(res.aov3, which = "dose")
# 
# summary(glht(Lme.mod, linfct=mcp(x1="Tukey")))
# 
# multcomp
# 
# ##### BLOCK AND EEG
# new_LMM_df$Block = as.factor(new_LMM_df$Block)
# 
# full_LMM_neg_block = lmer(AmpNegativity ~ Grammaticality*TMS*Block + (1+TMS+Block|Subject) + (1+Grammaticality|SecondWord), data = new_LMM_df)
# anova(full_LMM_neg_block)
# 
# 
# full_LMM_pos_block = lmer(AmpPositivity ~ Grammaticality*TMS*Block + (1+TMS|Subject) + (1+Grammaticality|SecondWord), data = new_LMM_df)
# anova(full_LMM_pos_block)
# 
# # Only Block 1
# new_LMM_df_B1 = new_LMM_df[new_LMM_df$Block ==1,]
# B1_full_LMM_neg = lmer(AmpNegativity ~ Grammaticality*TMS + (1+TMS|Subject) + (1|SecondWord), data = new_LMM_df_B1)
# anova(B1_full_LMM_neg) # obtain p values with LmerTest
# 
# new_LMM_df_B2 = new_LMM_df[new_LMM_df$Block ==2,]
# B2_full_LMM_neg = lmer(AmpNegativity ~ Grammaticality*TMS + (1+TMS|Subject) + (1|SecondWord), data = new_LMM_df_B2)
# anova(B2_full_LMM_neg) # obtain p values with LmerTest
# 
# ## SPL BA44
# SPL_new_LMM_df = new_LMM_df[new_LMM_df$TMS != "sham",]
# SPL_LMM_neg = lmer(AmpNegativity ~ Grammaticality*TMS*Block + (1+TMS|Subject) + (1|SecondWord), data = SPL_new_LMM_df)
# anova(SPL_LMM_neg)
# 
# ## SHAM BA44
# sham_new_LMM_df = new_LMM_df[new_LMM_df$TMS != "SPL",]
# sham_LMM_neg = lmer(AmpNegativity ~ Grammaticality*TMS*Block + (1+TMS|Subject) + (1|SecondWord), data = sham_new_LMM_df)
# anova(sham_LMM_neg)
# 
# ## SHAM SPL
# sham_SPL_new_LMM_df = new_LMM_df[new_LMM_df$TMS != "BA44",]
# sham_SPL_LMM_neg = lmer(AmpNegativity ~ Grammaticality*TMS*Block + (1+TMS|Subject) + (1|SecondWord), data = sham_SPL_new_LMM_df)
# anova(sham_SPL_LMM_neg)

save.image(file = "/data/p_02142/data_analysis_2020/bader_analysis/LMM_analysis_for_Reviewer1_cont_sum_20220901.RData")

