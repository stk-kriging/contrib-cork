function vfit3_identify_revision ()

depend_dir = fileparts (mfilename ('fullpath'));
vfit3_version_txt = fullfile (depend_dir, 'vfit3_version.txt');

if exist (vfit3_version_txt, 'file')
    try
        vfit3_version = fileread (vfit3_version_txt);
    catch
        vfit3_version = 'version ??? (CORRUPTED vfit3_version.txt?)';
    end
else
    vfit3_version = 'version ??? (MISSING vfit3_version.txt)';
end

fprintf ('Using vfit3 %s\n', vfit3_version);

end % function
