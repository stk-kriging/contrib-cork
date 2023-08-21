here = pwd ();

project_root = fileparts (mfilename ('fullpath'));
cd (project_root);

% Base directory for dependencies
depend_dir = fullfile (project_root, 'dependencies');

% Add subdirectories to the path
addpath (fullfile (project_root, 'BenchmarkFunctions'));
addpath (fullfile (project_root, 'CplxGPR'));
addpath (fullfile (project_root, 'utils'));
addpath (depend_dir);


%% Download dependencies if needed

% Directory names for dependencies
chebfun_dir = fullfile (depend_dir, 'chebfun');
stk_dir     = fullfile (depend_dir, 'stk');
vfit3_dir   = fullfile (depend_dir, 'vfit3');

% Download chebfun if needed
if ~ exist (chebfun_dir, 'dir')
    git_clone_dependency ('chebfun', ...
        'https://github.com/chebfun/chebfun.git', ...
        'ce4abe767d530d139a60a0dcdb370a6537e1807e');
end

% Download STK if needed (lm-param branch from Niklas' fork)
if ~ exist (stk_dir, 'dir')
    git_clone_dependency ('stk', ...
        'https://github.com/n-georg/stk.git', ...
        '7431a607b4e6ec5f8a51a4a166d9b79be9e23ebc');
end

% Download VFIT3 if needed
if ~ exist (vfit3_dir, 'dir')
    vfit3_download ();
end


%% Initialize dependencies

% Initialize STK
run (fullfile (stk_dir, 'stk_init.m'));
git_identify_revision ('stk');

% Chebfun
addpath (genpath (chebfun_dir));
git_identify_revision ('chebfun');

% VFIT3
addpath (genpath (vfit3_dir));
vfit3_identify_revision ();

cd (here);

clear here project_root depend_dir chebfun_dir stk_dir vfit3_dir
