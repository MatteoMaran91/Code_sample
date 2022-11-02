# -*- coding: utf-8 -*-
"""
Use this script to compare phonetic transcriptions of lists.
Generates a file containing ortographic and phonetic information of noun-inflected verb sets, with two phonetic disambiguation points:
DP2 (noun vs 2nd infl) and DP3 (noun vs 3rd infl).

Bug of second/third inflection fixed.

Version: 1.2
Created on March 29 2018
@author: Matteo Maran <maran@cbs.mpg.de>
"""
def compare_phonetics():

    import sys;
    import time;
    import re;
    date = time.strftime("%Y%m%d"); 
    time = time.strftime("%H%M"); # date and time allow unique filenames

# PRELIMINARY OPERATIONS
# Define working folder and files. The files have been generated copying the output of http://tom.brondsted.dk/text2phoneme/transcribeit.php
    work_fold = '/home/raid2/maran/The neural basis of merge/corpora/22_03/phonetics/';
    noun_file = work_fold + 'nouns_phonetics.txt';
    sec_infl_file = work_fold + '2nd_infl_phonetics.txt';
    trd_infl_file = work_fold + '3rd_infl_phonetics.txt';
    orig_list = '/home/raid2/maran/The neural basis of merge/corpora/22_03/N_V_umlaut_CONTROL_ultimate_list_201803221447.csv';
    output_file = work_fold + 'output_phonetics_' + date + '_' + time + '.txt';
    
# STORE FULL LINES OF FILES WITH PHONETICS.
# Store the lines of original file in three lists. Since each line ends with '\n', this character is then removed
    with open (noun_file, 'r+') as n_file:
        noun_info = n_file.readlines();     # store lines of n_file
        for n_ind in range(0, len(noun_info)):  # loop through stored lines
            noun_info[n_ind] = re.sub('\n$', '', noun_info[n_ind]); # and replace the new line character at the end of the line with nothing
    with open (sec_infl_file, 'r+') as sec_file:
        sec_info = sec_file.readlines();
        for sv_ind in range(0, len(sec_info)):
            sec_info[sv_ind] = re.sub('\n$', '', sec_info[sv_ind]);
    with open (trd_infl_file, 'r+') as trd_file:
        trd_info = trd_file.readlines();
        for tv_ind in range(0, len(trd_info)):
            trd_info[tv_ind] = re.sub('\n$', '', trd_info[tv_ind]);


# Check that there is no information missing, in that case stop script and return error message
    if not len(trd_info) == len (sec_info) == len(noun_info):
        sys.exit("ERROR: the original files have a different number of lines");

# TRANSFORM EACH  ELEMENT OF noun/sec/trd_info IN A LIST OF PHONEMES( [a, b, c d] -> [[a], [b], [c], [d]]), AND FIND THE DISAMBIGUATION
# POINTS, DP2_LIST (noun vs second inflection) and DP3_LIST (noun vs third inflection)

    noun_phon = [];
    sec_infl_phon = [];
    trd_infl_phon = [];
    DP_2_list = [];     # list of Disambiguation Point between 2nd infl and noun
    DP_3_list = [];     # list of DP between 3rd infl and noun 

# Store phonetic info as a list for each word. In this way, every word becomes a list of phonemes, which can then be compared.
# Splitting by space allows phonemes coded by more than a character (e.g. "a:") to be grouped together, since there is no space between them.

    for i in range (0, len(noun_info)):
        noun_phon.append(noun_info[i].split());  # append each element of noun_info split in a list
        sec_infl_phon.append(sec_info[i].split());
        trd_infl_phon.append(trd_info[i].split());

