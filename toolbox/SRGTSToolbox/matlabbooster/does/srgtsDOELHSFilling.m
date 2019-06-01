function DOELHD = srgtsDOELHSFilling(DOE,NbLHPoints,varargin)
%Function srgtsDOELHSFilling fills a user-defined design with a Latin
%hypercube design.
%Each row of the design represents one point (or sample). Design variables
%are normalized so that the hypercube points take values between 0 and 1.
%Thus, for example:
%
%     P = srgtsDOELHSFilling(DOE, NLHPOINTS): fills the initial DOE design
%     with a Latin hypercube sample of NLHPOINTS points.
%
%     P = srgtsDOELHSFilling(DOE, NLHPOINTS, 'PARAM1', val1, 'PARAM2', val2,...):
%     specifies parameter name/value pairs to control the sample generation.
%     Valid parameters are the following:
%
%        Parameter    Value
%        'smooth'     'on' (default) to produce points as above, or 'off' to
%                     produces points at the midpoints of the above intervals:
%                     0.5/N, 1.5/N, ..., 1-.5/N.
%        'iterations' The maximum number of iterations to perform in an
%                     attempt to improve the design (default=5)
%        'criterion'  The criterion to use to measure design improvement,
%                     chosen from 'maximin' (default) to maximize the minimum
%                     distance between points, 'correlation' to reduce
%                     correlation, or 'none' to do no iteration.
%
%Example:
%     % create pre-defined design (16x2).
%     NDV  = 2;
%     CCD = srgtsDOECentralComposite(NDV, 'type', 'inscribed')
% 
%     CCD =
% 
%     0.1464    0.1464
%     0.1464    0.8536
%     0.8536    0.1464
%     0.8536    0.8536
%          0    0.5000
%     1.0000    0.5000
%     0.5000         0
%     0.5000    1.0000
%     0.5000    0.5000
%
%     % fill with a Latin hypercube
%     NLHPOINTS = 20 - length(CCD(:,1));
%
%     P = srgtsDOELHSFilling(CCD, NLHPOINTS, ...
%                        'criterion', 'correlation', ...
%                        'iterations',50) % 20 points, 2 variables
%
% 
%     P =
%     
%     0.1464    0.1464
%     0.1464    0.8536
%     0.8536    0.1464
%     0.8536    0.8536
%          0    0.5000
%     1.0000    0.5000
%     0.5000         0
%     0.5000    1.0000
%     0.5000    0.5000
%     0.3250    0.7750
%     0.7250    0.3250
%     0.7750    0.3750
%     0.6250    0.0750
%     0.6750    0.6750
%     0.0750    0.6250
%     0.9250    0.9250
%     0.3750    0.5750
%     0.2750    0.7250
%     0.2250    0.1250
%     0.4250    0.2750
%     
%Results may change from run to run because of the random nature of the
%Latin hypercube design.

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
% check inputs
if mod(length(varargin),2)~=0
   error('SURROGATES Toolbox:srgtsDOELHSFilling:BadNumberInputs','Incorrect number of arguments.')
end
okargs = {'iterations' 'criterion' 'smooth'};
defaults = {NaN 'maximin' 'on'};
[eid,emsg,maxiter,crit,dosmooth] = statgetargs(okargs,defaults,varargin{:});
if ~isempty(eid)
   error(sprintf('SURROGATES Toolbox:srgtsDOELHSFilling:%s',eid),emsg)
end

if isempty(maxiter)
   maxiter = NaN;
elseif ~isnumeric(maxiter) | prod(size(maxiter))~=1 | maxiter<0
   error('SURROGATES Toolbox:srgtsDOELHSFilling:ScalarRequired',...
         'Value of ''iterations'' parameter must be a scalar >= 0.');
end
if isnan(maxiter), maxiter = 5; end

okcrit = {'none' 'maximin' 'correlation'};
if isempty(crit)
   crit = 'maximin';
end
if ~ischar(crit)
   error('SURROGATES Toolbox:srgtsDOELHSFilling:BadCriterion','Bad criterion name.');
end
i = strmatch(crit,okcrit);
if isempty(i)
   error('SURROGATES Toolbox:srgtsDOELHSFilling:BadCriterion','Bad criterion name "%s".',crit);
elseif length(i)>1
   error('SURROGATES Toolbox:srgtsDOELHSFilling:BadCriterion','Ambiguous criterion name "%s".',crit);
end
crit = okcrit{i};

if isempty(dosmooth)
   dosmooth = 'on';
elseif (~isequal(dosmooth,'on')) & (~isequal(dosmooth,'off'))
   error('SURROGATES Toolbox:srgtsDOELHSFilling:BadSmooth',...
         'Value of ''smooth'' parameter must be ''on'' or ''off''.');
end

% Start with a plain lhs sample over a grid
[n_init p]  = size(DOE);

LH = getsample(NbLHPoints,p,dosmooth);
n = NbLHPoints + n_init;

X = [DOE; LH];

% Create designs, save best one
if isequal(crit,'none') || size(X,1)<2
    maxiter = 0;
