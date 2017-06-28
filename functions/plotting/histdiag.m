function [D,bw] = histdiag( A, alpha )
%	
% 	Compute the histogram of non-zero elements in the diagonals of a square matrix.
% 	Inputs: 
%		A - nxn sequare matrix
%		alpha - optional double scalar
% 	
% 	Given a square matrix A of size n, this returns a vector D of size 2n-1 where element
% 	k is the number of non-zero elements in the diagonal n-k (the 0-diagonal being the
% 	main diagonal, and negative corresponds to the lower part).
% 	
% 	If the second input alpha is specified, the one-sided cumulative histogram is
% 	computed (combining the counts in both lower and upper part) and the first diagonal
% 	for which the cumulative histogram exceeds the threshold is returned as an estimate of
% 	the alpha-bandwidth.
% 	
% 	Copyright 2014, FMRIB
% 	Jonathan.hadida [at] fmrib.ox.ac.uk

	% Get number of rows/columns
	[n,nc] = size(A);
	assert(n == nc, 'M must be square.');
	
	% Create distribution
	D = (n+1)*ones(n,2*n-1);
	D(1,1:n) = n:-1:1;
	D(1,(n+1):end) = n*(1:n-1) + 1;
	D = cumsum(D);
	
	% Create mask
	M = false(size(D)); T = tril(true(n),-1);
	M(:,1:n) = T;
	M(:,n:end) = fliplr(T);
	D(M) = 0;
	
	% Count non-zero elements
	D(~M) = A(D(~M)) ~= 0;
	D     = sum(D);
	
	% Compute bandwidth
	if nargin > 1
		
		C = D(n:end);
		C(2:end) = C(2:end) + fliplr(D(1:n-1));
		C = cumsum(C) / sum(C);
		
		bw = find( C >= alpha, 1, 'first' );
	end

end