function confusion_matrix1(act1,det1)
[mat,order] = confusionmat(act1,det1);
k=length(order);         
imagesc(mat);
colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
textStrings = num2str(mat(:),'%0.02f');       %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:k);  
hStrings=text(x(:),y(:),textStrings(:),'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(mat(:) > midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors£»
set(gca,'XTick',1:10,...                                    
        'XTickLabel',{'Speaker1','Speaker2','Speaker3','Speaker4','Speaker5','Speaker6'...
        ,'Speaker7','Speaker8','Speaker9','Speaker10'},...  %#   and tick labels
        'YTick',1:10,...                                    
        'YTickLabel',{'Speaker1','Speaker2','Speaker3','Speaker4','Speaker5','Speaker6'...
        ,'Speaker7','Speaker8','Speaker9','Speaker10'},...
        'TickLength',[0 0]);