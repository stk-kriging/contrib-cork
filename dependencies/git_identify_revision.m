function git_identify_revision (name)

here = pwd ();

depend_dir = fileparts (mfilename ('fullpath'));
repo = fullfile (depend_dir, name);

if ~ exist (repo, 'dir')
    error (sprintf ('Directory not found: %s\n', repo)); %#ok<SPERR>
end

try
    cd (repo);

    [~, sha1] = system ('git rev-parse --short HEAD');
    sha1 = strtrim (sha1);

    if isunix ()
        % Linux or Mac: filter through backquotes to remove special chars
        [~, commit_date] = system ('echo `git show -s --format=%ci HEAD`');
    else
        [~, commit_date] = system ('git show -s --format=%ci HEAD');
    end
    commit_date = strtrim (commit_date);

    cd (here);
catch e
    cd (here);
    rethrow (e);
end

fprintf ('Using %s revision %s (%s)\n', name, sha1, commit_date);

end % function
