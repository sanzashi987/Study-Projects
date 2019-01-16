function [afterEndDet] =desli(x)


x = double(x);
x = x / max(abs(x));
 

FrameLen = 256;
FrameInc = 80;
amp1 = 10;
amp2 = 2;
zcr1 = 10;
zcr2 = 5;
maxsilence = 8;  % 8*10ms  = 80ms
 
 
minlen  = 15;    % 15*10ms = 150ms
status  = 0;     
count   = 0;     
silence = 0;     
 

x1=x(1:end-1);
x2=x(2:end);
%enframe
tmp1=enframe(x1,FrameLen,FrameInc);
tmp2=enframe(x2,FrameLen,FrameInc);
signs = (tmp1.*tmp2)<0;
diffs = (tmp1 -tmp2)>0.02;
zcr   = sum(signs.*diffs, 2);%one frame
 
%energy calculation
%amp = sum(abs(enframe(filter([1 -0.9375], 1, x), FrameLen, FrameInc)), 2);
amp = sum(abs(enframe(x, FrameLen, FrameInc)), 2);
 
 
amp1 = min(amp1, max(amp)/4);
amp2 = min(amp2, max(amp)/8);

%end point detection
x1 = 0;
x2 = 0;
v_num=0;
v_Begin=[];
v_End=[];
 

for n=1:length(zcr)
   goto = 0;
   switch status
   case {0,1}                   
      if amp(n) > amp1          % make sure enter the utterence 
         x1 = max(n-count-1,1);
         status  = 2;
         silence = 0;
         count   = count + 1;
      elseif amp(n) > amp2 || ... % maybe enter
             zcr(n) > zcr2
         status = 1;
         count  = count + 1;
      else                       % no it s silence
         status  = 0;
         count   = 0;
      end
   case 2                      
      if amp(n) > amp2 || ...     % during utterence 
         zcr(n) > zcr2
         count = count + 1;
      else                       % about to end
         silence = silence+1;
         if silence < maxsilence % silence too short
            count  = count + 1;
         elseif count < minlen   % too short to determine as utterence 
            status  = 0;
            silence = 0;
            count   = 0;
         else                    % ends
            status  = 3;
         end
      end
   case 3
   
      v_num=v_num+1;   %counts of utterence chip
      count = count-silence/2;
      x2 = x1 + count -1;
      v_Begin(1,v_num)=x1*FrameInc; 
      v_End(1,v_num)=x2*FrameInc;
      
      status  = 0;     %initial states
      count   = 0;     %
      silence = 0;     %
 
 
   end
end  
 
if length(v_End)==0
    x2 = x1 + count -1;
    v_Begin(1,1)=x1*FrameInc; 
    v_End(1,1)=x2*FrameInc;
end
 
lenafter=0;
for len=1:length(v_End)
    tmp=v_End(1,len)-v_Begin(1,len);
    lenafter=lenafter+tmp;
end
lenafter;
afterEndDet=zeros(lenafter,1);%returns desilence signal
beginnum=0;
endnum=0; 
 
    for k=1:length(v_End)
        tmp=x(v_Begin(1,k):v_End(1,k));
        beginnum=endnum+1;
        endnum=beginnum+v_End(1,k)-v_Begin(1,k);
        afterEndDet(beginnum:endnum)=tmp; 
    end
 
end
