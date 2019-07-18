//use </Users/mccikpc2/Dropbox/programming/making_stuff/openSCAD/threads/threads.scad>

$fn=120;
tol1=1;
th=2;
// fan guard
cube1_len=92;
cube1_hgt=10;
cyl2_rad=106/2;
cyl2_hgt=cube1_hgt+tol1;
cyl1_rad=cyl2_rad+th;
cyl1_hgt=cube1_hgt;

cyl2_rad2=92/2;
cyl1_rad2=cyl2_rad2+th;

rad_curve=5;
hole_rad=2.25;
hole_hgt=cube1_hgt+tol1;
hole_sep=82;

// peltier clamp
cyl_pelt_rad=70;//50; //42.43;
cyl_pelt_holes=102/2.;
oring_pelt_rad=40/2;
pelt_cutout_rad=36.5/2;

FAN_GUARD=1;
PELTIER_CLAMP=2;
PELTIER_CLAMP2=9;
NUT_AND_BOLT=3;
FIXING=4;
GLASS_CLAMP=5;
GLASS_CLAMP2=6;
GLASS_CLAMP3=7;
ORING_PLACEMENT=8;

object=PELTIER_CLAMP2;


if(object==FAN_GUARD) {
    difference() {
        union(){
            minkowski() {
                cube([cube1_len-2*rad_curve,cube1_len-2*rad_curve,cube1_hgt/2],true);
                cylinder(r=rad_curve,h=cube1_hgt/2,center=true);
            }
            cylinder(r=cyl1_rad,h=cyl1_hgt,center=true);
            // support:
            translate([0,-26-hole_sep/2+15,0]) cube([45,30,cyl1_hgt],true);
            
            translate([0,-26-hole_sep/2+5,-cyl1_hgt/2]) {
                minkowski() {
                    cube([45-3,5,cyl1_hgt*2-3],true);
                    rotate([90,0,0]) cylinder(d=3,h=5,center=true);
                }
            }
            //-
        }
        // support:
        translate([-15,-26-hole_sep/2+1,-2*cyl1_hgt/2]) rotate([90,0,0]) cylinder(d=4.5,h=20,center=true);
        translate([-15,-26-hole_sep/2+10,-2*cyl1_hgt/2]) nut(8.15);

        translate([15,-26-hole_sep/2+1,-2*cyl1_hgt/2]) rotate([90,0,0]) cylinder(d=4.5,h=20,center=true);
        translate([15,-26-hole_sep/2+10,-2*cyl1_hgt/2]) nut(8.15);
        //
        
        cylinder(r1=cyl2_rad,r2=cyl2_rad2,h=cyl2_hgt,center=true);
        translate([hole_sep/2,hole_sep/2,0]) cylinder(r=hole_rad,h=hole_hgt,center=true);
        translate([-hole_sep/2,-hole_sep/2,0]) cylinder(r=hole_rad,h=hole_hgt,center=true);
        translate([-hole_sep/2,hole_sep/2,0]) cylinder(r=hole_rad,h=hole_hgt,center=true);
        translate([hole_sep/2,-hole_sep/2,0]) cylinder(r=hole_rad,h=hole_hgt,center=true);
    }
} else if(object==PELTIER_CLAMP) {
    difference() {
        union() {
            rotate([0,0,45]) translate([11.5,0,0]) minkowski() { 
                cube([85*2-2*rad_curve,60*2-2*rad_curve,1.5],true);
                cylinder(r=rad_curve,h=1.5,center=true);
            }
//            rotate([0,0,45]) translate([20,0,0]) minkowski() { 
//                cube([cyl_pelt_rad*2-2*rad_curve,cyl_pelt_rad*2-2*rad_curve,1.5],true);
//                cylinder(r=rad_curve,h=1.5,center=true);
//            }
            translate([0,0,-3]) cylinder(d=60,h=3,center=true);
            
            rotate([0,0,45]) translate([-77/2,25/2,-2.5-1.5]) cube([13,13,5],true);
            rotate([0,0,45]) translate([-77/2,-25/2,-2.5-1.5]) cube([13,13,5],true);
            
            // clamp for acrylic cover
            rotate([0,0,45]) translate([80/2,0,-2.5-1.5]) cube([13,13,5],true);
            
            // clamp for chamber
            rotate([0,0,45]) translate([73.5+12.5+2.5,0,-2.5-1.5]) cube([13,13,5],true);
            
            // fixing for hinge:
            rotate([0,0,45]) translate([-73.5+2.5,0,-6-1]) cube([5,60,12],true);

        }
        // holes for chamber hinge
        rotate([0,0,45]) translate([-73.5,0,+1-6.32]) {
            rotate([0,90,0]) translate([0,23.5,0]) cylinder(d=3,h=20,center=true);
            rotate([0,90,0]) cylinder(d=3,h=20,center=true);
            rotate([0,90,0]) translate([0,-23.5,0]) cylinder(d=3,h=20,center=true);            
        }
        
        
        // hole for thermocouple:
        rotate([0,0,45]) translate([-15,25,0]) cylinder(d=1.7,h=10,center=true);
        // 4 screw holes:
        translate([cyl_pelt_holes,0,0]) {
            cylinder(r=hole_rad,h=hole_hgt,center=true);
//            translate([0,0,1]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
        }
        translate([-cyl_pelt_holes,0,0]) {
            cylinder(r=hole_rad,h=hole_hgt,center=true);
//            translate([0,0,1]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
        }
        translate([0,cyl_pelt_holes,0]) {
            cylinder(r=hole_rad,h=hole_hgt,center=true);
//            translate([0,0,1]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
        }
        translate([0,-cyl_pelt_holes,0]) {
            cylinder(r=hole_rad,h=hole_hgt,center=true);
//            translate([0,0,1]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
        }
        //-
/*        // bottom o-ring
        translate([0,0,-5]) rotate_extrude() {
            translate([oring_pelt_rad,0,0]) rotate([0,0,45]) square(size=2.5,center=true);
        }*/
        // top o-ring
/*        translate([0,0,2.3]) rotate_extrude() {
            translate([54/2,0,0]) rotate([0,0,45]) square(size=2.5,center=true);
        } */
//        cylinder(r=pelt_cutout_rad,h=hole_hgt,center=true);
        // bottom peltier stage:
        translate([0,0,-3]) {
            rotate([0,0,45]) {
                cube([40.75,40.75,3.0],true);
                translate([-40.75/2+2,40/2,0]) cube([4,20,3.0],true);
                translate([-(-40.75/2+2),40/2,0]) cube([4,20,3.0],true);
            }
        }
        
        // contacts on bottom peltier
        translate([0,0,-3]) {
            rotate([0,0,45]) {
                translate([-40.75/2+4,40/2-2.5,0]) cube([8,5.+0.75,4],true);
                translate([-(-40.75/2+4),40/2-2.5,0]) cube([8,5.+0.75,4],true);
            }
        }
        

        // top peltier stage:
        rotate([0,0,45]) cube([30.75,30.75,hole_hgt],true);
        
        // holes for hinge
        rotate([0,0,45]) translate([-77/2,25/2,0]) {
            cylinder(d=4.5,h=10,center=true);
            translate([0,0,-5-1.5]) rotate([90,0,0]) nut(8.15);
        }
        rotate([0,0,45]) translate([-77/2,-25/2,0]) {
            cylinder(d=4.5,h=10,center=true);
            translate([0,0,-5-1.5]) rotate([90,0,0]) nut(8.15);            
        }
        
        // hole for hinge to hole down acrylic
        rotate([0,0,45]) translate([-77/2-10,0,1.5]) {
            rotate([90,0,0]) cylinder(d=5,h=42,center=true);
        }

        // hole for clamp
        rotate([0,0,45]) translate([80/2,0,0]) {
            cylinder(d=4.5,h=20,center=true);
            translate([0,0,5+1.5-3.7]) rotate([90,0,0]) nut(8.15);  
        }        
        // hole for chamber clamp
        rotate([0,0,45]) translate([73.5+12.5+2.5,0,0]) {
            cylinder(d=4.5,h=20,center=true);
            translate([0,0,5+1.5-3.7]) rotate([90,0,0]) nut(8.15);  
        }        
      
        
 /*       // hole for spring to hold down thermocouple
        rotate([0,0,0]) translate([46/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
 */       
        // for LED
        //translate([-40,40,0]) rotate([0,90,-45]) cylinder(r=6./2,h=100,center=true);

   }

   

}   else if(object==PELTIER_CLAMP2) {
    difference() {
        union() {
            rotate([0,0,45]) translate([11.5,0,0]) minkowski() { 
                cube([85*2-2*rad_curve,60*2-2*rad_curve,1.5],true);
                cylinder(r=rad_curve,h=1.5,center=true);
            }

            translate([0,0,-3]) cylinder(d=60,h=3,center=true);
            
            // cover hinge clamp
            rotate([0,0,45]) translate([-77/2,25/2,-1.5-2.5/2.]) cube([13,13,2.5],true);
            rotate([0,0,45]) translate([-77/2,-25/2,-1.5-2.5/2.]) cube([13,13,2.5],true);
            
            // clamp for acrylic cover
            rotate([0,0,45]) translate([80/2,0,-1.5-2.5/2.]) cube([13,13,2.5],true);
            
            // clamp for chamber
            rotate([0,0,45]) translate([73.5+12.5+2.5,0,-2.5-1.5]) cube([13,13,5],true);
            
            // fixing for hinge:
            rotate([0,0,45]) translate([-73.5+2.5,0,-6-1]) cube([5,60,12],true);

        }
        // holes for chamber hinge
        rotate([0,0,45]) translate([-73.5,0,+1-6.32]) {
            rotate([0,90,0]) translate([0,23.5,0]) cylinder(d=3,h=20,center=true);
            rotate([0,90,0]) cylinder(d=3,h=20,center=true);
            rotate([0,90,0]) translate([0,-23.5,0]) cylinder(d=3,h=20,center=true);            
        }
        
        
        // hole for thermocouple:
        rotate([0,0,45]) translate([-15,25,0]) cylinder(d=1.7,h=10,center=true);
        rotate([0,0,45]) translate([-15,25,-3]) cube([3,3,3],center=true);
        // 4 screw holes:
        translate([cyl_pelt_holes,0,0]) {
            cylinder(r=hole_rad,h=hole_hgt,center=true);
//            translate([0,0,1]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
        }
        translate([-cyl_pelt_holes,0,0]) {
            cylinder(r=hole_rad,h=hole_hgt,center=true);
//            translate([0,0,1]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
        }
        translate([0,cyl_pelt_holes,0]) {
            cylinder(r=hole_rad,h=hole_hgt,center=true);
//            translate([0,0,1]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
        }
        translate([0,-cyl_pelt_holes,0]) {
            cylinder(r=hole_rad,h=hole_hgt,center=true);
//            translate([0,0,1]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
        }
        //-

        // bottom peltier stage:
        translate([0,0,-3]) {
            rotate([0,0,45]) {
                translate([0,0.5,0]) cube([40.75,40.75+1,3.0],true);
                translate([-40.75/2+2,40/2,0]) cube([4,20,3.0],true);
                translate([-(-40.75/2+2),40/2,0]) cube([4,20,3.0],true);
            }
        }
        
        // contacts on bottom peltier
        translate([0,0,-3]) {
            rotate([0,0,45]) {
                translate([-40.75/2+4,30.75/2+6./2,0]) cube([8,6.,4],true);
                translate([-(-40.75/2+4),30.75/2+6./2,0]) cube([8,6.,4],true);
                translate([-40.75/2+4+2,30.75/2-5./2,0]) cube([8,5.,4],true);
                translate([-(-40.75/2+4)-2,30.75/2-5./2,0]) cube([8,5.,4],true);
            }
        }
        

        // top peltier stage:
        rotate([0,0,45]) cube([30.75,30.75,hole_hgt],true);
        
        // holes for hinge
        rotate([0,0,45]) translate([-77/2,25/2,0]) {
            cylinder(d=4.5,h=10,center=true);
            translate([0,0,-5-1.5+1.5]) rotate([90,0,0]) nut(8.15);
        }
        rotate([0,0,45]) translate([-77/2,-25/2,0]) {
            cylinder(d=4.5,h=10,center=true);
            translate([0,0,-5-1.5+1.5]) rotate([90,0,0]) nut(8.15);            
        }
        
        // hole for hinge to hole down acrylic
        rotate([0,0,45]) translate([-77/2-10,0,1.5]) {
            rotate([90,0,0]) cylinder(d=5,h=42,center=true);
        }

        // hole for clamp
        rotate([0,0,45]) translate([80/2,0,0]) {
            cylinder(d=4.5,h=20,center=true);
            translate([0,0,-5-1.5+1.5]) rotate([90,0,0]) nut(8.15);
//            translate([0,0,5+1.5-3.7+2]) rotate([90,0,0]) nut(8.15);  
        }        
        // hole for chamber clamp
        rotate([0,0,45]) translate([73.5+12.5+2.5,0,0]) {
            cylinder(d=4.5,h=20,center=true);
            translate([0,0,5+1.5-3.7]) rotate([90,0,0]) nut(8.15);  
        }        
      

   }

   

}  else if(object==ORING_PLACEMENT) {
    
    rotate([0,0,45]) 
        // 4 screw holes: 
        difference() {
            union() {
                rotate([0,0,-45]) cube([58+3*2,55+3*2,2],true);
                hull() {
                    translate([cyl_pelt_holes,0,0]) {
                        cylinder(d=20,h=2,center=true);
                    }
                    translate([0,-cyl_pelt_holes,0]) {
                        cylinder(d=20,h=2,center=true);
                    }
                }
                hull() {
                   translate([-cyl_pelt_holes,0,0]) {
                        cylinder(d=20,h=2,center=true);
                    }
                    translate([0,cyl_pelt_holes,0]) {
                        cylinder(d=20,h=2,center=true);
                    }                    
                }
            }
            translate([cyl_pelt_holes,0,0]) {
                cylinder(r=hole_rad,h=hole_hgt,center=true);
                translate([0,0,0.5]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
            }
            translate([0,-cyl_pelt_holes,0]) {
                cylinder(r=hole_rad,h=hole_hgt,center=true);
                translate([0,0,0.5]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
            }
            translate([-cyl_pelt_holes,0,0]) {
                cylinder(r=hole_rad,h=hole_hgt,center=true);
                translate([0,0,0.5]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
            }
            translate([0,cyl_pelt_holes,0]) {
                cylinder(r=hole_rad,h=hole_hgt,center=true);
                translate([0,0,0.5]) cylinder(r1=hole_rad,r2=5,h=2,center=true);
            }
            rotate([0,0,-45]) cube([58.6,55.6,4],true);
        }
    } 
    else if(object==NUT_AND_BOLT) {
    //metric_thread (diameter=2.5, pitch=1, length=45);
    difference() {
        union() {
            cylinder(r=1,h=45,center=true);
            translate([0,0,-45/2-1.]) cylinder(r=6/2,h=2,center=true);
            translate([0,0,4+38.5-22.5]) cylinder(r1=1.6,r2=1,h=8,center=true);
        }
        translate([0,0,17]) cube([4,0.7,6],true);
    }
} else if(object==FIXING) {
    difference() {
        union() {
            translate([0,-2.25,0]) {
                minkowski() {
                    cube([130-12,45.5-12,10],true);
                    cylinder(r=6,h=10,center=true);
                }
            }
            translate([0,-44/2+38.5,10+5]) cube([10,2,10],true); // notch
            
            // clip 1
            translate([92/2+1,0,15]) {
                difference() {
                    union() {
                        cube([2,15,10],true);
                        translate([-1,0,5-1]) cube([3,15,2],true);
                    }
                    rotate([0,-30,0]) translate([0,0,5]) cube([10,15,2],true);
                }
            }
            // clip 2
            rotate([0,0,180]) translate([92/2+1,0,15]) {
                difference() {
                    union() {
                        cube([2,15,10],true);
                        translate([-1,0,5-1]) cube([3,15,2],true);
                    }
                    rotate([0,-30,0]) translate([0,0,5]) cube([10,15,2],true);
                }
            }
            // clip 3
            rotate([0,0,-90]) translate([45/2+1.5,0,15]) {
                difference() {
                    union() {
                        cube([2,15,10],true);
                        translate([-1,0,5-1]) cube([3,15,2],true);
                    }
                    rotate([0,-30,0]) translate([0,0,5]) cube([10,15,2],true);
                }
            }
            
        }
        // holes for screws
        translate([55,0,0]) cylinder(r=2,h=25,center=true) ;
        translate([55,0,10-1]) cylinder(r1=2,r2=6.6,h=3.,center=true) ;
        translate([-55,0,0]) cylinder(r=2,h=25,center=true) ;
        translate([-55,0,10-1]) cylinder(r1=2,r2=6.6,h=3,center=true) ;
        
        
        // mating holes
        translate([65/2,0,10-7]) cylinder(r=6.5/2,h=14,center=true);
        translate([-65/2,0,10-7]) cylinder(r=6.5/2,h=14,center=true);

        translate([65/2,9,10-7]) cylinder(r=6.5/2,h=14,center=true);
        translate([-65/2,9,10-7]) cylinder(r=6.5/2,h=14,center=true);

        translate([65/2,-9,10-7]) cylinder(r=6.5/2,h=14,center=true);
        translate([-65/2,-9,10-7]) cylinder(r=6.5/2,h=14,center=true);
    }
    
} else if(object==GLASS_CLAMP) {
   difference() {
       union() {
           cylinder(r=65/2,h=6,center=true);
           cube([cyl_pelt_rad*2+1.5,6,6],true);
           cube([6,cyl_pelt_rad*2+1.5,6],true);
           
           // catch 1
           translate([cyl_pelt_rad+3,0,2+2+3.5/2+1.5]) cube([5,6,14+3.5+3],true);
           translate([cyl_pelt_rad+2+0.5,0,11+3.5+3]) rotate([90,0,0]) cylinder(r=3,h=6,center=true);
           // catch 2
           rotate([0,0,180]) {
            translate([cyl_pelt_rad+3,0,2+2+3.5/2+1.5]) cube([5,6,14+3.5+3],true);
            translate([cyl_pelt_rad+2+0.5,0,11+3.5+3]) rotate([90,0,0]) cylinder(r=3,h=6,center=true);
           }
           // catch 3
           rotate([0,0,90]) {
            translate([cyl_pelt_rad+3,0,2+2+3.5/2+1.5]) cube([5,6,14+3.5+3],true);
            translate([cyl_pelt_rad+2+0.5,0,11+3.5+3]) rotate([90,0,0]) cylinder(r=3,h=6,center=true);
           }
           // catch 4
           rotate([0,0,-90]) {
            translate([cyl_pelt_rad+3,0,2+2+3.5/2+1.5]) cube([5,6,14+3.5+3],true);
            translate([cyl_pelt_rad+2+0.5,0,11+3.5+3]) rotate([90,0,0]) cylinder(r=3,h=6,center=true);
           }
       }
       // bottom o-ring
       translate([0,0,3.5]) rotate_extrude() {
           translate([54/2,0,0]) rotate([0,0,45]) square(size=2.5,center=true);
       }
       cube([23,23,hole_hgt],true);
       translate([0,0,-6/2-hole_hgt/2+0.35]) cube([26,26,hole_hgt],true);
        
       // hole for sandwiching glass slide
       rotate([0,0,-45]) translate([43/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       rotate([0,0,45]) translate([43/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       rotate([0,0,135]) translate([43/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       rotate([0,0,225]) translate([43/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
   }
}  else if(object==GLASS_CLAMP2) {
   difference() {
       union() {
           //cylinder(r=65/2,h=6,center=true);
           //cube([65,65,6],true);
           minkowski() {
               cube([65-6,65-6,3],true);
               cylinder(r=3,h=3,center=true);
           }
           minkowski() {
               cube([cyl_pelt_rad*2-6,15,3],true);
               cylinder(r=3,h=3,center=true);
           }
           minkowski() {
               cube([15,cyl_pelt_rad*2-6,3],true);
               cylinder(r=3,h=3,center=true);
           }
           
       }
       // bottom o-ring
       translate([0,0,3.5]) rotate_extrude() {
           translate([54/2,0,0]) rotate([0,0,45]) square(size=2.5,center=true);
       }
       cube([23,23,hole_hgt],true);
       translate([0,0,-6/2-hole_hgt/2+0.35]) cube([26,26,hole_hgt],true);
        
       // hole for sandwiching glass slide
       rotate([0,0,-45]) translate([65/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       rotate([0,0,45]) translate([65/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       rotate([0,0,135]) translate([65/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       rotate([0,0,225]) translate([65/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);

       // cut out for clamp
       rotate([0,0,-5]) rotate_extrude(angle=24,convexity=10) {
           translate([75/2,0,0]) square([3,10],center=true);
       }
       rotate([0,0,-5+90]) rotate_extrude(angle=24,convexity=10) {
           translate([75/2,0,0]) square([3,10],center=true);
       }
       rotate([0,0,-5+180]) rotate_extrude(angle=24,convexity=10) {
           translate([75/2,0,0]) square([3,10],center=true);
       }
       rotate([0,0,-5+270]) rotate_extrude(angle=24,convexity=10) {
           translate([75/2,0,0]) square([3,10],center=true);
       }
      
       
   }

}  else if(object==GLASS_CLAMP3) {
   difference() {
       union() {
           //cylinder(r=65/2,h=6,center=true);
           //cube([65,65,6],true);
           minkowski() {
               cube([65-6,65-6,1],true);
               cylinder(r=3,h=1,center=true);
           }
           
       }
       cube([23,23,hole_hgt],true);
       // hole for sandwiching glass slide
       rotate([0,0,-45]) translate([65/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       rotate([0,0,45]) translate([65/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       rotate([0,0,135]) translate([65/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       rotate([0,0,225]) translate([65/2.,0,0]) cylinder(r=1.3,h=hole_hgt*2,center=true);
       
   }
    difference() {
        translate([0,0,-1-5]) cylinder(d=50,h=5);
        translate([0,0,-1-5]) cylinder(d=45,h=5);
    }

} 


module nut(size){
    $fn=6;
    translate([0,0,0]) rotate([90,0,0]) cylinder(d=size,h=10,center=true);
}

