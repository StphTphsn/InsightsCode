function errorpatch(X, Y, E, LC, PC)
% This function replicates the functionality of errorbar, but uses
% errorpatches instead
X = X(:);
Y = Y(:);
E = E(:);
% By Emily Mackevicius, edited by Matt Best 6/27/11
if nargin < 5
    PC = [.9 .9 .9];
end;

if nargin < 4
    LC = [.2 .2 .2];
end;


plot(X, Y, 'Color', LC)%, 'LineWidth', 3);

xa = [X; X(end:-1:1)];
ya = [(Y + E); (Y(end:-1:1) - E(end:-1:1))];

h = patch(xa, ya, PC);
set(h, ...
      'EdgeAlpha', .3, ...
      'EdgeColor', PC, ...
      'FaceAlpha', .3, ...
      'LineStyle', 'none' ...
      );
return