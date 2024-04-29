%% Load the file

% TO DO: check that you're calling in only the files you want to plot. Use
%an asterisk to inidate parts of the file name you don't want to specify.

selFiles = uigetdir('Select folder') ;
selFiles = dir(strcat(selFiles,"/*.txt"));
nFiles = numel(selFiles);
filepath = selFiles(1).folder;
filenames = natsortfiles({selFiles.name}');

yValue = [] ;

for i = 1:nFiles
    fileName = strcat(filepath,"/",filenames{i}) ;
    
    tmpData = readmatrix(fileName) ;
    
    tmpData(end,:) = [] ;
    
    if i==1 
        xValue = tmpData(:,1) ;
    end
    
    yValue(:,i) = tmpData(:,2) ;
end   

%% make plots
fig = figure();
% TO DO: Indicate in the two lines below the range of X values to plot
% for Raman centered at 547, a good range is 400 to 650
% for Raman centered at 557 or 560, a good range is 950 to 1100
% for Raman centered at 650, a good range is 3300 to 3600
% for full FTIR spectra, a good range is 500 to 4500
%for water region of FTIR only, try 2600 to 4000
minXvalue = 500 ;
maxXvalue = 4000 ;

idx = find(xValue>=minXvalue & xValue<=maxXvalue) ;
newXvalue = xValue(idx,:) ;
newYvalue = yValue(idx,:) ;

% find the minimum to get the baseline
minValue = min(newYvalue) ;

% find the maximum to scale
maxValue = max(newYvalue-minValue) ;
scaledY = (newYvalue-minValue)./maxValue ;

% create the offset
% TO DO:  After running once, tweak the increment value below
increment = 0.5 ;
offset = 0:increment:(nFiles-1)*increment ;

% define the colorplot
cm = colormap(cool(nFiles)) ;
colororder(cm)

% make the plot
plot(newXvalue,scaledY+offset)
ax = gca;
set(ax,'plotboxaspectratio',[1,1,1]);


%% DONT MIND ALL THIS, THIS IS JUST SO THE SCRIPT PLOTS SPECTRA IN NAME ORDER
function [B,ndx,dbg] = natsortfiles(A,rgx,varargin)
% Natural-order / alphanumeric sort of filenames or foldernames.
%
% (c) 2014-2023 Stephen Cobeldick
%
% Sorts text by character code and by number value. File/folder names, file
% extensions, and path directories (if supplied) are sorted separately to
% ensure that shorter names sort before longer names. For names without
% file extensions (i.e. foldernames, or filenames without extensions) use
% the 'noext' option. Use the 'xpath' option to ignore the filepath. Use
% the 'rmdot' option to remove the folder names "." and ".." from the array.
%
%%% Example:
% P = 'C:\SomeDir\SubDir';
% S = dir(fullfile(P,'*.txt'));
% S = natsortfiles(S);
% for k = 1:numel(S)
%     F = fullfile(P,S(k).name)
% end
%
%%% Syntax:
%  B = natsortfiles(A)
%  B = natsortfiles(A,rgx)
%  B = natsortfiles(A,rgx,<options>)
% [B,ndx,dbg] = natsortfiles(A,...)
%
% To sort the elements of a string/cell array use NATSORT (File Exchange 34464)
% To sort the rows of a string/cell/table use NATSORTROWS (File Exchange 47433)
% To sort string/cells using custom sequences use ARBSORT (File Exchange 132263)
%
%% File Dependency %%
%
% NATSORTFILES requires the function NATSORT (File Exchange 34464). Extra
% optional arguments are passed directly to NATSORT. See NATSORT for case-
% sensitivity, sort direction, number format matching, and other options.
%
%% Explanation %%
%
% Using SORT on filenames will sort any of char(0:45), including the
% printing characters ' !"#$%&''()*+,-', before the file extension
% separator character '.'. Therefore NATSORTFILES splits the file-name
% from the file-extension and sorts them separately. This ensures that
% shorter names come before longer names (just like a dictionary):
%
% >> Af = {'test_new.m'; 'test-old.m'; 'test.m'};
% >> sort(Af) % Note '-' sorts before '.':
% ans =
%     'test-old.m'
%     'test.m'
%     'test_new.m'
% >> natsortfiles(Af) % Shorter names before longer:
% ans =
%     'test.m'
%     'test-old.m'
%     'test_new.m'
%
% Similarly the path separator character within filepaths can cause longer
% directory names to sort before shorter ones, as char(0:46)<'/' and
% char(0:91)<'\'. This example on a PC demonstrates why this matters:
%
% >> Ad = {'A1\B', 'A+/B', 'A/B1', 'A=/B', 'A\B0'};
% >> sort(Ad)
% ans =   'A+/B'  'A/B1'  'A1\B'  'A=/B'  'A\B0'
% >> natsortfiles(Ad)
% ans =   'A\B0'  'A/B1'  'A1\B'  'A+/B'  'A=/B'
%
% NATSORTFILES splits filepaths at each path separator character and sorts
% every level of the directory hierarchy separately, ensuring that shorter
% directory names sort before longer, regardless of the characters in the names.
% On a PC separators are '/' and '\' characters, on Mac and Linux '/' only.
%
%% Examples %%
%
% >> Aa = {'a2.txt', 'a10.txt', 'a1.txt'}
% >> sort(Aa)
% ans = 'a1.txt'  'a10.txt'  'a2.txt'
% >> natsortfiles(Aa)
% ans = 'a1.txt'  'a2.txt'  'a10.txt'
%
% >> Ab = {'test2.m'; 'test10-old.m'; 'test.m'; 'test10.m'; 'test1.m'};
% >> sort(Ab) % Wrong number order:
% ans =
%    'test.m'
%    'test1.m'
%    'test10-old.m'
%    'test10.m'
%    'test2.m'
% >> natsortfiles(Ab) % Shorter names before longer:
% ans =
%    'test.m'
%    'test1.m'
%    'test2.m'
%    'test10.m'
%    'test10-old.m'
%
%%% Directory Names:
% >> Ac = {'A2-old\test.m';'A10\test.m';'A2\test.m';'A1\test.m';'A1-archive.zip'};
% >> sort(Ac) % Wrong number order, and '-' sorts before '\':
% ans =
%    'A1-archive.zip'
%    'A10\test.m'
%    'A1\test.m'
%    'A2-old\test.m'
%    'A2\test.m'
% >> natsortfiles(Ac) % Shorter names before longer:
% ans =
%    'A1\test.m'
%    'A1-archive.zip'
%    'A2\test.m'
%    'A2-old\test.m'
%    'A10\test.m'
%
%% Input and Output Arguments %%
%
%%% Inputs (**=default):
% A   = Array to be sorted. Can be the structure array returned by DIR,
%       or a string array, or a cell array of character row vectors.
% rgx = Optional regular expression to match number substrings.
%     = []** uses the default regular expression (see NATSORT).
% <options> can be supplied in any order:
%     = 'rmdot' removes the dot directory names "." and ".." from the output.
%     = 'noext' for foldernames, or filenames without filename extensions.
%     = 'xpath' sorts by name only, excluding any preceding filepath.
% Any remaining <options> are passed directly to NATSORT.
%
%%% Outputs:
% B   = Array <A> sorted into natural sort order.      The same size as <A>.
% ndx = NumericMatrix, generally such that B = A(ndx). The same size as <A>.
% dbg = CellArray, each cell contains the debug cell array of one level
%       of the filename/path parts, i.e. directory names, or filenames, or
%       file extensions. Helps debug the regular expression (see NATSORT).
%
% See also SORT NATSORTFILES_TEST NATSORT NATSORTROWS ARBSORT IREGEXP
% REGEXP DIR FILEPARTS FULLFILE NEXTNAME STRING CELLSTR SSCANF

%% Input Wrangling %%
%
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
%
if isstruct(A)
	assert(isfield(A,'name'),...
		'SC:natsortfiles:A:StructMissingNameField',...
		'If first input <A> is a struct then it must have field <name>.')
	nmx = {A.name};
	assert(all(fnh(nmx)),...
		'SC:natsortfiles:A:NameFieldInvalidType',...
		'First input <A> field <name> must contain only character row vectors.')
	[fpt,fnm,fxt] = cellfun(@fileparts, nmx, 'UniformOutput',false);
	if isfield(A,'folder')
		fpt(:) = {A.folder};
		assert(all(fnh(fpt)),...
			'SC:natsortfiles:A:FolderFieldInvalidType',...
			'First input <A> field <folder> must contain only character row vectors.')
	end
elseif iscell(A)
	assert(all(fnh(A(:))),...
		'SC:natsortfiles:A:CellContentInvalidType',...
		'First input <A> cell array must contain only character row vectors.')
	[fpt,fnm,fxt] = cellfun(@fileparts, A(:), 'UniformOutput',false);
	nmx = strcat(fnm,fxt);
elseif ischar(A)
	assert(ndims(A)<3,...
		'SC:natsortfiles:A:CharNotMatrix',...
		'First input <A> if character class must be a matrix.') %#ok<ISMAT>
	[fpt,fnm,fxt] = cellfun(@fileparts, num2cell(A,2), 'UniformOutput',false);
	nmx = strcat(fnm,fxt);
else
	assert(isa(A,'string'),...
		'SC:natsortfiles:A:InvalidType',...
		'First input <A> must be a structure, a cell array, or a string array.');
	[fpt,fnm,fxt] = cellfun(@fileparts, cellstr(A(:)), 'UniformOutput',false);
	nmx = strcat(fnm,fxt);
end
%
varargin = cellfun(@nsf1s2c, varargin, 'UniformOutput',false);
ixv = fnh(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
trd = strcmpi(txt,'rmdot');
tnx = strcmpi(txt,'noext');
txp = strcmpi(txt,'xpath');
%
nsfAssert(txt, trd, 'rmdot', '"." and ".." folder')
nsfAssert(txt, tnx, 'noext', 'file-extension')
nsfAssert(txt, txp, 'xpath', 'file-path')
%
chk = '(no|rm|x)(dot|ext|path)';
%
if nargin>1
	nsfChkRgx(rgx,chk)
	txt = [{rgx},txt(~(trd|tnx|txp))];
end
%
%% Path and Extension %%
%
% Path separator regular expression:
if ispc()
	psr = '[^/\\]+';
else % Mac & Linux
	psr = '[^/]+';
end
%
if any(trd) % Remove "." and ".." dot directory names
	ddx = strcmp(nmx,'.') | strcmp(nmx,'..');
	fxt(ddx) = [];
	fnm(ddx) = [];
	fpt(ddx) = [];
	nmx(ddx) = [];
end
%
if any(tnx) % No file-extension
	fnm = nmx;
	fxt = [];
end
%
if any(txp) % No file-path
	mat = reshape(fnm,1,[]);
else % Split path into {dir,subdir,subsubdir,...}:
	spl = regexp(fpt(:),psr,'match');
	nmn = 1+cellfun('length',spl(:));
	mxn = max(nmn);
	vec = 1:mxn;
	mat = cell(mxn,numel(nmn));
	mat(:) = {''};
	%mat(mxn,:) = fnm(:); % old behavior
	mat(permute(bsxfun(@eq,vec,nmn),[2,1])) =  fnm(:);  % TRANSPOSE bug loses type (R2013b)
	mat(permute(bsxfun(@lt,vec,nmn),[2,1])) = [spl{:}]; % TRANSPOSE bug loses type (R2013b)
end
%
if numel(fxt) % File-extension
	mat(end+1,:) = fxt(:);
end
%
%% Sort Matrices %%
%
nmr = size(mat,1)*all(size(mat));
dbg = cell(1,nmr);
ndx = 1:numel(fnm);
%
for ii = nmr:-1:1
	if nargout<3 % faster:
		[~,idx] = natsort(mat(ii,ndx),txt{:},xtx{:});
	else % for debugging:
		[~,idx,gbd] = natsort(mat(ii,ndx),txt{:},xtx{:});
		[~,idb] = sort(ndx);
		dbg{ii} = gbd(idb,:);
	end
	ndx = ndx(idx);
end
%
% Return the sorted input array and corresponding indices:
%
if any(trd)
	tmp = find(~ddx);
	ndx = tmp(ndx);
end
%
ndx = ndx(:);
%
if ischar(A)
	B = A(ndx,:);
elseif any(trd)
	xsz = size(A);
	nsd = xsz~=1;
	if nnz(nsd)==1 % vector
		xsz(nsd) = numel(ndx);
		ndx = reshape(ndx,xsz);
	end
	B = A(ndx);
else
	ndx = reshape(ndx,size(A));
	B = A(ndx);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsortfiles
function nsfChkRgx(rgx,chk)
chk = sprintf('^(%s)$',chk);
assert(~ischar(rgx)||isempty(regexpi(rgx,chk,'once')),...
	'SC:natsortfiles:rgx:OptionMixUp',...
	['Second input <rgx> must be a regular expression that matches numbers.',...
	'\nThe provided expression "%s" looks like an optional argument (inputs 3+).'],rgx)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsfChkRgx
function nsfAssert(txt,idx,eid,opt)
% Throw an error if an option is overspecified.
if nnz(idx)>1
	error(sprintf('SC:natsortfiles:%s:Overspecified',eid),...
		['The %s option may only be specified once.',...
		'\nThe provided options:%s'],opt,sprintf(' "%s"',txt{idx}));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsfAssert
function arr = nsf1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsf1s2c
function [B,ndx,dbg] = natsort(A,rgx,varargin)
% Natural-order / alphanumeric sort the elements of a text array.
%
% (c) 2012-2023 Stephen Cobeldick
%
% Sorts text by character code and by number value. By default matches
% integer substrings and performs a case-insensitive ascending sort.
% Options to select the number format, sort order, case sensitivity, etc.
%
%%% Example:
% >> A = ["x2", "x10", "x1"];
% >> natsort(A)
% ans =   "x1"  "x2"  "x10"
%
%%% Syntax:
%  B = natsort(A)
%  B = natsort(A,rgx)
%  B = natsort(A,rgx,<options>)
% [B,ndx,dbg] = natsort(A,...)
%
% To sort any file-names or folder-names use NATSORTFILES (File Exchange 47434)
% To sort the rows of a string/cell/table use NATSORTROWS (File Exchange 47433)
% To sort string/cells using custom sequences use ARBSORT (File Exchange 132263)
%
%% Number Format %%
%
% The **default regular expression '\d+' matches consecutive digit
% characters, i.e. integer numbers. Specifying the optional regular
% expression allows the numbers to include a +/- sign, decimal point,
% decimal fraction digits, exponent E-notation, character quantifiers,
% or lookarounds. For information on defining regular expressions:
% <http://www.mathworks.com/help/matlab/matlab_prog/regular-expressions.html>
% For example, to match leading/trailing whitespace prepend/append '\s*'.
%
% The number substrings are parsed by SSCANF into numeric values, using
% either the **default format '%f' or the user-supplied format specifier.
% Both decimal comma and decimal point are accepted in number substrings.
%
% This table shows examples of some regular expression patterns for common
% notations and ways of writing numbers, together with suitable SSCANF formats:
%
% Regular       | Number Substring | Number Substring              | SSCANF
% Expression:   | Match Examples:  | Match Description:            | Format Specifier:
% ==============|==================|===============================|==================
% **        \d+ | 0, 123, 4, 56789 | unsigned integer              | %f  %i  %u  %lu
% --------------|------------------|-------------------------------|------------------
%      [-+]?\d+ | +1, 23, -45, 678 | integer with optional +/- sign| %f  %i  %d  %ld
% --------------|------------------|-------------------------------|------------------
%     \d+\.?\d* | 012, 3.45, 678.9 | integer or decimal            | %f
% (\d+|Inf|NaN) | 123, 4, NaN, Inf | integer, Inf, or NaN          | %f
%  \d+\.\d+E\d+ | 0.123e4, 5.67e08 | exponential notation          | %f
% --------------|------------------|-------------------------------|------------------
%  0X[0-9A-F]+  | 0X0, 0X3E7, 0XFF | hexadecimal notation & prefix | %x  %i
%    [0-9A-F]+  |   0,   3E7,   FF | hexadecimal notation          | %x
% --------------|------------------|-------------------------------|------------------
%  0[0-7]+      | 012, 03456, 0700 | octal notation & prefix       | %o  %i
%   [0-7]+      |  12,  3456,  700 | octal notation                | %o
% --------------|------------------|-------------------------------|------------------
%  0B[01]+      | 0B1, 0B101, 0B10 | binary notation & prefix      | %b   (not SSCANF)
%    [01]+      |   1,   101,   10 | binary notation               | %b   (not SSCANF)
% --------------|------------------|-------------------------------|------------------
%
%% Debugging Output Array %%
%
% The third output is a cell array <dbg>, for checking how the numbers
% were matched by the regular expression <rgx> and converted to numeric
% by the SSCANF format. The rows of <dbg> are linearly indexed from
% the first input argument <A>.
%
% >> [~,~,dbg] = natsort(A)
% dbg =
%    'x'    [ 2]
%    'x'    [10]
%    'x'    [ 1]
%
%% Examples %%
%
%%% Multiple integers (e.g. release version numbers):
% >> Aa = {'v10.6', 'v9.10', 'v9.5', 'v10.10', 'v9.10.20', 'v9.10.8'};
% >> sort(Aa) % for comparison.
% ans =   'v10.10'  'v10.6'  'v9.10'  'v9.10.20'  'v9.10.8'  'v9.5'
% >> natsort(Aa)
% ans =   'v9.5'  'v9.10'  'v9.10.8'  'v9.10.20'  'v10.6'  'v10.10'
%
%%% Integer, decimal, NaN, or Inf numbers, possibly with +/- signs:
% >> Ab = {'test+NaN', 'test11.5', 'test-1.4', 'test', 'test-Inf', 'test+0.3'};
% >> sort(Ab) % for comparison.
% ans =   'test' 'test+0.3' 'test+NaN' 'test-1.4' 'test-Inf' 'test11.5'
% >> natsort(Ab, '[-+]?(NaN|Inf|\d+\.?\d*)')
% ans =   'test' 'test-Inf' 'test-1.4' 'test+0.3' 'test11.5' 'test+NaN'
%
%%% Integer or decimal numbers, possibly with an exponent:
% >> Ac = {'0.56e007', '', '43E-2', '10000', '9.8'};
% >> sort(Ac) % for comparison.
% ans =   ''  '0.56e007'  '10000'  '43E-2'  '9.8'
% >> natsort(Ac, '\d+\.?\d*(E[-+]?\d+)?')
% ans =   ''  '43E-2'  '9.8'  '10000'  '0.56e007'
%
%%% Hexadecimal numbers (with '0X' prefix):
% >> Ad = {'a0X7C4z', 'a0X5z', 'a0X18z', 'a0XFz'};
% >> sort(Ad) % for comparison.
% ans =   'a0X18z'  'a0X5z'  'a0X7C4z'  'a0XFz'
% >> natsort(Ad, '0X[0-9A-F]+', '%i')
% ans =   'a0X5z'  'a0XFz'  'a0X18z'  'a0X7C4z'
%
%%% Binary numbers:
% >> Ae = {'a11111000100z', 'a101z', 'a000000000011000z', 'a1111z'};
% >> sort(Ae) % for comparison.
% ans =   'a000000000011000z'  'a101z'  'a11111000100z'  'a1111z'
% >> natsort(Ae, '[01]+', '%b')
% ans =   'a101z'  'a1111z'  'a000000000011000z'  'a11111000100z'
%
%%% Case sensitivity:
% >> Af = {'a2', 'A20', 'A1', 'a10', 'A2', 'a1'};
% >> natsort(Af, [], 'ignorecase') % default
% ans =   'A1'  'a1'  'a2'  'A2'  'a10'  'A20'
% >> natsort(Af, [], 'matchcase')
% ans =   'A1'  'A2'  'A20'  'a1'  'a2'  'a10'
%
%%% Sort order:
% >> Ag = {'2', 'a', '', '3', 'B', '1'};
% >> natsort(Ag, [], 'ascend') % default
% ans =   ''   '1'  '2'  '3'  'a'  'B'
% >> natsort(Ag, [], 'descend')
% ans =   'B'  'a'  '3'  '2'  '1'  ''
% >> natsort(Ag, [], 'num<char') % default
% ans =   ''   '1'  '2'  '3'  'a'  'B'
% >> natsort(Ag, [], 'char<num')
% ans =   ''   'a'  'B'  '1'  '2'  '3'
%
%%% UINT64 numbers (with full precision):
% >> natsort({'a18446744073709551615z', 'a18446744073709551614z'}, [], '%lu')
% ans =       'a18446744073709551614z'  'a18446744073709551615z'
%
%% Input and Output Arguments %%
%
%%% Inputs (**=default):
% A   = Array to be sorted. Can be a string array, or a cell array of
%       character row vectors, or a categorical array, or a datetime array,
%       or any other array type which can be converted by CELLSTR.
% rgx = Optional regular expression to match number substrings.
%     = [] uses the default regular expression '\d+'** to match integers.
% <options> can be entered in any order, as many as required:
%     = Sort direction: 'descend'/'ascend'**
%     = Character case handling: 'matchcase'/'ignorecase'**
%     = Character/number order: 'char<num'/'num<char'**
%     = NaN/number order: 'NaN<num'/'num<NaN'**
%     = SSCANF conversion format: e.g. '%x', '%li', '%b', '%f'**, etc.
%     = Function handle of a function that sorts text. It must accept one
%       input, which is a cell array of char vectors (the text array to
%       be sorted). It must return as its 2nd output the sort indices.
%
%%% Outputs:
% B   = Array <A> sorted into natural sort order.     The same size as <A>.
% ndx = NumericArray, generally such that B = A(ndx). The same size as <A>.
% dbg = CellArray of the parsed characters and number values. Each row
%       corresponds to one input element of <A>, in linear-index order.
%
% See also SORT NATSORT_TEST NATSORTFILES NATSORTROWS ARBSORT
% IREGEXP REGEXP COMPOSE STRING STRINGS CATEGORICAL CELLSTR SSCANF

%% Input Wrangling %%
%
fnh = @(c)cellfun('isclass',c,'char') & cellfun('size',c,1)<2 & cellfun('ndims',c)<3;
%
if iscell(A)
	assert(all(fnh(A(:))),...
		'SC:natsort:A:CellInvalidContent',...
		'First input <A> cell array must contain only character row vectors.')
	C = A(:);
elseif ischar(A) % Convert char matrix:
	assert(ndims(A)<3,...
		'SC:natsort:A:CharNotMatrix',...
		'First input <A> if character class must be a matrix.') %#ok<ISMAT>
	C = num2cell(A,2);
else % Convert string, categorical, datetime, enumeration, etc.:
	C = cellstr(A(:));
end
%
chk = '(match|ignore)(case|dia)|(de|a)scend(ing)?|(char|nan|num)[<>](char|nan|num)|%[a-z]+';
%
if nargin<2 || isnumeric(rgx)&&isequal(rgx,[])
	rgx = '\d+';
elseif ischar(rgx)
	assert(ndims(rgx)<3 && size(rgx,1)==1,...
		'SC:natsort:rgx:NotCharVector',...
		'Second input <rgx> character row vector must have size 1xN.') %#ok<ISMAT>
	nsChkRgx(rgx,chk)
else
	rgx = ns1s2c(rgx);
	assert(ischar(rgx),...
		'SC:natsort:rgx:InvalidType',...
		'Second input <rgx> must be a character row vector or a string scalar.')
	nsChkRgx(rgx,chk)
end
%
varargin = cellfun(@ns1s2c, varargin, 'UniformOutput',false);
ixv = fnh(varargin); % char
txt = varargin(ixv); % char
xtx = varargin(~ixv); % not
%
% Sort direction:
tdd = strcmpi(txt,'descend');
tdx = strcmpi(txt,'ascend')|tdd;
% Character case:
tcm = strcmpi(txt,'matchcase');
tcx = strcmpi(txt,'ignorecase')|tcm;
% Char/num order:
ttn = strcmpi(txt,'num>char')|strcmpi(txt,'char<num');
ttx = strcmpi(txt,'num<char')|strcmpi(txt,'char>num')|ttn;
% NaN/num order:
ton = strcmpi(txt,'num>NaN')|strcmpi(txt,'NaN<num');
tox = strcmpi(txt,'num<NaN')|strcmpi(txt,'NaN>num')|ton;
% SSCANF format:
tsf = ~cellfun('isempty',regexp(txt,'^%([bdiuoxfeg]|l[diuox])$'));
%
nsAssert(txt, tdx, 'SortDirection', 'sort direction')
nsAssert(txt, tcx,  'CaseMatching', 'case sensitivity')
nsAssert(txt, ttx,  'CharNumOrder', 'number-character order')
nsAssert(txt, tox,   'NanNumOrder', 'number-NaN order')
nsAssert(txt, tsf,  'sscanfFormat', 'SSCANF format')
%
ixx = tdx|tcx|ttx|tox|tsf;
if ~all(ixx)
	error('SC:natsort:InvalidOptions',...
		['Invalid options provided. Check the help and option spelling!',...
		'\nThe provided options:%s'],sprintf(' "%s"',txt{~ixx}))
end
%
% SSCANF format:
if any(tsf)
	fmt = txt{tsf};
else
	fmt = '%f';
end
%
xfh = cellfun('isclass',xtx,'function_handle');
assert(nnz(xfh)<2,...
	'SC:natsort:FunctionHandle:Overspecified',...
	'The function handle option may only be specified once.')
assert(all(xfh),...
	'SC:natsort:InvalidOptions',...
	'Optional arguments must be character row vectors, string scalars, or function handles.')
if any(xfh)
	txfh = xtx{xfh};
end
%
%% Identify and Convert Numbers %%
%
[nbr,spl] = regexpi(C(:), rgx, 'match','split', txt{tcx});
%
if numel(nbr)
	V = [nbr{:}];
	if strcmp(fmt,'%b')
		V = regexprep(V,'^0[Bb]','');
		vec = cellfun(@(s)pow2(numel(s)-1:-1:0)*sscanf(s,'%1d'),V);
	else
		vec = sscanf(strrep(sprintf(' %s','0',V{:}),',','.'),fmt);
		vec = vec(2:end); % SSCANF wrong data class bug (R2009b and R2010b)
	end
	assert(numel(vec)==numel(V),...
		'SC:natsort:sscanf:TooManyValues',...
		'The "%s" format must return one value for each input number.',fmt)
else
	vec = [];
end
%
%% Allocate Data %%
%
% Determine lengths:
nmx = numel(C);
lnn = cellfun('length',nbr);
lns = cellfun('length',spl);
mxs = max(lns);
%
% Allocate data:
idn = permute(bsxfun(@le,1:mxs,lnn),[2,1]); % TRANSPOSE lost class bug (R2013b)
ids = permute(bsxfun(@le,1:mxs,lns),[2,1]); % TRANSPOSE lost class bug (R2013b)
arn = zeros(mxs,nmx,class(vec));
ars =  cell(mxs,nmx);
ars(:) = {''};
ars(ids) = [spl{:}];
arn(idn) = vec;
%
%% Debugging Array %%
%
if nargout>2
	dbg = cell(nmx,0);
	for k = 1:nmx
		V = spl{k};
		V(2,:) = [num2cell(arn(idn(:,k),k));{[]}];
		V(cellfun('isempty',V)) = [];
		dbg(k,1:numel(V)) = V;
	end
end
%
%% Sort Matrices %%
%
if ~any(tcm) % ignorecase
	ars = lower(ars);
end
%
if any(ttn) % char<num
	% Determine max character code:
	mxc = 'X';
	tmp = warning('off','all');
	mxc(1) = Inf;
	warning(tmp)
	mxc(mxc==0) = 255; % Octave
	% Append max character code to the split text:
	%ars(idn) = strcat(ars(idn),mxc); % slower than loop
	for ii = reshape(find(idn),1,[])
		ars{ii}(1,end+1) = mxc;
	end
end
%
idn(isnan(arn)) = ~any(ton); % NaN<num
%
if any(xfh) % external text-sorting function
	[~,ndx] = txfh(ars(mxs,:));
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),txt{tdx});
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),txt{tdx});
		ndx = ndx(idx);
		[~,idx] = txfh(ars(ii,ndx));
		ndx = ndx(idx);
	end
