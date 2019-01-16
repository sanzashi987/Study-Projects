function mfcc_vector=mfcc_c(a,fs,num_mel,nfft)
    unit=1e-3;t=1/fs;%num_mel=24;nfft=512;
    window_scale=20*unit/t;window_step=window_scale/2;
    num_of_frame=ceil(length(a)/window_step);
    %% melfilters
    [freq,mel]=melfilter(num_mel,nfft,fs);
    % mel=melbankm(num_mel,512,fs,0,0.5,'t');mel=full(mel);
    % figure(1);hold on
    % for k=2:num_mel+1
    % plot(freq,mel(k-1,:),'r','linewidth',1); hold on
    % end
    %% pre-emphasis
    aa=double(a);
    %% enframe
    frame=zeros(window_scale,num_of_frame);
    a_2=[aa;zeros(window_scale,1)];
    for i=1:num_of_frame
        frame(:,i)=a_2((i-1)*window_step+1:(i-1)*window_step+window_scale);
    end
    frame=frame';
    %% MFCC
    n2=fix(nfft/2)+1;
    for i =1:size(frame,1)
       current=frame(i,:)'.*hamming( window_scale);
       mag_fft=abs(fft(current)).^2;
       temp=dct(log10(mel*mag_fft(1:n2)));
       mfcc_vector(i,:)=temp(1:13)';
    end
end