end

switch(crit)
 case 'maximin'
   bestscore = score(X,crit);
   for j=2:maxiter
       
      lh = getsample(NbLHPoints,p,dosmooth);
      x = [DOE; lh];

      newscore = score(x,crit);
      if newscore > bestscore
         X = x;
         bestscore = newscore;
      end
   end
   
 case 'correlation'
   bestscore = score(X,crit);
   for iter=2:maxiter
      % Forward ranked Gram-Schmidt step:
      for j=2:p
         for k=1:j-1
            z = takeout(X(:,j),X(:,k));
            x = (rank(z) - 0.5) / n;
            X(n_init + 1 : end, k) = x(n_init + 1 : end);
         end
      end
      % Backward ranked Gram-Schmidt step:
      for j=p-1:-1:1
         for k=p:-1:j+1
            z = takeout(X(:,j),X(:,k));
            x = (rank(z) - 0.5) / n;
            X(n_init + 1 : end, k) = x(n_init + 1 : end);
         end
      end
   
      % Check for convergence
      newscore = score(X,crit);
      if newscore <= bestscore
         break;
      else
         bestscore = newscore;
      end
   end
end

DOELHD = X;

% ---------------------
function x = getsample(n,p,dosmooth)
x = rand(n,p);
for i=1:p
   x(:,i) = rank(x(:,i));
end
   if isequal(dosmooth,'on')
      x = x - rand(size(x));
   else
      x = x - 0.5;
   end
   x = x / n;
   
% ---------------------
function s = score(x,crit)
% compute score function, larger is better

if size(x,1)<2
    s = 0;       % score is meaningless with just one point
    return
end

switch(crit)
 case 'correlation'
   % Minimize the sum of between-column squared correlations
   c = corrcoef(x);
   s = -sum(sum(triu(c,1).^2));

 case 'maximin'
   % Maximimize the minimum point-to-point difference
   % Get I and J indexing each pair of points
   [m,p] = size(x);
   pp = (m-1):-1:2;
   I = zeros(m*(m-1)/2,1);
   I(cumsum([1 pp])) = 1;
   I = cumsum(I);
   J = ones(m*(m-1)/2,1);
   J(cumsum(pp)+1) = 2-pp;
   J(1)=2;
   J = cumsum(J);

   % To save space, loop over dimensions
   d = zeros(size(I));
   for j=1:p
      d = d + (x(I,j)-x(J,j)).^2;
   end
   s = sqrt(min(d));
end

% ------------------------
function z=takeout(x,y)

% Remove from y its projection onto x, ignoring constant terms
xc = x - mean(x);
yc = y - mean(y);
b = (xc-mean(xc))\(yc-mean(yc));
z = y - b*xc;

% -----------------------
function r=rank(x)

% Similar to tiedrank, but no adjustment for ties here
[sx, rowidx] = sort(x);
r(rowidx) = 1:length(x);
r = r(:);


function [eid,emsg,varargout]=statgetargs(pnames,dflts,varargin)
%STATGETARGS Process parameter name/value pairs for statistics functions
%   [EID,EMSG,A,B,...]=STATGETARGS(PNAMES,DFLTS,'NAME1',VAL1,'NAME2',VAL2,...)
%   accepts a cell array PNAMES of valid parameter names, a cell array
%   DFLTS of default values for the parameters named in PNAMES, and
%   additional parameter name/value pairs.  Returns parameter values A,B,...
%   in the same order as the names in PNAMES.  Outputs corresponding to
%   entries in PNAMES that are not specified in the name/value pairs are
%   set to the corresponding value from DFLTS.  If nargout is equal to
%   length(PNAMES)+1, then unrecognized name/value pairs are an error.  If
%   nargout is equal to length(PNAMES)+2, then all unrecognized name/value
%   pairs are returned in a single cell array following any other outputs.
%
%   EID and EMSG are empty if the arguments are valid.  If an error occurs,
%   EMSG is the text of an error message and EID is the final component
%   of an error message id.  STATGETARGS does not actually throw any errors,
%   but rather returns EID and EMSG so that the caller may throw the error.
%   Outputs will be partially processed after an error occurs.
%
%   This utility is used by some Statistics Toolbox functions to process
%   name/value pair arguments.
%
%   Example:
%       pnames = {'color' 'linestyle', 'linewidth'}
%       dflts  = {    'r'         '_'          '1'}
%       varargin = {{'linew' 2 'nonesuch' [1 2 3] 'linestyle' ':'}
%       [eid,emsg,c,ls,lw] = statgetargs(pnames,dflts,varargin{:})    % error
%       [eid,emsg,c,ls,lw,ur] = statgetargs(pnames,dflts,varargin{:}) % ok

%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 1.4.2.1 $  $Date: 2003/11/01 04:28:41 $ 

% We always create (nparams+2) outputs:
%    one each for emsg and eid
%    nparams varargs for values corresponding to names in pnames
% If they ask for one more (nargout == nparams+3), it's for unrecognized
% names/values

% Initialize some variables
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
