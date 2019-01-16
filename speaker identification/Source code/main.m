clc;clear;close all;
path='\Data\Data\Speaker';
num_of_speaker=10;num_of_train=7;
ubm_train=[];
for i =1:num_of_speaker
    current_speaker=strcat(path,num2str(i));
    current_wav=strcat(current_speaker,'\*.wav');
    files=dir(current_wav);
    x=[];
    for j=1:num_of_speaker
        [a,fs]=audioread(strcat(current_speaker,'\',files(j).name)); 
        a=desli(a);
        mfcc_vector=mfcc_c(a,fs,24,512);
        if j<=num_of_train  x=[x;mfcc_vector];
        else  speaker{i}.test{j+3-10}=mfcc_vector;
        end
    end
    speaker{i}.mfcc=x;
    ubm_train=[ubm_train;x];
end
save('workspace.mat')
%% train UBM
clc;clear
load('workspace.mat')
[ubm.weight, ubm.mu, ubm.sigma] = EM(ubm_train', 10);
save('workspace.mat')
%% map
clc;clear
load('workspace.mat')
for i=1:num_of_speaker
    speaker{i}.GMM=map(ubm,(speaker{i}.mfcc)');    
end
%% verification
clc;e=[];T=[];
for i=1:10
    for j=1:3
        T=[T;i];
        test_data=speaker{i}.test{j};
        log_ubm=LogLikelihood(ubm,test_data);
        log_gmm=zeros(10,1);
            for k=1:num_of_speaker
                log_gmm(k)=LogLikelihood(speaker{k}.GMM,test_data);
            end
        [~,estimated_speaker]=max(log_gmm-log_ubm*ones(10,1)/size(test_data,1));
        e=[e;estimated_speaker];
    end
end
confusion_matrix1(T,e);