# STORE DISAMBIGUATION POINTS
# Loop through phonemes of each word and compared them between nouns and verb forms. Store to DP_2/3_list the disambiguation points.
    
    for h in range (0, len(noun_phon)):     # loop through different nouns and verb forms
        # Initialize an empty list of phonemes for current noun, second and third pers inflected verb
        c_noun_ph = [];     
        c_2V_ph = [];   
        c_3V_ph = [];
        # The two disambiguation points start as empty strings
        DP_n_2 = '';    # DP noun versus 2nd infl
        DP_n_3 = '';    # DP noun versus 3rd infl
        # Retrieve the list of phonemes of noun and seecon and third inflected verbs at h index
        c_noun_ph = noun_phon[h];       
        c_2V_ph = sec_infl_phon[h];     
        c_3V_ph = trd_infl_phon[h];   
        
        # Loop through the elements of the current noun and second infl verb lists of phonemes and compare them.
        # If they match, store to DP_n_2 and append to DP_2_list
        for ph2 in range (0, len(c_noun_ph)):       
            curr_n_ph = c_noun_ph[ph2];     # phoneme at position indexed by ph2 of noun
            curr_2V_ph = c_2V_ph[ph2];
            if curr_n_ph == curr_2V_ph:
                DP_n_2 = DP_n_2 + curr_n_ph + ' ';      # add current phoneme to disambiguation point string if they match
            else:
                DP_n_2 = re.sub('\s$', '', DP_n_2);        # remove last space at the end of DP
                DP_2_list.append(DP_n_2);               
                break;          # stop comparison when they no longer match (to avoid that matching phonemes after DP are not added to DP_n_2. E.g. in "ABC" vs "ACC", the DP_n_2 will be AB and not A_C)                        
        # Loop through the elements of the current noun and third infl verb lists of phonemes and compare them.
        # If they match, store to DP_n_3 and append to DP_3_list
        for ph3 in range (0, len(c_noun_ph)):       
            curr_n_ph = c_noun_ph[ph3];     
            curr_3V_ph = c_3V_ph[ph3];
            if curr_n_ph == curr_3V_ph:
                DP_n_3 = DP_n_3 + curr_n_ph + ' ';
            else:
                DP_n_3 = re.sub('\s$', '', DP_n_3);
                DP_3_list.append(DP_n_3);
                break;

# RETRIEVE ORIGINAL INFO ON ORTHOGRAPHY AND STORE IT TO A LARGE LIST OF LISTS [[first_noun, first_sec_infl, first_trd_infl], [second_noun, second_sec_infl, second_trd_infl] ...]
    ort_info = [];      # orthographic info. It is a list (one elem for each line) of lists (each of one has info on orthography of noun an two verbal forms)
    with open (orig_list, 'r+') as ort_info_file:
        ort_lines = ort_info_file.readlines();
        for ol in range (1, len(ort_lines)):         # starts from 1 in order to skipe the header
            curr_o_info = []; # List of ortographic info: here we will append first info on noun, then second infl and finallz third infl. Being a list makes it easier to retrieve the info for final output
            curr_ol = ort_lines[ol];
            curr_ol_split = curr_ol.split();        # split the line
            curr_noun_o = curr_ol_split[0];     # current noun ortographic info is at first column, second infl at 19th and third at 14th
            curr_2V_o = curr_ol_split[18];
            curr_3V_o = curr_ol_split[13];
            # For each line create a list containing the ortographic info
            curr_o_info.append(curr_noun_o);
            curr_o_info.append(curr_2V_o);
            curr_o_info.append(curr_3V_o);
            # Append the list to the larger list with ortographic of 
            ort_info.append(curr_o_info);
            
# PRINT TO FINAL FINLE
    header = 'NOUN_ORT' + '\t' + 'NOUN_PHON'+ '\t' + '2ND_ORT' + '\t' '2ND_PHON' + '\t' + '3RD_ORT' + '\t' '3RD_PHON' +  '\t' + 'DP_2ND' + '\t' + 'DP_3RD' + '\n';
    with open (output_file, 'a') as output:
        output.write(header);
        for w in range(0, len(noun_info)):
            curr_line = ort_info[w][0] + '\t' + noun_info[w] + '\t' +  ort_info[w][1] + '\t' + sec_info[w] + '\t' + ort_info[w][2] + '\t' + trd_info[w] + '\t' + DP_2_list[w] + '\t' + DP_3_list[w] + '\n';
            output.write(curr_line);  

# Start            
compare_phonetics()