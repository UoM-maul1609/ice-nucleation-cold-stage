$fn=60;
union() {
    difference() {
        minkowski() {
            cube([55-3,58-3,2.],true);
            cylinder(d=3,h=2.,center=true);
        }
        minkowski() {
            cube([50-1,53-1,5.1],true);
            cylinder(d=1,h=2.5,center=true);
        }
        
    }
    difference() {
        union() {
            translate([0,0,0.4]) minkowski() {
                cube([24.2-5,26-5,3.2/2.],true);
                cylinder(d=5,h=3.2/2.,center=true);
            }
            translate([0,0,1-0.5]) cube([55,2.5,3],true);
            translate([0,0,1-0.5]) cube([2.5,55,3],true);
        }
        
        
        translate([0,0,-2-0.5-0.3]) cube([25.2,25.2,2],true);
        for (i=[1 : 4]) {
            for(j=[1:4]) {
                translate([-25/2+4+(25-2)/4*(i-1),
                    -25/2+4+(25-2)/4*(j-1),0]) cylinder(d=5.,h=10,center=true);
            }   
        }
        
    }
}
