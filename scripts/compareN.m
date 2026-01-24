function varargout = compareN(varargin)

N = nargin;
time = varargin{1}(:,2);

for k = 2:N
    time = intersect(time, varargin{k}(:,2), 'stable');
end

for k = 1:N
    [~, ia] = ismember(time, varargin{k}(:,2));
    varargout{k} = varargin{k}(ia,:);
end

end
