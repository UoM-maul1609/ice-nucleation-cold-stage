side=1;
wid1=110.9;

if (side==1) {
    difference() {
        touch_screen();
        translate([100,0,0]) cube([200,200,200],true);
    }
}
else if (side==2) {
    difference() {
        touch_screen();
        translate([-100,0,0]) cube([200,200,200],true);
    }
}


module touch_screen() {
    difference() {
        minkowski() {
            //cube([193.2+6,wid1+6,1.5],true);
            cube([193.2-6,wid1-6,2.5/2.+0.25],true);
            cylinder(r=6,h=2.5/2.+0.25,center=true);
        }

        translate([0,0,0.51+0.25]) minkowski() {
            cube([193.2-6-6,wid1-6-6,1.5/2],true);
            cylinder(r=6,h=1.5/2.,center=true);
        }
        
        translate([0,-1,0]) cube([167,100.9,5],true);
        
        //translate([126./2.,wid1/2+2.9,0]) cube([6,6,5],true);
        //translate([-126./2.,wid1/2+2.9,0]) cube([6,6,5],true);
    }

}