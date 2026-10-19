
function [U, Y] = createDataset()

% Input values used in the paper
u = [-0.5, 0, 0.5];

% Generate all nine combinations
[U1, U2] = ndgrid(u, u);

U = [U1(:), U2(:)]; %convert each in column vertor and then 
% create a 9X2 matrix.

% Desired nonlinear output from Equation (19)
Y = -U(:,1) - U(:,2) ...
    + U(:,1).^2 + U(:,2).^2 ...
    + U(:,1).*U(:,2);

end


% this file only creates the nine input-output 
% examples that our FNN will try to learn. 
% It does not train the network.