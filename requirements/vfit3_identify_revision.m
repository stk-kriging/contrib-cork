function vfit3_identify_revision ()

requirements = fileparts (mfilename ('fullpath'));
vfit3_version_txt = fullfile (requirements, 'vfit3_version.txt');

if exist (vfit3_version_txt, 'file')
    try
        vfit3_version = fileread ('requirements/vfit3_version.txt');
    catch
        vfit3_version = 'version ??? (CORRUPTED vfit3_version.txt?)';
    end
else
    vfit3_version = 'version ??? (MISSING vfit3_version.txt)';
end

fprintf ('Using vfit3 %s\n', vfit3_version);

end % function
