# -*- coding: utf-8 -*-
"""
Use this script to generate a set of potential infinitive forms starting from a selection of German nouns ending with 
'er' downloaded from CELEX. The infinitive forms have the following features:

1. Generally, they substitute 'er' with 'en';
2. If the noun ends with 'ler', it generates an additional potential verb ending in 'eln' (e.g. Bastler -> basteln);
3. If the noun ends with 'ner', it generates an additional potential verb with the 'n' dropped (e.g. Schuldner -> schulden);

If the output of this script is then uploaded to CELEX it is possible to check which of this infinitive forms exists.

Version: 1.0
Created on March 21 2018
@author: Matteo Maran <maran@cbs.mpg.de>
"""

def generate_potential_early_DP_verbs():
    
    import re;   
    import time;
    date = time.strftime("%Y%m%d"); 
    time = time.strftime("%H%M"); # date and time allow unique filenames


# Define folders and files    
    corpora_fold = '/home/raid2/maran/The neural basis of merge/corpora/';
    corp_nouns = corpora_fold + 'lemma_search_21_03_2018.txt';
    output_file = corpora_fold + 'potential_verbs_early_DP_' + date + '_' + time + '.txt';
    
# Create list of noun heads in corp_nouns
    nouns_list = [];    
    with open (corp_nouns, "r+") as c_nouns:
        n_lines = c_nouns.readlines();       
        for nl in range(1, len(n_lines)):					# loop through lines after header
            curr_nline = n_lines[nl];
            curr_nline = curr_nline.replace(",","\t")  # to avoid problems in splitting to columns because of , decimal separator 									        		
            curr_nline_split = curr_nline.split();
            curr_n_entry = curr_nline_split[0];
            curr_n_entry = curr_n_entry.decode("utf-8");        # for umlauts
            curr_n_entry = curr_n_entry.lower();    # turn into lower case
            nouns_list.append(curr_n_entry);
    nouns_list = set(nouns_list);   # remove duplicates
    nouns_list = sorted(nouns_list);    #arrange in alphabetical order
    
    
# Generate a file with potential verbs correspondng to the nouns of the corp_nouns, replacing 'er'
# with possible endings of infinitive verbs.
# This new file can then be uploaded to CELEX to see which verbs actually do exist
    with open (output_file, 'a+') as verb_file:
        for noun in nouns_list:
            line = '';
            verb = re.sub('er$', 'en', noun);
            line = verb + '\n';
            verb_file.write(line);
            if noun.endswith('ler'):
                verb_two = re.sub('ler$', 'eln', noun);                
                line_two = verb_two + '\n';
                verb_file.write(line_two);
            if noun.endswith ('ner'):
                verb_two = re.sub('ner$', 'en', noun);
                line_two = verb_two + '\n';
                verb_file.write(line_two);

        
                
        