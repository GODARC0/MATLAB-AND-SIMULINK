
function y = fnnForward(u, w, m, sigma)

% u     : 2 input values
% w     : 9 rule weights
% m     : 6 Gaussian membership means (center)
% sigma : 6 Gaussian membership standard deviations (width)


% (:) operator turns an array into a column vector.
u = u(:);
w = w(:);
m = m(:);
sigma = sigma(:);

% Input validation
assert(numel(u) == 2, 'Expected two inputs.');
assert(numel(w) == 9, 'Expected nine weights.');
assert(numel(m) == 6, 'Expected six means.');
assert(numel(sigma) == 6, 'Expected six sigmas.');
assert(all(sigma > 0), 'All sigmas must be positive.');

% Layer 1: two input nodes
% Layer 2: six Gaussian memberships
mu = zeros(6,1); %created a 6X1 matrix with zeros in it to fill it later

for j = 1:6
    if j <= 3
        inputIndex = 1;
    else
        inputIndex = 2;
    end

    mu(j) = exp( ...
        -(u(inputIndex) - m(j))^2 ...
        / (2*sigma(j)^2));
end

% Layer 3: nine rules
% Each rule multiplies one membership from
% input 1 by one membership from input 2.
rule = zeros(9,1);
k = 1;

for i = 1:3
    for j = 1:3
        rule(k) = mu(i) * mu(j+3);
        k = k + 1;
    end
end

% Layer 4: weighted summation
y = sum(w .* rule);

end
