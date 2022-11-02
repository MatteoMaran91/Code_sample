# -*- coding: utf-8 -*-
"""
Use this script to compare two ratings for stimuli, present in work_fold

Version: 1.0
Created on April 04 2018
@author: Matteo Maran <maran@cbs.mpg.de>
"""

def rating_comparison():
    
    import re;
    # Define day and time for output name file
    import time;
    date = time.strftime("%Y%m%d"); 
    time = time.strftime("%H%M"); # date and time allow unique filenames
    
    # Define folders and files
    work_fold = '/home/raid2/maran/The neural basis of merge/stimuli_for_TMS/Lists_checked/files_for_comparison/';
    file_1 = work_fold + 'Matteo_Stimuli_Liste_Laura_N_03_04_2018.csv';
    file_2 = work_fold + 'Matteo_Stimuli_Liste_Lisa_K_04_04_2018.csv';
    output_file = work_fold + 'ratings_combined_' + date + '_' + time + '.txt';
    
    # Import lines of file 1
    with open (file_1, 'r+') as f1_file:        
        file1_info = f1_file.readlines();     # store lines of n_file

    for f1_l in range(0, len(file1_info)):  # loop through stored lines
        file1_info[f1_l] = re.sub('\n$', '', file1_info[f1_l]);
        file1_info[f1_l] = file1_info[f1_l].split();    # make each line a list
    file1_info.remove(file1_info[0]);       # remove header
    
    # Store backup file 1
    with open (file_1, 'r+') as f1_file:            # this contains full lines not split. Useful to print full line in case there is mismatch
        orig_f1 = f1_file.readlines();  
    for o1_l in range(0, len(orig_f1)):  # loop through stored lines
        orig_f1[o1_l] = re.sub('\n$', '', orig_f1[o1_l]);
    orig_f1.remove(orig_f1[0]); 
    
    
    # Import lines of file 2    
    with open (file_2, 'r+') as f2_file:
        file2_info = f2_file.readlines();     # store lines of n_file
        for f2_l in range(0, len(file2_info)):  # loop through stored lines
            file2_info[f2_l] = re.sub('\n$', '', file2_info[f2_l]);
            file2_info[f2_l] = file2_info[f2_l].split();    # make each line a list
    file2_info.remove(file2_info[0]);       # remove header
        
    # Store backup file 2   
    with open (file_2, 'r+') as f2_file:
        orig_f2 = f2_file.readlines();        
    for o2_l in range(0, len(orig_f2)):  # loop through stored lines
        orig_f2[o2_l] = re.sub('\n$', '', orig_f2[o2_l]);
    orig_f2.remove(orig_f2[0]);

     # Check if they contain the same amount of info
    if len(file1_info) != len(file2_info):
        print ('ERROR: the two files contain different amount of information');
    
    # Create header for output
    header = 'Noun\t3rd_infl\t2nd_infl\tRemove\tObject\tProfession\tQuality\n';
        
    # Compare and print
    with open (output_file, 'a') as output:
        output.write(header);
        for l in range (0, len(file1_info)):
                f1_line = file1_info[l]
                f2_line = file2_info[l];
                if f1_line[0] != f2_line[0] or f1_line[1] != f2_line[1] or f1_line[2] != f2_line[2]:
                    line2print = orig_f1[l] + '\n' + orig_f2[l] + '\n';
                    line2print = line2print.decode('utf8').upper();
                    line2print = line2print.encode('utf8');
                else:                                      
                    remove_vl = str(int(float(f1_line[3]) + float(f2_line[3])));
                    object_vl = str(int(float(f1_line[4]) + float(f2_line[4])));
                    profes_vl = str(int(float(f1_line[5]) + float(f2_line[5])));
                    qualit_vl = str(int(float(f1_line[6]) + float(f2_line[6])));
                    line2print = f1_line[0] + '\t' + f1_line[1] + '\t' + f1_line[2] + '\t' + remove_vl + '\t' + object_vl + '\t' + profes_vl + '\t' + qualit_vl + '\n'; 
                output.write(line2print);                  
                
