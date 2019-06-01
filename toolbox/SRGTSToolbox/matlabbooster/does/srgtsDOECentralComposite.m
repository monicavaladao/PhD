function CCD = srgtsDOECentralComposite(NDV, varargin)
%Function srgtsDOECentralComposite generates a central composite design (CCD).
%
% THIS FUNCTION USES THE NATIVE MATLAB FUNCTION: ccdesign of the native
% MATLAB Statistics Toolbox!
%
%Each row of the design represents one point (or sample). Design variables
%are normalized so that the hypercube points take values between 0 and 1.
%Thus, for example:
%
%     P = srgtsDOECentralComposite(NDV): generates an NPOINTS-by-NDV
%     matrix. NPOINTS is the number of points and NDV is the number of
%     variables.
%
%     NPOINTS = 2^NDV + 2*NDV + NCENTER
%
%     where NCENTER is the number of center points.
%
%     P = srgtsDOECentralComposite(NDV,'PNAME1',pvalue1,'PNAME2',pvalue2,...): 
%     allows you to specify additional parameters and their values. Valid
%     parameters are the following:
%   
%     Parameter    Value
%     'center'     The number of center points to include, or 'uniform'
%                  to select the number of center points to give uniform
%                  precision, or 'orthogonal' (the default) to give an
%                  orthogonal design.
%                  Default is 1.
%     'fraction'   Fraction of full factorial for cube portion expressed
%                  as an exponent of 1/2:  0 = whole design, 1 = 1/2
%                  fraction, 2 = 1/4 fraction, etc.
%                  Default is 0.
%     'type'       Either 'inscribed', 'circumscribed', or 'faced'.
%                  Default is 'circumscribed'.
%     'blocksize'  The maximum number of points allowed in a block.
%                  Default is Inf.
%
%Example:
%     % create a 9x2 design.
%     NDV = 2;
%
%     P = srgtsDOECentralComposite(NDV)
%
%     P =
% 
%          0         0
%          0    1.0000
%     1.0000         0
%     1.0000    1.0000
%    -0.2071    0.5000
%     1.2071    0.5000
%     0.5000   -0.2071
%     0.5000    1.2071
%     0.5000    0.5000

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Felipe A. C. Viana
% felipeacviana@gmail.com
% http://sites.google.com/site/felipeacviana
%
% This program is free software; you can redistribute it and/or
% modify it. This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% check for valid inputs
if NDV < 2
   error('SURROGATES Toolbox:srgtsDOECentralComposite:BadNumVariables',...
         'Number of variables must be at least 2.')
end

okargs = {'center' 'fraction' 'type' 'blocksize'};
defaults = {1 0 'circumscribed' Inf};

[eid, emsg, NCENTER, FRACTION, STARTYPE, BLOCKSIZE] = ...
    statgetargs(okargs,defaults,varargin{:});

if ~isempty(eid)
   error(sprintf('SURROGATES Toolbox:srgtsDOECentralComposite:%s',eid),emsg);
end

oktypes = {'circumscribed' 'inscribed' 'faced'};
if isempty(STARTYPE) | ~ischar(STARTYPE)
   i = [];
else
   i = strmatch(lower(STARTYPE), oktypes);
end

if isempty(i)
   error('SURROGATES Toolbox:srgtsDOECentralComposite:BadType',...
         'Valid types are ''inscribed'', ''circumscribed'', and ''faced''.');
end

STARTYPE = oktypes{i};

if BLOCKSIZE ~= Inf
   if ~isnumeric(BLOCKSIZE) | BLOCKSIZE<1 | BLOCKSIZE~=floor(BLOCKSIZE)
      error('SURROGATES Toolbox:srgtsDOECentralComposite:BadBlockSize',...
            'Value of ''BLOCKSIZE'' parameter must be a positive ingeger.');
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% create design
CCD = ccdesign(NDV, ...
    'center',    NCENTER, ...
    'fraction',  FRACTION, ...
    'type',      STARTYPE, ...
    'blocksize', BLOCKSIZE);

CCD = srgtsScaleVariable(CCD, ...
    [-ones(1, NDV); ones(1, NDV)], ...
    [zeros(1, NDV); ones(1, NDV)]);

return

function [eid,emsg,varargout]=statgetargs(pnames,dflts,varargin)
emsg = '';
eid = '';
nparams = length(pnames);
varargout = dflts;
unrecog = {};
nargs = length(varargin);

% Must have name/value pairs
if mod(nargs,2)~=0
    eid = 'WrongNumberArgs';
    emsg = 'Wrong number of arguments.';
else
    % Process name/value pairs
    for j=1:2:nargs
        pname = varargin{j};
        if ~ischar(pname)
            eid = 'BadParamName';
            emsg = 'Parameter name must be text.';
            break;
        end
        i = strmatch(lower(pname),pnames);
        if isempty(i)
            % if they've asked to get back unrecognized names/values, add this
            % one to the list
            if nargout > nparams+2
                unrecog((end+1):(end+2)) = {varargin{j} varargin{j+1}};
                
                % otherwise, it's an error
            else
                eid = 'BadParamName';
                emsg = sprintf('Invalid parameter name:  %s.',pname);
                break;
            end
        elseif length(i)>1
            eid = 'BadParamName';
            emsg = sprintf('Ambiguous parameter name:  %s.',pname);
            break;
        else
            varargout{i} = varargin{j+1};
        end
    end
end

varargout{nparams+1} = unrecog;
