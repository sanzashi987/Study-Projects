function [weight_e, mu_e, sigma_e] = EM(data, M)
%This is a function to realize EM alogrithm 
%input data: multidemensional data
%input M: using M Gaussian Distributions represents input data
%outpu weight_e: probability for each Gaussian distribution
%output mu_e : mean matrix for M Gaussian distributions
%output sigma_e] : covariance matrix for M Gaussian distributions
    [dim,N]=size(data);
    sigma_e=zeros(dim,dim,M);weight_e=ones(1, M)./M;
    [cluster_idx, mu_e, sumd] = kmeans(data', M, 'replicate', 10);
    for j = 1:M
        sumd(j,1)=sumd(j,1)./sum(cluster_idx==j);
    end
    
    for j = 1:M
		sigma_e(:, :, j) = eye(dim) .* sumd(j, 1);
    end
    mu_e=mu_e';
    nbStep=0;
    error=1;
    while (error>0.005) && nbStep<=70 %defines the loop count
        nbStep = nbStep+1;
        sigma_old=sigma_e;weight_old=weight_e;mu_old=mu_e;
        prob_lkh=zeros(M,N);
        for j =1:M
            mu_i=mu_e(:,j);
            s_i=sigma_e(:,:,j);
            for i=1:N
                p_xz=exp(-0.5*(data(:,i)-mu_i)'/s_i*(data(:,i)-mu_i));
                prob_lkh(j,i)=p_xz;
            end
            prob_lkh(j,:)=prob_lkh(j,:)/sqrt(det(s_i));
        end
        prob_lkh=prob_lkh*(2*pi)^(-dim/2);
        prob_post=zeros(M,N);
        prob_union=zeros(1,M);
        for i=1:N
            for j=1:M
                prob_union(1,j)=weight_e(j)*prob_lkh(j,i);
            end
            for j=1:M
                prob_post(j,i)=prob_union(1,j)/sum(prob_union);
            end
        end
        %M  
        N_k=zeros(1,M);
        for j=1:M       
            N_k(1,j)=sum(prob_post(j,:));
        end
        %update weight
        weight_e=N_k./N;
        %update mu
        for j=1:M
            mu_k=0;
            for i=1:N
                mu_k=mu_k+prob_post(j,i)*data(:,i);
            end
            mu_e(:,j)=mu_k/N_k(j);
        end
        %update sigma
        for j=1:M
            sigma_t=zeros(dim,dim);
            for i=1:N
                sigma_t=sigma_t+prob_post(j,i)*(data(:,i)-...
                mu_e(:,j))*(data(:,i)-mu_e(:,j))';             
            end 
            sigma_e(:,:,j)=sigma_t/N_k(j);
        end
        error=max([norm(sigma_e(:)-sigma_old(:))/norm(sigma_old(:));norm(mu_old-mu_e)/norm(mu_old);...
                    norm(weight_old-weight_e)/norm(weight_old)]);      
    end
end