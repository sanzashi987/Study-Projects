function [freq,filters]=melfilter(num_filter,nfft,fs)
    f_low=0;f_high=fs/2;
    mel_low=2595*log(1+f_low/700);mel_high=2595*log(1+f_high/700);
    y=linspace(0,mel_high-mel_low,num_filter+2);
    F=700*(exp(y/2595)-1);
    W2=nfft/2+1;df=fs/nfft;
    freq=(0:W2-1)*df;
    filters=zeros(num_filter,W2);
    for k=2:num_filter+1
        f1=F(k-1);f2=F(k+1);f0=F(k);
        n1=round(f1/df)+1;n2=round(f2/df)+1;n0=round(f0/df)+1;
        for i=1 : W2
            if i>=n1 && i<=n0
                filters(k-1,i)=1*(i-n1)/(n0-n1);
            elseif i>n0 && i<=n2
                filters(k-1,i)=1*(n2-i)/(n2-n0);
            end
        end
    end
end 
