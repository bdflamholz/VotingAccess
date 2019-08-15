clear all
close all
clc
% load('EAVS_2018_Table.mat')
% overallStruct=struct;
% % Jurisdiction_structs=cell(size(T,1)-1,1);
% for i=2:size(T,1)
% %     T.Var2{i}=strrep(T.Var2{i},' ','_');
% %     T.Var2{i}=strrep(T.Var2{i},'.','');
% %     T.Var2{i}=strrep(T.Var2{i},'-','_');
% %     T.Var2{i}=strrep(T.Var2{i},'(','_');
% %     T.Var2{i}=strrep(T.Var2{i},')','_');
% %     T.Var2{i}=strrep(T.Var2{i},"'",'');
% %     T.Var2{i}=strrep(T.Var2{i},'&','_');
%     T.Var1{i}=strcat('FIPS_',T.Var1{i});
%     overallStruct=setfield(overallStruct,T.Var1{i},struct);
%     for j=2:size(T,2)
%         cellName=table2cell(T(1,j));
%         fieldName=cellName{1};
%         cellVal=table2cell(T(i,j));
%         fieldVal=cellVal{1};
%         overallStruct=setfield(overallStruct,T.Var1{i},fieldName,fieldVal);
%     end
% end
% save('VotingAccessStruct','overallStruct')

load('VotingAccessStruct.mat');
stateStruct=struct;
jurisdictionCodes=fieldnames(overallStruct);
oldLabelArray={'A1a','A1b','A1c','A2a','A3a','A3b','A3c','A3d','A3e'};
newLabelArray={'totalRegisteredVoters','totalActiveVoters',...
               'totalInactiveVoters','totalNewSameDayRegistrations',...
               'totalRegistrationForms','newValidRegistrationForms',...
               'newPreRegistrationForms','duplicateRegistrationForms',...
               'invalidOrRejectedRegistrationForms'};
for i=1:length(jurisdictionCodes)
    stateStruct=singleIter(overallStruct,stateStruct,...
                        jurisdictionCodes{i},oldLabelArray,newLabelArray);
end


% populate percentages, intesive metrics, and densities
stateAbrs=fieldnames(stateStruct);

% run file to load 2016 presidential popular and electoral votes by state
% data and add these fields to the struct
addIn2016PresElecPopData;

for statei=1:length(stateAbrs)
    voters=getfield(stateStruct,stateAbrs{statei},'totalRegisteredVoters');
    numJs=getfield(stateStruct,stateAbrs{statei},'numJurisdictions');
    stateStruct=setfield(stateStruct,stateAbrs{statei},...
        'VotersPerJurisdiction',voters/numJs);
    
    registrationForms=getfield(stateStruct,stateAbrs{statei},'totalRegistrationForms');
    rejectedForms=getfield(stateStruct,stateAbrs{statei},'invalidOrRejectedRegistrationForms');
    stateStruct=setfield(stateStruct,stateAbrs{statei},'PercentageRejectedRegistrationForms',rejectedForms/registrationForms);
    
    sameDayReg=getfield(stateStruct,stateAbrs{statei},'totalNewSameDayRegistrations');
    stateStruct=setfield(stateStruct,stateAbrs{statei},'PercentageSameDayRegistrations',sameDayReg/registrationForms);
    
    if isfield(getfield(stateStruct,stateAbrs{statei}),'Total2016PresidentialTurnout')
        T2016PT=getfield(stateStruct,stateAbrs{statei},'Total2016PresidentialTurnout');
        TRV=getfield(stateStruct,stateAbrs{statei},'totalRegisteredVoters');
        trumpVotes=getfield(stateStruct,stateAbrs{statei},'TrumpVotes');
        clintonVotes=getfield(stateStruct,stateAbrs{statei},'ClintonVotes');
        thirdPartyVotes=getfield(stateStruct,stateAbrs{statei},'ThirdPartyPresidentialVoters');
        stateStruct=setfield(stateStruct,stateAbrs{statei},...
            'PercentageOfRegVotersWhoVoted',T2016PT/TRV);
        stateStruct=setfield(stateStruct,stateAbrs{statei},...
            'TrumpVotePercentage',trumpVotes/T2016PT);
        stateStruct=setfield(stateStruct,stateAbrs{statei},...
            'ClintonVotePercentage',clintonVotes/T2016PT);
        stateStruct=setfield(stateStruct,stateAbrs{statei},...
            'ThirdPartyVotePercentage',thirdPartyVotes/T2016PT);
    end
        
end

% run file to load 2019 state population and density data and add these 
% fields to the struct
addInDensityData;


function [mVal]=preCalc(overallStruct,code,oldLabel)
    mVal=str2num(getfield(overallStruct,code,oldLabel));
    if (((isempty(mVal)) || (mVal==-99)) || mVal==-88)
        mVal=0;
    end
end

function [mValVec]=preCalcAllVals(overallStruct,code,oldLabelArray)
    N=length(oldLabelArray);
    mValVec=zeros(1,N);
    for i=1:N
        mValVec(i)=preCalc(overallStruct,code,oldLabelArray{i});
    end
end
        

function [stateStruct]=addMetric(stateStruct,newLabel,stateAbr,mVal)
    stateStruct=setfield(stateStruct,stateAbr,newLabel,mVal);
end

function [stateStruct]=addAllMetrics(stateStruct,newLabelArray,stateAbr,mValVec)
    N=length(newLabelArray);
    for i=1:N
        stateStruct=addMetric(stateStruct,newLabelArray{i},stateAbr,mValVec(i));
    end
end

function [stateStruct]=augmentMetric(stateStruct,newLabel,stateAbr,mVal)
    mValPre=getfield(stateStruct,stateAbr,newLabel);
    stateStruct=setfield(stateStruct,stateAbr,newLabel,mVal+mValPre);
end

function [stateStruct]=augmentAllMetrics(stateStruct,newLabelArray,stateAbr,mValVec)
    N=length(newLabelArray);
    for i=1:N
        stateStruct=augmentMetric(stateStruct,newLabelArray{i},stateAbr,mValVec(i));
    end
end

function [stateStruct]=singleIter(overallStruct,stateStruct,code,...
                                  oldLabelArray,newLabelArray)
    stateAbr=getfield(overallStruct,code,'State_Abbr');
    stateName=getfield(overallStruct,code,'State_Full');
    mValVec=preCalcAllVals(overallStruct,code,oldLabelArray);
    if ~isfield(stateStruct,stateAbr)
        stateStruct=setfield(stateStruct,stateAbr,struct);
        stateStruct=setfield(stateStruct,stateAbr,'fullName',stateName);
        stateStruct=addAllMetrics(stateStruct,newLabelArray,stateAbr,mValVec);
        stateStruct=setfield(stateStruct,stateAbr,'numJurisdictions',1);
    else
        stateStruct=augmentAllMetrics(stateStruct,newLabelArray,stateAbr,mValVec);
        numJ=getfield(stateStruct,stateAbr,'numJurisdictions')+1;
        stateStruct=setfield(stateStruct,stateAbr,'numJurisdictions',numJ);
    end
end
    
    
