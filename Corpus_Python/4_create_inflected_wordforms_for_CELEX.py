# -*- coding: utf-8 -*-
"""
This script reads the merged output creaded by 'match_verb_noun_early_DP_21_03_2018.py', extracts the verbs
and inflects them.
Creates two output files, one for inflection at present tense 2nd singular and one for the 3rd singular,
to be used in wordform search in CELEX DB.

Version: 1.0
Created on March 23 2018
@author: Matteo Maran <maran@cbs.mpg.de>
"""
def create_inflected_wordforms_for_CELEX():
    
    import time;
    import re;
    date = time.strftime("%Y%m%d"); 
    time = time.strftime("%H%M"); # date and time allow unique filenames


# Define folders and files    
    corpora_fold = '/home/raid2/maran/The neural basis of merge/corpora/';
    merged_file = corpora_fold + 'nouns_verbs_matched_early_DP_20180321_1755.txt';
    output_file_3p = corpora_fold + '3p_inflected_verb_wordforms_' + date + '_' + time + '.txt';
    output_file_2p = corpora_fold + '2p_inflected_verb_wordforms_' + date + '_' + time + '.txt';
    
# Define expections for verb inflection
  #list_of_endings = ['den', 'ten', 'bnen', 'bmen', 'chnen', 'chmen', 'dnen', 'dmen', 'fnen', 'fmen', 'gnen', 'gmen', 'pnen', 'pmen', 'tnen', 'tmen'];
   #  http://www.thegermanprofessor.com/present-tense-verbs/    

# Create inflected wordforms http://www.thegermanprofessor.com/present-tense-verbs/
    with open (merged_file, 'r+') as merged_info:
        with open (output_file_3p, 'a+') as output_third:
            with open (output_file_2p, 'a+') as output_sec:
                lines = merged_info.readlines();
                for ln in range (1, len(lines)):
                    curr_line = lines[ln]
                    curr_line_split = curr_line.split();
                    verb_inf = curr_line_split[7];
                    third_infl = '';
                    sec_infl = '';
                    if re.search('[b-d,f-h,l-n,p-t,v-z][m,n]en$', verb_inf) or re.search ('[t,d]en$', verb_inf):
                        third_infl = re.sub('en$', 'et\n', verb_inf);
                        sec_infl = re.sub('en$', 'est\n', verb_inf);
                    elif re.search('ln$', verb_inf):
                        third_infl = re.sub('n$', 't\n', verb_inf);
                        sec_infl = re.sub('n$', 'st\n', verb_inf)                        
                    else:
                        third_infl = re.sub('en$', 't\n', verb_inf);
                        sec_infl = re.sub('en$', 'st\n', verb_inf);
                    output_third.write(third_infl);
                    output_sec.write(sec_infl);

                    
#
#OLD VERSION WITH NOT ALL EXPECTIONS 
## Create inflected wordforms
#    with open (merged_file, 'r+') as merged_info:
#        with open (output_file_3p, 'a+') as output_third:
#            with open (output_file_2p, 'a+') as output_sec:
#                lines = merged_info.readlines();
#                for ln in range (1, len(lines)):
#                    curr_line = lines[ln]
#                    curr_line_split = curr_line.split();
#                    verb_inf = curr_line_split[7];
#                    if verb_inf.endswith(tuple(list_of_endings)):
#                        third_infl = re.sub('en$','et\n', verb_inf);
#                        sec_infl = re.sub('en$','est\n', verb_inf);
#                    else:
#                        third_infl = re.sub('en$','t\n', verb_inf);
#                        sec_infl = re.sub('en$','st\n', verb_inf);
#                    output_third.write(third_infl);
#                    output_sec.write(sec_infl);
#                    
# Start program   
create_inflected_wordforms_for_CELEX()

 
 