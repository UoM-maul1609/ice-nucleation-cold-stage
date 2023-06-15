import numpy as np
import matplotlib.pyplot as plt
import sys

def plot_ramp(fileName,fno):

    plt.figure()
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

    ax=plt.subplot((111))
    plt.plot(arr[:,0],arr[:,1])
    plt.plot(arr[:,0],arr[:,2])

    plt.show()

    plt.text(0.3,0.8,fno.replace('.png',''),horizontalalignment='left',verticalalignment='top',transform=ax.transAxes)
    plt.ylim((-50,20))
    plt.xlabel('time (s)')
    plt.ylabel('temp ($\circ$C)')
    plt.legend(['control','actual'])
    
    plt.savefig('../../figures/' + fno,dpi=300)
    plt.gcf().subplots_adjust(bottom=0.15)
    plt.savefig('../../figures/' + fno,dpi=300)

