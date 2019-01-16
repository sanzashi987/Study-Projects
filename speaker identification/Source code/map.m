function specific_mod=map(ubm,data)
    weight=ubm.weight;mu=ubm.mu;sigma=ubm.sigma;
    [dim,N]=size(data);M=length(weight);
    prob_lkh=zeros(M,N);
    for j= 1: M
        mean=mu(:,j);
        covariance=sigma(:,:,j);
        for i=1:N
            p_xz=exp(-0.5*(data(:,i)-mean)'/covariance*(data(:,i)-mean));
            prob_lkh(j,i)=p_xz;
        end
        prob_lkh(j,:)=prob_lkh(j,:)/sqrt(det(covariance));
    end
    prob_lkh=prob_lkh*(2*pi)^(-dim/2);
    prob_post=zeros(M,N);
    prob_union=zeros(1,M);
    for i=1:N
        for j=1:M
            prob_union(1,j)=weight(j)*prob_lkh(j,i);
        end
        for j=1:M
            prob_post(j,i)=prob_union(1,j)/sum(prob_union);
        end
    end
    
    N_k=sum(prob_post,2);
    for j=1:M
       mu_k=0;
       for i=1:N
           mu_k=mu_k+prob_post(j,i)*data(:,i);
       end
       mu(:,j)=mu_k/N_k(j);
    end
    sigma_e=zeros(dim,dim,M);
    for j=1:M
        sigma_t=zeros(dim,dim);
        for i=1:N
            sigma_t=sigma_t+prob_post(j,i)*(data(:,i)-...
            mu(:,j))*(data(:,i)-mu(:,j))';             
        end 
        sigma_e(:,:,j)=sigma_t/N_k(j);
    end
    alpha=zeros(M,1);
    for j=1:M
        alpha(j)=N_k(j)/(N_k(j)+16);
    end
    new_mu=ones(dim,1)*alpha'.*mu+ones(dim,1)*(ones(M,1)-alpha)'.*ubm.mu;
    s=zeros(dim,dim,M);
    mu_old=ubm.mu;
    for j=1:M
        s(:,:,j)=alpha(j)*sigma_e(:,:,j)+...
            (1-alpha(j))*(sigma(:,:,j)+...
            diag(diag(mu_old(:,j)*mu_old(:,j)')))-...
            diag(diag(mu(:,j)*mu(:,j)'));
    end
    w=alpha.*N_k/N+(ones(M,1)-alpha).*(ubm.weight)';
    w=w/sum(w);
    specific_mod.mu=new_mu;%ones(dim,1)*alpha'.*mu+ones(dim,1)*(ones(M,1)-alpha)'.*ubm.mu;
    specific_mod.weight=w';%ubm.weight;
    specific_mod.sigma=ubm.sigma;%s;
    

end