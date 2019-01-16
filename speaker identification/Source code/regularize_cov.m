function regularized_cov = regularize_cov(covariance, epsilon)
	regularized_cov = covariance + epsilon * eye(size(covariance));

	% makes sure matrix is symmetric upto 1e-15 desimal
	regularized_cov = (regularized_cov + regularized_cov')/2;

end
