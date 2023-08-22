function b_toplevel = git_check_toplevel (repo)

if ~ exist (repo, 'dir')
    error (sprintf ('Directory not found: %s\n', repo)); %#ok<SPERR>
end

here = pwd ();

try
    cd (repo);  d1 = pwd ();

    [~, toplevel] = system ('git rev-parse --show-toplevel');
    toplevel = strtrim (toplevel);

    cd (toplevel);  d2 = pwd ();

    cd (here);
catch e
    cd (here);
    rethrow (e);
end

b_toplevel = strcmp (d1, d2);

end % function
