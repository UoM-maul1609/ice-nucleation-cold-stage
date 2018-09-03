$fn=60;
difference() {
    minkowski() {
        cylinder(d2=15,d1,10,h=8,center=true);
        sphere(d=3);
    }
    translate([0,0,-8]) cube([30,30,10],true);

    translate([0,0,-15]) {
        nut(8.15);
        translate([0,0,12]) cylinder(d=5,h=10,center=true);
    }
}


module nut(size){
    $fn=6;
    translate([0,0,20]) cylinder(d=size,h=10,center=true);
}
