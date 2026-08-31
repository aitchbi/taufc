function sts = chkexist(sess_v1, f, msg)

if exist(f,'file')

    sts = 1;

else

    sts = 0;
    
    fprintf('\n\n. %s file missing [session: %s]: %s\n\n', msg, sess_v1, f);
end
end
