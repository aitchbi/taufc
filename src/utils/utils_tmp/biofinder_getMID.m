function [sess, scandate] = biofinder_getMID(ID,BF2,WhichSess,WhichData)

switch WhichData

    case 'Tau'
    
        tag = 'taupet';
    
    case 'Amy'
    
        tag = 'amypet';
    
    case 'RS'
    
        tag = 'reststate';
    
    case 'FS'
    
        tag = 'freesurfer';
end

row = find(BF2.(tag)(:,1)==ID);

scandate = BF2.(tag)(row,2+WhichSess);

if scandate==0

    fprintf('\n\n..No %s session %d [ID: %d] ---subject skipped.\n',...
        WhichData, WhichSess, ID);
    
    scandate = [];
    
    sess     = [];
    
    return;
end

sess = sprintf('BOF112_BioFINDER2_%d__%d', ID, scandate);
end