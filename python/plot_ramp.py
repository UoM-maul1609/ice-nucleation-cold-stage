import numpy as np
import matplotlib.pyplot as plt
import sys

fileName=sys.argv[1]

fp=open(fileName,'rt')

text=fp.readlines()
fp.close()

r=len(text)
arr=np.zeros((r-2,3))
for i in range(2,r):
    vars1=text[i].split(" ")
    arr[i-2][0]=float(vars1[0])
    arr[i-2][1]=float(vars1[1])
    arr[i-2][2]=float(vars1[2])

plt.ion()

plt.plot(arr[:,0],arr[:,1])
plt.plot(arr[:,0],arr[:,2])

plt.show()

