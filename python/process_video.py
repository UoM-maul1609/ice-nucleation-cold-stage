"""
    program to find the time where droplets freeze
"""
import numpy as np
import cv2
from matplotlib import path
import matplotlib.pyplot as plt
import sys



if(len(sys.argv) < 3):
    print('2 inputs required')
    sys.exit()
    
    
"""
    get filename from commandline
"""
filename1=sys.argv[1]


"""
    open up video and rread the first image
"""
vidcap = cv2.VideoCapture(filename1)
success,image = vidcap.read()

"""
    define circles
"""
th=np.linspace(0,2*np.pi,50);
r=70;
x=[r*np.cos(th[i]) for i in range(50)]
y=[r*np.sin(th[i]) for i in range(50)]
x1=[740] 
y1=[272]
delta=[207]
d=np.asarray(delta)

n=4 # size of the droplet array
X,Y=np.meshgrid(np.arange(0,1920,1),np.arange(0,1080,1));
X , Y = X.flatten() , Y.flatten()
points=np.vstack((X,Y)).T


"""
    structure array for holding data
"""
IN=np.zeros((n,n),dtype=[('len','int'),('IN','(1920,1080)float32')])


"""
    loop through all circles and get coordinates using "contains_points" method
"""
for i in range(n):
    for j in range(n):
        # contour is x and ys in a column list
        contour=np.vstack((np.asarray(x)+np.asarray(x1+delta*np.asarray(i)),\
            np.asarray(y)+np.asarray(y1+delta*np.asarray(j)))).T
        p=path.Path(contour)
        
        # for this contour find the points that are inside
        mask = p.contains_points(points,radius=2)
        IN1 = mask.reshape((1080,1920)).T
        (ind1,ind2)=np.where(IN1==True) #indicates the points that lie inside the circle
        
        # save in the structured array
        IN[i,j]['IN']=IN1
        IN[i,j]['len']=len(ind1)
        
        
        

"""
    now get all the images and calculate the standard deviation of the points
"""
resize_size=1000;
extend_size=resize_size
bright1=np.zeros((n,n,resize_size))
count=0
while success:
    print('Read a new frame: ', success, count)


    # resize if needed
    if(count >= resize_size):
        resize_size=resize_size+extend_size
        bright1=np.append(bright1,np.zeros((n,n,extend_size)),2)


    
    
    
    # read the image
    success,image = vidcap.read()
    if(not success):
        break
    # https://stackoverflow.com/questions/12201577/how-can-i-convert-an-rgb-image-into-grayscale-in-python
    one=np.dot(image[...,:3], [0.299, 0.587, 0.114])
    
        
        
        
    # calculate the standard deviation of the greyscale image inside each circle
    for i in range(n):
        for j in range(n):
            (ind1,ind2)=np.where(IN[i,j]['IN']==True)
            bright1[i,j,count]=np.std(one[ind2,ind1].flatten())
            
    count += 1

# resize the standard deviation array so that it is the correct size
bright1=bright1[:,:,0:count:1]
      
      
            

"""
    finally calculate the freezing point
"""
frozen=np.zeros((n**2,1))
m=0
for i in range(n):
    for j in range(n):
        deriv=np.diff(bright1[i,j,:] / bright1[i,j,0])
        (ind,)=np.where(deriv < -0.015)
        if(len(ind)):
            frozen[m]=ind[0]
        m=m+1
 
"""
    output the freezing times to a file
"""


"""
    get filename from commandline
"""
filename2=sys.argv[2]
fp=open(filename2,'w')
fp.write("total number of frames:" + str(count) +"\n")
fp.write("freezing events by frame number (zero based)\n")
for i in range(n**2):
    fp.write(str(frozen[i,0]) +"\n") 
fp.close()


# order that they freeze
order_frozen=np.argsort(frozen[:,0])