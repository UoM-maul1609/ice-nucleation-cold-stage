# -*- coding: utf-8 -*-
"""
Created on Thu Aug 13 11:07:21 2020

@author: Rae
"""


import cv2
import numpy as np
import matplotlib.pyplot as plt
import matplotlib as mpl
from cycler import cycler
import sys

"""
    load files
"""
filename1='20200810-154311.h264'

filename2 = filename1[0:-5]


"""
    get firstframe from video as jpg
"""

vidcap = cv2.VideoCapture(filename1)
count = 0
success = True
while success:
    success,image = vidcap.read()
    if count ==500:
          cv2.imwrite(filename2+'_frame1.jpg',image)
    count+=1


"""
    load firstframe, convert to grayscale and blur
"""

img1 = cv2.imread(filename2+'_frame1.jpg',cv2.IMREAD_GRAYSCALE) # Load in image here - Ensure 8-bit grayscale
img = cv2.blur(img1, (1, 3)) 

# size of the image
H, W = img.shape


"""
    determine position of drops
"""
# Stores the final circles that don't go out of bounds
final_circles = [] 
# If detection of circles not write can change variables in following line:
circles	= cv2.HoughCircles(img,cv2.HOUGH_GRADIENT,3,100,param1=110,param2=50,minRadius=50,maxRadius=55)

circles	= np.uint16(np.around(circles))

# Obtain rows and columns
rows = img.shape[0] 
cols = img.shape[1]
circles = np.round(circles[0, :]).astype("int") # Convert to integer
for (x, y, r) in circles: # For each circle we have detected...
    if (600<= x <= cols-500) and ( 110 <= y <= rows-200): # Check if circle is within boundary
        final_circles.append([x, y, r]) # If it is, add this to our final list

final_circles = np.asarray(final_circles).astype("int") # Convert to numpy array for compatability

for	i in final_circles:
# 					draw	the	outer	circle
				cv2.circle(img,(i[0],i[1]),i[2],(0,255,0),2)
				#	draw	the	center	of	the	circle
				cv2.circle(img,(i[0],i[1]),2,(0,0,255),3)
cv2.imshow("HoughCirlces", img)
cv2.waitKey()
cv2.destroyAllWindows()

"""
    Ae position of drops successfully determined? If not go back to line 55 and change variables
"""

user_input= input('Continue?')
if user_input == 'n':
    sys.exit()
  
mask = np.zeros(img.shape, np.uint8)

d_total =  np.ndarray.item(np.array(final_circles.shape[0:1]))


"""
    read video as frames and calculate std
"""
results, frame_count = [], []
vidcap = cv2.VideoCapture(filename1)
success,frame = vidcap.read()
count=0
while success:
    print('Read a new frame: ', success, count)
    success,frame = vidcap.read()
    if(not success):
        break
    count += 1    


    roi = np.zeros(frame.shape[:2], np.uint8)
    for i in final_circles:
        x,y,r = i[0], i[1], i[2]
        roi = cv2.circle(roi, (x, y), r, 255, cv2.FILLED)
        mask = np.ones_like(frame) * 255
        mask = cv2.bitwise_and(mask, frame, mask=roi) + cv2.bitwise_and(mask, mask, mask=~roi)
        border=1
        height, width = img1.shape
        x1 = max(x-r - border//2, 0)      # eventually  -(border//2+1)
        x2 = min(x+r + border//2, width)  # eventually  +(border//2+1)
        y1 = max(y-r - border//2, 0)      # eventually  -(border//2+1)
        y2 = min(y+r + border//2, height) # eventually  +(bord
    
        image = frame[y1:y2,x1:x2]
        # cv2.imshow('b', image) 
        std=(np.mean(image))
        # print(std)
        # cntNotBlack = cv2.countNonZero(image)
        results.append(std)
        frame_count.append(count)
            

"""
    Convert to lists to array and save data
"""

frame_count = np.array(frame_count)

results = np.array(results)

f_total = np.ndarray.item(np.array(frame_count[-1:]))

x = frame_count[::d_total]

l = np.array_split(results, f_total)

np.savetxt(filename2+'_mean.txt', l)



"""
    determine freezing point
"""
data = np.loadtxt(filename2+'_mean.txt')

# #   uncomment below to show std of drops against frames
color = mpl.cm.nipy_spectral(np.linspace(0, 1, d_total))
mpl.rcParams['axes.prop_cycle'] = cycler('color', color)

for column in data.T:
  plt.scatter(x, column)
plt.ylabel('Standard deviation')
plt.xlabel('Frame number')
plt.show()

#   To sort when variation large at start of data set, assumes frame 0 is freezing point 
 
freezing_frame=[]
for column in data.T:
    a_prime = column[9:] - column[8:-1]
    answer = np.argmax(a_prime[1:] - a_prime[:-1])
    freezing_frame.append(answer+8) # +8 adjusts for missing frames
print(sorted(freezing_frame))
freezing_frame = np.array(freezing_frame)  


"""
    finally calculate temperature of freezing point and save as txt file
"""

#   load text file
a = np.loadtxt('data/'+filename2+'.txt', skiprows=2)

x = freezing_frame[0:]/5 # /5 refers to fps

temp = np.interp(x, a[:,0], a[:,2])
np.savetxt('temp_up_test'+filename2+'.txt', temp)
print(sorted(temp))

with open('ultrapure_test.txt','ab') as ftext:  #Wb if you want to create a new one,
        np.savetxt(ftext,temp)


