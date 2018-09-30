% University of British Columbia, Vancouver, 2017
%   Dr. Guy Nir
%   Shahriar Noroozi Zadeh
%   Amir Refaee
%   Lap-Tak Chu

clear; clc  %#ok<*UNRCH>

global TRAIN_PATH TEST_PATH  RESULTS_PATH;

TRAIN_PATH   = '../data/WMTrain/';

if exist('RunTimeInfo.txt', 'file')
        [oldPath,~] = RunTimeInformation([],[],'r',0,0,0);
end
[~, NumSVSslides, ~] = RunTimeInformation(TRAIN_PATH,TEST_PATH,'w',...
                                           256, 256, 1);

%feature Selection and pre-processing

%TRAINING DATA FEATURE EXTRACTION
processSlides = false;
if (processSlides)
    for i=1:NumSVSslides
        brain_slide_process;
    end
    %SaveFigures('/Train Slide Process');
end

%TEST DATA FEATURE EXTRACTION
processTestSlides = true;
if (processTestSlides)
    brain_slide_process_test;
    %SaveFigures('/Test Slide Process');
end


%classification
isTesting = true;
isTrained = false;
if isTesting

    %CREATE THE CLASSIFIER
    if ~isTrained
        brain_slide_train_test;
        isTrained = false; SaveResultsTesting;  %#ok<NASGU>
    end

    %CLASSIFIES THE TEST DATA
    brain_slide_classify_test;
    isTrained = true; SaveResultsTesting;
    %SaveMatFiles('test');
else
    %classification and cross-validation
    brain_slide_classify;
    SaveResults;
end

%save figures results
%SaveMatFiles('train');
%SaveFigures('/Slide Classification');

%make interface
isInterfacing = true;
if isInterfacing

    %CREATES DIRECTORY STRUCTURE
    InterfaceOutput;
end

delete('RunTimeInfo.txt');
