# -*- coding: utf-8 -*-
"""
Starting from input_file, which is generated in STEP 6, 
2 for correct bigram sequences (first word capitalize and first word lower case)
2 for incorrect bigram sequences (first word capitalize and first word lower case)

Version: 1.0
Created on March 23 2018
@author: Matteo Maran <maran@cbs.mpg.de>
"""

def match_2nd_3rd_infl_files():
    
    import time;
    date = time.strftime("%Y%m%d"); 
    time = time.strftime("%H%M"); # date and time allow unique filenames

    folder = '/home/raid2/maran/The neural basis of merge/corpora/22_03/';
    input_file = folder + 'N_V_umlaut_CONTROL_ultimate_list_201803221447.csv';
    
    output_corr_lc = folder + 'Corr_Low_Case_list_of_bigrams_' + date + '.txt';
    output_corr_cap = folder + 'Corr_Cap_Case_list_of_bigrams_' + date + '.txt';
    output_inc_lc = folder + 'Inc_Low_Case_list_of_bigrams_' + date + '.txt';
    output_inc_cap = folder + 'Inc_Cap_Case_list_of_bigrams_' + date + '.txt';

    # Define first word
    first_word_lc = ['ein ', 'er ', 'du ']; # first letters lower case
    first_word_cap = ['Ein ', 'Er ', 'Du '];    # first letters capitalized

    with open (output_corr_lc, 'a+') as out_c_low:
        with open (output_corr_cap, 'a+') as out_c_cap:
            with open (output_inc_lc, 'a+') as out_i_low:
                with open (output_inc_cap, 'a+') as out_i_cap:
                    with open (input_file, 'r+') as input:
                        in_lines = input.readlines();
                        for il in range (1, len(in_lines)):
                            curr_il = in_lines[il];
                            curr_il_split = curr_il.split();
                            curr_noun = curr_il_split[0];
                            curr_2nd_v = curr_il_split[18];
                            curr_3rd_v = curr_il_split[13];
                            
                            # Correct first word lower case
                            out_c_low.write(first_word_lc[0] + curr_noun + '\n');
                            out_c_low.write(first_word_lc[1] + curr_3rd_v + '\n');
                            out_c_low.write(first_word_lc[2] + curr_2nd_v + '\n');
                            
                            # Correct first word capitalize
                            out_c_cap.write(first_word_cap[0] + curr_noun + '\n');
                            out_c_cap.write(first_word_cap[1] + curr_3rd_v + '\n');
                            out_c_cap.write(first_word_cap[2] + curr_2nd_v + '\n');
                            
                            # Incorrect first word lower case
                            out_i_low.write(first_word_lc[0] + curr_3rd_v + '\n');
                            out_i_low.write(first_word_lc[0] + curr_2nd_v + '\n');
                            out_i_low.write(first_word_lc[1] + curr_noun + '\n');  
                            out_i_low.write(first_word_lc[2] + curr_noun + '\n');
                            
                            # Incorrect first word capitalize
                            out_i_cap.write(first_word_cap[0] + curr_3rd_v + '\n');
                            out_i_cap.write(first_word_cap[0] + curr_2nd_v + '\n');
                            out_i_cap.write(first_word_cap[1] + curr_noun + '\n');  
                            out_i_cap.write(first_word_cap[2] + curr_noun + '\n');
                            
                        
                            
                            
#    
#    #first_words = ['Ein ', 'ein ', 'Er ', 'er ', 'Du ', 'du '];  
#    first_words_1 = ['Ein ', 'Er ', 'ein ', 'er '];
#    first_words_2 = ['Ein ', 'Du ', 'ein ', 'du '];
#    
#    with open (output_file_1, 'a') as output_1:
#        with open (output_file_2, 'a+') as output_2:
#            with open (input_file, 'r+') as input:
#                in_lines = input.readlines();
#                for il in range (1, len(in_lines)):
#                    curr_il = in_lines[il];
#                    curr_il_split = curr_il.split();
#                    curr_noun = curr_il_split[0];
#                    curr_2nd_v = curr_il_split[18];
#                    curr_3rd_v = curr_il_split[13];
#                    
#                    # output_file_1 will have only ein/er + noun/3rd pers sing
#                    for fw1 in first_words_1:
#                       output_1.write(fw1 + curr_noun + '\n');
#                       output_1.write(fw1 + curr_3rd_v + '\n');
#                       
#                    # output_file_2 will have only ein/du + noun/2nd pers sing
#                    for fw2 in first_words_2:
#                       output_2.write(fw2 + curr_noun + '\n');
#                       output_2.write(fw2 + curr_2nd_v + '\n');

# Start program   
match_2nd_3rd_infl_files()
                    
                    
                    
                    
    

