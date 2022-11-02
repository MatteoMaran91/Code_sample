# -*- coding: utf-8 -*-
"""
This file matches each infinitive form actually existing (as found out by in STEP 2, giving the output 'new_lemma_match_verbs_early_DP_21_03.txt)
with the original nouns from which the potential infinitive forms were generated (in STEP 1)

It returns a merged_file with info on both noun and respective infinitive form info.

Version: 1.1
Created on March 23 2018
@author: Matteo Maran <maran@cbs.mpg.de>
"""

def match_verb_noun_early_DP_21_03_2018():
    
    import re;
    import time;
    date = time.strftime("%Y%m%d"); 
    time = time.strftime("%H%M"); # date and time allow unique filenames


# Define folders and files    
    corpora_fold = '/home/raid2/maran/The neural basis of merge/corpora/';
    nouns_file = corpora_fold + 'lemma_search_21_03_2018.txt';
    verbs_file = corpora_fold + 'new_lemma_match_verbs_early_DP_21_03.txt';   
    merged_file = corpora_fold + 'nouns_verbs_matched_early_DP_' + date + '_' + time + '.txt';
    
    
# Create list of verbs heads in verbs_file. IMPORTANT: CHECK THAT THERE IS A HEADER IN VERBS FILE 
    verb_list = [];    
    with open (verbs_file, "r+") as verbs_head:
        v_lines = verbs_head.readlines();       
        for vli in range(1, len(v_lines)):					# loop through lines after header
            curr_vline = v_lines[vli];
            curr_vline = curr_vline.replace(",","\t")  # to avoid problems in splitting to columns because of , decimal separator 									        		
            curr_vline_split = curr_vline.split();
            curr_v_entry = curr_vline_split[0];
            curr_v_entry = curr_v_entry.decode("utf-8");        # for umlauts
            curr_v_entry = curr_v_entry.lower();    # turn into lower case
            verb_list.append(curr_v_entry);
    verb_list = set(verb_list);   # remove duplicates
    verb_list = sorted(verb_list);    #arrange in alphabetical order
    

# Loop through verb_list, generate a potential corresponding noun and look for match.
# Different 'if' statements are present, according to how infinitive form and corresponding noun might differ
# Then add both lines to an element of matched_pairs list.
    matched_pairs = [];
    with open (nouns_file, 'r+') as noun_head:
        n_lines = noun_head.readlines();
        for verb in verb_list:
            match = 0;
            # 1. GENERAL RULE: 'EN' -> 'ET'
            if verb.endswith('en') and match == 0:
                noun_target = re.sub('en$', 'er', verb);
                noun_target = noun_target.capitalize();
                for nli in range(1, len(n_lines)):
                    curr_nline = n_lines[nli];
                    curr_nline = curr_nline.replace(",","\t")  # to avoid problems in splitting to columns because of , decimal separator 									        		
                    curr_nline_split = curr_nline.split();
                    curr_n_entry = curr_nline_split[0];
                    curr_n_entry = curr_n_entry.decode("utf-8");
                    if curr_n_entry == noun_target:
                        curr_pair = noun_target + '\t' + verb;
                        matched_pairs.append(curr_pair);
                        match = 1;
                        break # stop if match found, and go to next verb   
            # 2. VERBS WHOSE INFINITIVE END IN 'ELN'. The respective noun should end with 'LER'
            if verb.endswith('eln') and match == 0:
                noun_target = re.sub('eln$', 'ler', verb);
                noun_target = noun_target.capitalize();
                for nli in range(1, len(n_lines)):
                    curr_nline = n_lines[nli];
                    curr_nline = curr_nline.replace(",","\t")  # to avoid problems in splitting to columns because of , decimal separator 									        		
                    curr_nline_split = curr_nline.split();
                    curr_n_entry = curr_nline_split[0];
                    curr_n_entry = curr_n_entry.decode("utf-8");
                    if curr_n_entry == noun_target:
                        curr_pair = noun_target + '\t' + verb;
                        matched_pairs.append(curr_pair);
                        match = 1;
                        break;  
            # 3. IF MATCH STILL TO BE FOUND, IT MUST BE ONE OF THE CASES DROPPING A BEFORE ENDING 'N' AT THE INFINTIIVE FORM (like schulden - schuldner)            
            if match == 0:
                noun_target = re.sub('en$', 'ner', verb);
                noun_target = noun_target.capitalize();
                for nli in range(1, len(n_lines)):
                    curr_nline = n_lines[nli];
                    curr_nline = curr_nline.replace(",","\t")  # to avoid problems in splitting to columns because of , decimal separator 									        		
                    curr_nline_split = curr_nline.split();
                    curr_n_entry = curr_nline_split[0];
                    curr_n_entry = curr_n_entry.decode("utf-8");
                    if curr_n_entry == noun_target:
                        curr_pair = noun_target + '\t' + verb;
                        matched_pairs.append(curr_pair);
                        match = 1;
                        break;
        noun_head.close();        

# Now we actually need to find put together the whole info from original files
    with open (verbs_file, 'r+') as verb_head:
        v_lines = verb_head.readlines();
    verb_head.close();

# Create headers and print to merged_file    
    verb_header = v_lines[0];
    noun_header = n_lines[0];
    noun_header = re.sub('\n$','\t', noun_header);
    output_header = noun_header + verb_header; # no tab needed since it is already in the headers
 
# Print header and merged info   
    with open (merged_file, 'a') as output_file:
        output_file.write (output_header);
        for pair in matched_pairs:
            curr_pairs_split = pair.split();
            curr_noun = curr_pairs_split[0];
            curr_verb = curr_pairs_split[1];
            for nl in n_lines:
                n_pattern = curr_noun + '\t';
                if nl.startswith(n_pattern):
                    noun_info = re.sub('\n$','\t',nl);    # replace new line at the end with tab to concatenate with verb info
                    break;
            for vl in v_lines:
                v_pattern = curr_verb + '\t';
                if vl.startswith(v_pattern):
                    verb_info = vl;
                    break
            line_for_output = noun_info + verb_info;
            output_file.write(line_for_output);
        
    
    
                
                    