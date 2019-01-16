function logLikelihood = LogLikelihood(model, X)
    means=model.mu';covariances=model.sigma;weights=model.weight;
	[N, dim] = size(X);
	M = length(weights);
	logLikelihood = 0;
    for i = 1:N 
		p = 0;
		for j = 1:M  
			m_D = X(i,:) - means(j,:);
			covar = covariances(:,:,j);
			norm = 1 / (((2*pi)^(dim/2)) * sqrt(det(covar)));
			p = p + weights(j) / (((2*pi)^(dim/2)) * sqrt(det(covar)))...
                * exp(-0.5 * ((m_D / covar) * m_D') );
		end
		logLikelihood = logLikelihood + log(p);
    end
end

