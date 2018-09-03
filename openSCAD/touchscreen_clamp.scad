$fn=60;
difference() {
    union() {
        cube([15,120,5],true);
        translate([0,2.5,0]) {
            translate([0,33,0]) cylinder(d=25,h=5,center=true);
            translate([0,-33,0]) cylinder(d=25,h=5,center=true);
        }
        translate([0,60-2.5,-2-2.5]) cube([15,5,4],true);
        translate([0,-(60-2.5),-2-2.5]) cube([15,5,4],true);
    }
    translate([0,2.5,0]) union() {
        translate([0,33,0]) cylinder(d=3.5,h=10,center=true);
        translate([0,-33,0]) cylinder(d=3.5,h=10,center=true);
        translate([0,33,-1.5-2.5+3]) cube([16,8.5,3],true);
        translate([0,-33,-1.5-2.5+3]) cube([16,8.5,3],true);
    }
}