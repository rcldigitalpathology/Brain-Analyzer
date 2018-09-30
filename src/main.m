% University of British Columbia, Vancouver, 2017
%   Alex Kyriazis
%   William Choi

% To start analysis just run this file and select the desired options.
% 
% Once you've selected the options, it will prompt for a slide or a folder 
% of slides to analyze.
%
% Next, it will prompt for the location to save the post-analysis output
% file(s) and in the case of single slide analysis, the output file name.
%
% Once the program is done running, you will notice that the output file(s)'s
% been created. If you want to visualize the results, run GUI/main.m and
% choose the analysis output file when prompted.  

run('init.m');

process_type_text = {'Select single file','Select folder for batch processing'};
process_data_text = {'Analyze only count', 'Analyze count and morphology'};

process_type = listdlg('PromptString','Select an Option:','SelectionMode','single','ListString',process_type_text,'ListSize',[200 100]);
process_data = listdlg('PromptString','Select an Option:','SelectionMode','single','ListString',process_data_text,'ListSize',[200 100]);

if isempty(process_type) || isempty(process_data)
    error('Select an option');
end

if process_data == 1
    analysis_type = 1;
elseif process_data == 2 
    analysis_type = 0;    
end

if process_type==1
  %select single file
    Pipeline.pathology_analysis(analysis_type)
else
  %select folder for batch analysis
    Pipeline.batch_pathology_analysis(analysis_type)
end