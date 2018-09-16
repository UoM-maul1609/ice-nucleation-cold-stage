
LID=1;
BOX=2;

show1=LID;
led_y=40;
if(show1==LID) {
    difference() {
        cube([100,147,2],true);
        translate([0,0,-2]) hull() {
            camera();
        }
        translate([100/2-3.5,147/2-3.5,0]) cylinder(d=3,h=10,center=true);
        translate([100/2-3.5,-147/2+3.5,0]) cylinder(d=3,h=10,center=true);
        translate([-100/2+3.5,147/2-3.5,0]) cylinder(d=3,h=10,center=true);
        translate([-100/2+3.5,-147/2+3.5,0]) cylinder(d=3,h=10,center=true);
        translate([led_y,0,0]) cylinder(d=6,h=20,center=true);
    }
    
    // led holder
    difference() {
        union() {
            translate([led_y,0,15+1]) cylinder(d=12,h=30,center=true);
            translate([led_y,6,15+1]) cube([10,8,30],true);
        }
        translate([led_y,0,15+1+0.99]) cylinder(d=8,h=32,center=true);
        translate([led_y,10,20+1-3]) rotate([90,0,0]) cylinder(d=4.1,h=20,center=true,$fn=30);
        translate([led_y,6.5,20+1-3]) {
            nut(8.15);
            translate([5,0,0]) cube([10,3.5,7.0581],true);
        }
    }
    
    
    // make holes in camera for screws
    difference() {
        translate([0,0,-1]) camera();
        translate([12.5-2,0,5+1]) {
            cylinder(d=2,h=10,center=true,$fn=30);
            translate([0,0,4]) cylinder(d=2.5,h=10,center=true,$fn=30);
        }
        translate([-(12.5-2),0,5+1]) {
            cylinder(d=2,h=10,center=true,$fn=30);
            translate([0,0,4]) cylinder(d=2.5,h=10,center=true,$fn=30);
        }
        translate([12.5-2,12.5,5+1]) {
            cylinder(d=2,h=10,center=true,$fn=30);
            translate([0,0,4]) cylinder(d=2.5,h=10,center=true,$fn=30);
        }
        translate([-(12.5-2),12.5,5+1]) {
            cylinder(d=2,h=10,center=true,$fn=30);
            translate([0,0,4]) cylinder(d=2.5,h=10,center=true,$fn=30);
        }
    }
    //-
    
    translate([-35,-55,1]) scale(0.6) rotate([0,0,90]) linear_extrude(3) {
            text("Centre for Atmospheric Science");
            translate([15,-15,0]) text("Ice Nucleation Cold Stage"); 
    }

    translate([70,0,-1]) camera_back();

} else if(show1==BOX) {
    difference() {
        cube([100,147,80],true);
        cube([96,143,100],true);
        translate([0,-143/2,16-80/2]) rotate([90,0,0]) cylinder(d=3.5,h=10,center=true);
        translate([23.5,-143/2,16-80/2]) rotate([90,0,0]) cylinder(d=3.5,h=10,center=true);
        translate([-23.5,-143/2,16-80/2]) rotate([90,0,0]) cylinder(d=3.5,h=10,center=true);
    }
    translate([-96/2+1.5,-143/2+1.5,-10+40]) {
        difference() {
            union() {
                cylinder(d=7,h=20,center=true);
                translate([0,0,-15]) cylinder(d1=1,d2=7,h=10,center=true);
            }
            translate([0,0,1]) cylinder(d=2.6,h=20,center=true);
        }
    }
    translate([96/2-1.5,-143/2+1.5,-10+40]) {
        difference() {
            union() {
                cylinder(d=7,h=20,center=true);
                translate([0,0,-15]) cylinder(d1=1,d2=7,h=10,center=true); 
            }
            translate([0,0,1]) cylinder(d=2.6,h=20,center=true);

        }
    }
    translate([96/2-1.5,143/2-1.5,-10+40]) {
        difference() {
            union() {
                cylinder(d=7,h=20,center=true);
                translate([0,0,-15]) cylinder(d1=1,d2=7,h=10,center=true);     
            }
            translate([0,0,1]) cylinder(d=2.6,h=20,center=true);            
        }
    }
    translate([-96/2+1.5,143/2-1.5,-10+40]) {
        difference() {
            union() {
                cylinder(d=7,h=20,center=true);
                translate([0,0,-15]) cylinder(d1=1,d2=7,h=10,center=true);      
            }
            translate([0,0,1]) cylinder(d=2.6,h=20,center=true);
        }
    }
    // screw down bit
    translate([0,145/2+15/2+5/2,-40+5]) {
        difference() {
            minkowski() {
                translate([0,0,0]) cube([20-2,20-2,5],true);
                cylinder(d=2,h=5,center=true);
            }
            hull() {
                translate([0,-5,0]) cylinder(d=5,h=22,center=true);
                translate([0,20,0]) cylinder(d=5,h=22,center=true);
            }
        }
    }
}


module camera_back() {
    import("../stl/RPi_camera_stand/RPi_camera_back.stl");
}
module camera()
translate([0,1.5,0]) difference() {
    import("../stl/RPi_camera_stand/RPi_camera_stand.stl");
    translate([0,-38.,0]) cube([50,50,30],true);
}

module nut(size){
    $fn=6;
    translate([0,0,0]) rotate([90,0,0]) cylinder(d=size,h=3.5,center=true);
}


