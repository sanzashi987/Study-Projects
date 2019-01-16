function [count error danger_error]=check_accuracy(predict,test)
    count=0;test_len=length(test);k=1;error=0;j=1;danger_error=[];
    for i=1:test_len
        if predict(i)==test(i)
            count=count+1;
        else 
            error(k,1)=i;
            k=k+1;
            if predict(i)==1 && test(i)==0
                danger_error(j,1)=i;
                j=j+1;
            end
        end
    end
    count=count/test_len*100;
end