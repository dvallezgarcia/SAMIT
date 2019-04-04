function samit_def = samit_defaults(atlas)
%   Load default values for SPM analysis of PET/SPECT in small animals
%   FORMAT samit_def = samit_defaults(atlas)
%       atlas     - Small animal atlas
%                  'Schwarz'    Rat Atlas (Default)
%                  'Ma'         Mouse Atlas
%       samit_def - Output variable with all the default parameters

%   Version: 19.03 (19 Mar 2019)
%   Author:  David V�llez Garcia
%   Email:   samit@umcg.nl

%   Tested with SPM8 & SPM12

%   Recommended Basal Plasma Glucose levels:
%       - Rat:  5.5 mmol/L


%% Atlas
if ~exist('atlas','var')
    error('Please, specify the desired animal atlas')
end

% Select atlas specific parameters
samit_def.dir                   = fileparts(which('samit'));

switch atlas
    case 'none'       
        samit_def.specie                = 'Non specified';
        samit_def.atlas                 = 'No reference atlas';
        samit_def.details               = 'No descrition';
        samit_def.mri 					= [];
        samit_def.mask 					= [];
        samit_def.stats.results.mipmat 	= [];
        samit_def.bregma                = spm_matrix([0 0 0]);
   
    otherwise    
        AtlasList = readtable('samit_atlases.txt', ...
                              'ReadVariableNames', true, ...
                              'Delimiter',',', ...
                              'Format','%s %s %s %s %s %s %s', ...
                              'CommentStyle',{'//'});

        [~, idx] = ismember(atlas,AtlasList.AtlasName);

        pathname = AtlasList.Folder{idx};       
        samit_def.specie                = AtlasList.Specie;
        samit_def.atlas                 = AtlasList.AtlasName;
        samit_def.details               = AtlasList.Details;
        samit_def.mri 					= fullfile(samit_def.dir,pathname,'templates',AtlasList.MRI{idx});
        samit_def.mask 					= fullfile(samit_def.dir,pathname,'mask',AtlasList.Mask{idx});
        samit_def.stats.results.mipmat 	= fullfile(samit_def.dir,pathname,'MIP.mat');
        samit_def.bregma                = spm_matrix(str2num(AtlasList.Bregma{idx}));
end

%% Define other common variables
% Normalise
samit_def.normalise.estimate.smosrc   = 0.8;
samit_def.normalise.estimate.smoref   = 0;
samit_def.normalise.estimate.regtype  = 'none';
samit_def.normalise.estimate.cutoff   = 25;
samit_def.normalise.estimate.nits     = 0;             % Avoid warp
samit_def.normalise.estimate.reg      = 0;
samit_def.normalise.estimate.graphics = 0;

samit_def.normalise.write.preserve   = 0;
samit_def.normalise.write.vox        = [0.2 0.2 0.2];  % Voxel size
samit_def.normalise.write.interp     = 1;              % Interpolation method
samit_def.normalise.write.wrap       = [0 0 0];        % Warping
samit_def.normalise.write.prefix	 = 'w';

% Check if it is correct
if isempty(samit_def.mri)
    bb = [-9.4000  -16.8000  -14.0000; 9.6000    7.0000    5.0000];
    vx = samit_def.normalise.write.vox;
else
    [bb, vx] = spm_get_bbox(samit_def.mri);
end

bb(2,:) = bb(2,:) + abs(vx);            % Correction for number of slides
samit_def.normalise.write.bb         = bb;

% Smooth
samit_def.smooth.fwhm  = [1.2 1.2 1.2];

% Co-registration
samit_def.coreg.estimate.cost_fun = 'nmi';
samit_def.coreg.estimate.sep      = [0.4 0.2];
samit_def.coreg.estimate.tol      = [0.002 0.002 0.002 0.0001 0.0001 0.0001 0.001 0.001 0.001 0.0001 0.0001 0.0001];
samit_def.coreg.estimate.fwhm     = [0.7 0.7];

samit_def.coreg.write.mask        = 0;
samit_def.coreg.write.mean        = 0;
samit_def.coreg.write.interp      = 1; %4
samit_def.coreg.write.which       = 1;
samit_def.coreg.write.wrap        = [0 0 0];
samit_def.coreg.write.prefix      = 'r';


%% Change dafault values in SPM
global defaults;
defaults.stats.results.mipmat   = samit_def.stats.results.mipmat;
defaults.smooth.fwhm            = samit_def.smooth.fwhm;
if isequal(spm('Ver'),'SPM12')
    defaults.old.normalise      = samit_def.normalise; 
else
    defaults.normalise          = samit_def.normalise; 
end
defaults.coreg                  = samit_def.coreg;
end