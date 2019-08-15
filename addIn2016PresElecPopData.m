% save('PresElectoralAndPopularVoteData2016','PresElectoralAndPopularVoteData2016')
load('PresElectoralAndPopularVoteData2016.mat');

for si=1:length(stateAbrs)
    if any(strcmpi(PresElectoralAndPopularVoteData2016.STATE,stateAbrs{si}))
        sIndex=find(strcmpi(PresElectoralAndPopularVoteData2016.STATE,stateAbrs{si})==1);
        TrumpElectors=PresElectoralAndPopularVoteData2016.ELECTORALVOTE(sIndex);
        if isnan(TrumpElectors)
            TrumpElectors=0;
        end
        ClintonElectors=PresElectoralAndPopularVoteData2016.ELECTORALVOTE1(sIndex);
        if isnan(ClintonElectors)
            ClintonElectors=0;
        end
        TrumpVotes=PresElectoralAndPopularVoteData2016.POPULARVOTE(sIndex);
        ClintonVotes=PresElectoralAndPopularVoteData2016.POPULARVOTE1(sIndex);
        ThirdPartyPresidentialVoters=...
                  PresElectoralAndPopularVoteData2016.POPULARVOTE2(sIndex);
        Total2016PresidentialTurnout=PresElectoralAndPopularVoteData2016.POPULARVOTE3(sIndex);
        
        stateStruct=setfield(stateStruct,stateAbrs{si},'TrumpElectors',TrumpElectors);
        stateStruct=setfield(stateStruct,stateAbrs{si},'ClintonElectors',ClintonElectors);
        stateStruct=setfield(stateStruct,stateAbrs{si},'TrumpVotes',TrumpVotes);
        stateStruct=setfield(stateStruct,stateAbrs{si},'ClintonVotes',ClintonVotes);
        stateStruct=setfield(stateStruct,stateAbrs{si},...
              'ThirdPartyPresidentialVoters',ThirdPartyPresidentialVoters);
        stateStruct=setfield(stateStruct,stateAbrs{si},...
              'Total2016PresidentialTurnout',Total2016PresidentialTurnout);
    end
end
        
