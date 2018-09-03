% !ffmpeg -i video1.h264 video1.mp4

vidObj=VideoReader('video.mp4');
th=linspace(0,2.*pi,50);
r=70;
x=r.*cos(th);
y=r.*sin(th);
x1=[741];
y1=[273];
delta=207;

n=4;
clear IN;
[X,Y]=meshgrid(1:1920,1:1080);

for i=1:n
    for j=1:n
        IN(i,j).IN=inpolygon(X,Y,x+x1+delta.*(i-1),...
            y+y1+delta.*(j-1)); 
        IN(i,j).len=length(find(IN(i,j).IN(:)==1));
    end
end


% figure
% image(vidFram)
% hold on;

m=1;
while hasFrame(vidObj)

    vidFram=readFrame(vidObj);
    one=rgb2gray(vidFram);
    
    for i=1:n
        for j=1:n
%             plot(x+x1+delta.*(i-1),y+y1+delta.*(j-1),'g')
            ind=find(IN(i,j).IN(:)==1);
            bright1(i,j,m)=std(double(one(ind))); % ...
                %./IN(i,j).len;
        end
    end
    m=m+1;
    m
end


m=1;
clear frozen;
for i=1:n
    for j=1:n
        deriv=diff(squeeze(bright1(i,j,:))./bright1(i,j,1));
        ind=find(deriv<-0.015);
        frozen(m)=ind(1);
        m=m+1;
    end
end
[a,b]=sort(frozen);


