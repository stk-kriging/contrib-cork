function vfit3_download ()

requirements = fileparts (mfilename ('fullpath'));

% Destination directory (where the archive will be unzipped)
dst_dir = fullfile (requirements, 'vfit3');

if exist (dst_dir, 'dir')
    error (sprintf ('Directory already exists: %s\n', dst)); %#ok<SPERR>
end

fprintf ('Downloading VFIT3... ');
url = 'https://www.sintef.no/globalassets/project/vectfit/vfit3.zip';
dst_zip = fullfile (requirements, 'vfit3.zip');
websave (dst_zip, url);

try
    here = pwd ();
    cd (requirements);

    % Try to get SHA1 using sha1sum
    cmd = 'sha1sum vfit3.zip | grep -o "^\S*"';
    [status, sha1] = system (cmd);
    if status == 0
        sha1 = lower (strtrim (sha1));
        sha1_ok = true;
    else
        % Try to get SHA1 using Get-FileHash
        cmd = [ ...
            'powershell -Command "Get-FileHash vfit3.zip ' ...
            '-Algorithm SHA1 | Format-List -Property Hash"' ];
        [status, sha1] = system (cmd);
        if status == 0
            sha1 = regexprep (lower (strtrim (sha1)), 'hash\s*:\s*', '');
            sha1_ok = true;
        else
            sha1_ok = false;
        end
    end

    cd (here);
catch e
    cd (here);
    rethrow (e);
end

if ~ sha1_ok
    vfit3_ver = '??? (vfit3.zip, failed version check, refer to vfit3.m)';
elseif strcmp (sha1, '69cd6fd926fa076b4ade40e45613b72f8f66587f')
    vfit3_ver = '1.0 (vfit3.zip, 2008-08-08)';
else
    vfit3_ver = '??? (vfit3.zip, unknown version, refer to vfit3.m)';
end

fid = fopen (fullfile (requirements, 'vfit3_version.txt'), 'w');
fprintf (fid, 'version %s', vfit3_ver);
fclose (fid);

fprintf ('Extracting... ');
unzip (dst_zip, dst_dir);

fprintf ('OK\n');

if status ~= 0
    warning ('Failed to run sha1sum, VFIT3 version could not be checked.')
end

end % function