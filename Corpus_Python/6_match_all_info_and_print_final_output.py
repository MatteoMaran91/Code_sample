# -*- coding: utf-8 -*-
"""
This script generates the final output for stimuli selection.

It first matches the two respective inflected forms (second and third pers for each verb), and then combines this info with the
respective noun and infinitive form from which they were derived.

Currently it prints to the final output only the bisillabic noun-verb pairs, with a pattern accent matching 10.


Version: 1.0
Created on March 23 2018
@author: Matteo Maran <maran@cbs.mpg.de>
"""
def match_2nd_3rd_infl_files():
    
    import time;
    import re;
    date = time.strftime("%Y%m%d"); 
    time = time.strftime("%H%M"); # date and time allow unique filenames

    folder = '/home/raid2/maran/The neural basis of merge/corpora/22_03/';
    sec_file = folder + '2p_inflected_matches_22_03_CORR.txt';
    third_file = folder + '3p_inflected_matches_22_03_CORR.txt';
    output_file = folder + 'merged_inflected_info_bisillabic_' + date + '_' + time + '.txt';
    
    original_noun_file = folder + 'nouns_verbs_matched_early_DP_20180321_1755.txt';     # file with the nouns and original infinitive forms
    ultimate_list = folder + 'ultimate_list_' + date + time + '.txt';       # final output with both nouns, verb inf, 2nd and 3rd pers pres infl

# Store lines of each file, remove duplicates and sort them
    sec_infl_lines = [];
    with open (sec_file, 'r+') as sec_infl_info:
        sec_lines = sec_infl_info.readlines();
        for sl in range(1, len(sec_lines)):
            curr_sl_line = sec_lines[sl];
            sec_infl_lines.append(curr_sl_line);
    sec_infl_lines = set(sec_infl_lines);
    sec_infl_lines = sorted(sec_infl_lines);
    
    third_infl_lines = [];
    with open (third_file, 'r+') as third_infl_info:
        third_lines = third_infl_info.readlines();
        for tl in range(1, len(third_lines)):
            curr_tl_line = third_lines[tl];
            third_infl_lines.append(curr_tl_line);
    third_infl_lines = set(third_infl_lines);
    third_infl_lines = sorted(third_infl_lines);
    
    
    
# Match 2nd and 3rd person inflected forms, append to merged_info only bysillabic verbs with accent to first word
    merged_info = [];
    for third_line in third_infl_lines: # loop through third infl verb forms
        line2print = '';
        str_pat = '';
        potential_sec_match = '';
        curr_tl_split = third_line.split();
        str_pat = curr_tl_split[1];
        if str_pat == '10':         # 10 = pattern of accent with first syllable accented 
            curr_third_entry = curr_tl_split[0];
            potential_sec_match = re.sub('t$', 'st', curr_third_entry);     #$ in regexp indicates the end of the word
            curr_third_info = re.sub('\n$', '\t', third_line);
            for sec_line in sec_infl_lines:         # search the respective second inflected form
                curr_sl_split = sec_line.split();
                curr_sec_entry = curr_sl_split[0];
                if curr_sec_entry == potential_sec_match:
                    line2print = curr_third_info  + sec_line;
                    break;
                else:
                        line2print = curr_third_info + '\n';
            merged_info.append(line2print);    

# THIS PRINTS ALSO MONOSYLLABLES            
#    merged_info = [];
#    for third_line in third_infl_lines:
#        line2print = '';
#        potential_sec_match = '';
#        curr_tl_split = third_line.split();
#        curr_third_entry = curr_tl_split[0];
#        potential_sec_match = re.sub('t$', 'st', curr_third_entry);
#        curr_third_info = re.sub('\n$', '\t', third_line);
#        for sec_line in sec_infl_lines:
#            curr_sl_split = sec_line.split();
#            curr_sec_entry = curr_sl_split[0];
#            if curr_sec_entry == potential_sec_match:
#                line2print = curr_third_info  + sec_line;
#                break;
#            else:
#                line2print = curr_third_info + '\n';
#        merged_info.append(line2print);
 
# Create a header and print info of only inflected forms       
    third_header = re.sub('\n$', '\t', third_lines[0])
    sec_header = sec_lines[0];
    header = third_header + sec_header;
   
    with open (output_file, 'a') as output:
        output.write(header);        
        for info in merged_info:
            output.write(info);
    
# Merge info with original info (from file with both nouns and infinitive form)
    original_info = [];
    with open (original_noun_file, 'r+') as original_noun:
        original_lines = original_noun.readlines();
        for oi in range (1, len(original_lines)):
            curr_oi = original_lines[oi];
            curr_oi = curr_oi.replace('.','');
            original_info.append(curr_oi)
            
# Create a final list with both 1. Nouns 2. Inf form 3. third pers infl and 4. second pers infl
    final_merged_output = [];
    for mi in merged_info:      # no header in merged_info
       mi_split = mi.split();
       curr_mi_verb = mi_split[0];
       for orig_in in original_info:
           curr_or_split = orig_in.split();
           curr_verb_inf = curr_or_split[7];
           # Recreate from infinitive form the third infl person, which should match in merged_info
           if re.search('[b-d,f-h,m-n,p-t,v-z][m,n]en$', curr_verb_inf) or re.search ('[t,d]en$', curr_verb_inf):
               third_infl = re.sub('en$', 'et', curr_verb_inf);
           elif re.search('ln$', curr_verb_inf):
               third_infl = re.sub('n$', 't', curr_verb_inf);
           else:
               third_infl = re.sub('en$', 't', curr_verb_inf);
                   
           if curr_mi_verb == third_infl:
              orig_2_print = re.sub('\n$', '\t', orig_in);
              final_info_2_print = orig_2_print + mi;
              final_merged_output.append(final_info_2_print);
    
# Print final output
    orig_header = original_lines[0];
    orig_header = re.sub('\n$', '\t', orig_header);
    final_header = orig_header + header;
    with open (ultimate_list, 'a') as ult_output:
        ult_output.write(final_header);
        for final_in in final_merged_output:
            ult_output.write(final_in);
    
        
                   


                   
            
               
    
    
    