elseif any(tdd)
	[~,ndx] = sort(nsGroups(ars(mxs,:)),'descend');
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),'descend');
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),'descend');
		ndx = ndx(idx);
		[~,idx] = sort(nsGroups(ars(ii,ndx)),'descend');
		ndx = ndx(idx);
	end
else
	[~,ndx] = sort(ars(mxs,:)); % ascend
	for ii = mxs-1:-1:1
		[~,idx] = sort(arn(ii,ndx),'ascend');
		ndx = ndx(idx);
		[~,idx] = sort(idn(ii,ndx),'ascend');
		ndx = ndx(idx);
		[~,idx] = sort(ars(ii,ndx)); % ascend
		ndx = ndx(idx);
	end
end
%
%% Outputs %%
%
if ischar(A)
	ndx = ndx(:);
	B = A(ndx,:);
else
	ndx = reshape(ndx,size(A));
	B = A(ndx);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%natsort
function grp = nsGroups(vec)
% Groups in a cell array of char vectors, equivalent to [~,~,grp]=unique(vec);
[vec,idx] = sort(vec);
grp = cumsum([true(1,numel(vec)>0),~strcmp(vec(1:end-1),vec(2:end))]);
grp(idx) = grp;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsGroups
function nsChkRgx(rgx,chk)
% Perform some basic sanity-checks on the supplied regular expression.
chk = sprintf('^(%s)$',chk);
assert(isempty(regexpi(rgx,chk,'once')),...
	'SC:natsort:rgx:OptionMixUp',...
	['Second input <rgx> must be a regular expression that matches numbers.',...
	'\nThe provided input "%s" looks like an optional argument (inputs 3+).'],rgx)
if isempty(regexpi('0',rgx,'once'))
	warning('SC:natsort:rgx:SanityCheck',...
		['Second input <rgx> must be a regular expression that matches numbers.',...
		'\nThe provided regular expression does not match the digit "0", which\n',...
		'may be acceptable (e.g. if literals, quantifiers, or lookarounds are used).'...
		'\nThe provided regular expression: "%s"'],rgx)
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsChkRgx
function nsAssert(txt,idx,eid,opt)
% Throw an error if an option is overspecified.
if nnz(idx)>1
	error(sprintf('SC:natsort:%s:Overspecified',eid),...
		['The %s option may only be specified once.',...
		'\nThe provided options:%s'],opt,sprintf(' "%s"',txt{idx}));
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%nsAssert
function arr = ns1s2c(arr)
% If scalar string then extract the character vector, otherwise data is unchanged.
if isa(arr,'string') && isscalar(arr)
	arr = arr{1};
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ns1s2c