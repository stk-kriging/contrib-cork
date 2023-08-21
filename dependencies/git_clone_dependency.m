function git_clone_dependency (name, url, sha1)

depend_dir = fileparts (mfilename ('fullpath'));

% Destination directory (where the repo will be cloned)
dst = fullfile (depend_dir, name);

if exist (dst, 'dir')
    error (sprintf ('Directory already exists: %s\n', dst)); %#ok<SPERR>
end

fprintf ('Cloning %s... ', name);

try

    gitcmd = sprintf ('git clone %s %s', url, dst);
    evalc (sprintf ('[status, output] = system (''%s'')', gitcmd));
    if status ~= 0
        error ([ ...
            'git-clone failed with the following ' ...
            'error message:\n\n%s\n\n'], output);
    end

    here = pwd ();  cd (dst);

    gitcmd = sprintf ('git checkout %s', sha1);
    evalc (sprintf ('[status, output] = system (''%s'')', gitcmd));
    if status ~= 0
        error ([ ...
            'git-checkout failed with the following ' ...
            'error message:\n\n%s\n\n'], output);
    end

    cd (here);

catch e

    cd (here);

    % Remove partial/failed install
    if exist (dst, 'dir')
        rmdir (dst, 's');
    end

    rethrow (e);

end % try-catch

fprintf('OK\n');

end % function
