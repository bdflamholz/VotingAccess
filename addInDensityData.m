% stateDensityTable2019=readtable('StateDensityData2019.csv');
% save('stateDensityTable2019','stateDensityTable2019');
load('stateDensityTable2019.mat');

densityVec=[];
VotersPerJurisdiction=[];
stateAbrsArray={};
PercentageRejectedRegistrationForms=[];
TrumpVotePercentage=[];
ClintonVotePercentage=[];
ThirdPartyVotePercentage=[];
SameDayRegistrationPercentage=[];
% stateSubStructs={};

for statei=1:length(stateAbrs)
    stateSubStructi=getfield(stateStruct,stateAbrs{statei});
    stateNamei=getfield(stateStruct,stateAbrs{statei},'fullName');
    if any(strcmpi(stateDensityTable2019.State,stateNamei))
        tableIndex=find(strcmpi(stateDensityTable2019.State,stateNamei)==1);
        pop=stateDensityTable2019.Pop(tableIndex);
        density=stateDensityTable2019.Density(tableIndex);
    else
        pop='Unlisted';
        density='Unlisted';
    end
    stateStruct=setfield(stateStruct,stateAbrs{statei},'Population',pop);
    stateStruct=setfield(stateStruct,stateAbrs{statei},'Density',density);
    
    if isnumeric(density)
%         stateSubStructs{end+1}=stateSubStructi;
        densityVec=[densityVec; density];
        vPJ=getfield(stateStruct,stateAbrs{statei},'VotersPerJurisdiction');
        sDR=getfield(stateStruct,stateAbrs{statei},'PercentageSameDayRegistrations');
        VotersPerJurisdiction=[VotersPerJurisdiction; vPJ];
        stateAbrsArray{end+1,1}=stateAbrs{statei};
        PRRF=getfield(stateStruct,stateAbrs{statei},'PercentageRejectedRegistrationForms');
        PercentageRejectedRegistrationForms=[PercentageRejectedRegistrationForms; PRRF];
        TrumpVotePerc=getfield(stateStruct,stateAbrs{statei},'TrumpVotePercentage');
        ClintonVotePerc=getfield(stateStruct,stateAbrs{statei},'ClintonVotePercentage');
        ThirdPartyVotePerc=getfield(stateStruct,stateAbrs{statei},'ThirdPartyVotePercentage');
        TrumpVotePercentage=[TrumpVotePercentage; TrumpVotePerc];
        ClintonVotePercentage=[ClintonVotePercentage; ClintonVotePerc];
        ThirdPartyVotePercentage=[ThirdPartyVotePercentage; ThirdPartyVotePerc];
        SameDayRegistrationPercentage=[SameDayRegistrationPercentage;sDR];
    end
        
end

TFS=35; % title font size
axisFS=35; % axis font size
textFS=30; % plot text font size
circleSize=100;


stateTable=table(stateAbrsArray,densityVec,VotersPerJurisdiction,...
    PercentageRejectedRegistrationForms,TrumpVotePercentage,...
    ClintonVotePercentage,ThirdPartyVotePercentage,SameDayRegistrationPercentage);

figure()
scatter(densityVec,VotersPerJurisdiction)
xlabel('Density (people/square mile)')
ylabel('Voters Per Jurisdiction')



indicesRej=find(~isnan(stateTable.PercentageRejectedRegistrationForms)&~isinf(stateTable.PercentageRejectedRegistrationForms));
PercentageRejectedRegistrationForms=PercentageRejectedRegistrationForms(indicesRej);

R1=corrcoef(SameDayRegistrationPercentage(indicesRej),PercentageRejectedRegistrationForms);
figure()
t=0:0.05:0.45;
avgRejected=mean(PercentageRejectedRegistrationForms)*ones(1,length(t));
scatter(SameDayRegistrationPercentage(indicesRej),PercentageRejectedRegistrationForms,circleSize,'filled')
text(0.25, 0.15, strcat('Correlation Coeff: R = ', num2str(R1(1,2))),'FontSize',textFS)
title('Percentage of Same Day Registrations Vs. Percentage of Rejected Registrations (by State)', 'FontSize', TFS)
xlabel('State Same Day Registrations as a Percentage of Total Registrations','FontSize',axisFS)
ylabel('State Percentage of Rejected Registrations','FontSize',axisFS)
hold on 
plot(t,avgRejected,'g','LineWidth',3)
text(0.2, 0.027, 'Mean Rejection Rate','Color','green','FontSize',textFS)
text(0.005, 0.23, 'Kentucky','Color','red','FontSize',textFS)
text(0.005, 0.11, 'Pennsylvania','Color','blue','FontSize',textFS)

figure()
R2=corrcoef(TrumpVotePercentage(indicesRej),PercentageRejectedRegistrationForms);
scatter(PercentageRejectedRegistrationForms,TrumpVotePercentage(indicesRej),circleSize)
text(0.125, 0.4, strcat('Correlation Coeff: R = ', num2str(R2(1,2))),'FontSize',textFS)
title('Percentage of Rejected Registrations Vs. Percentage of Vote Received by Trump (by State)', 'FontSize', TFS)
xlabel('State Percentage of Rejected Registrations','FontSize',axisFS)
ylabel('State Percentage of Vote Received by Trump','FontSize',axisFS)

figure()
R3=corrcoef(ClintonVotePercentage(indicesRej),PercentageRejectedRegistrationForms);
scatter(PercentageRejectedRegistrationForms,ClintonVotePercentage(indicesRej),circleSize)
text(0.125, 0.6, strcat('Correlation Coeff: R = ', num2str(R3(1,2))),'FontSize',textFS)
title('Percentage of Rejected Registrations Vs. Percentage of Vote Received by Clinton (by State)', 'FontSize', TFS)
xlabel('State Percentage of Rejected Registrations','FontSize',axisFS)
ylabel('State Percentage of Vote Received by Clinton','FontSize',axisFS)