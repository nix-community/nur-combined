/*
Fast voronoi generator (function version) - requires the BOSL2 library
by Alex Matulich
April 2024

On Printables: https://www.printables.com/model/831732
On Thingiverse: https://www.thingiverse.com/thing:6563356

Usage:
------
// must use "include" rather than "use"!
include <fastvoronoi_func_bosl2.scad> // includes standard and rounding BOSL2 libraries 

// 1. Generate an array of random points compatible with fast voronoi
points = voronoi_array(cellsize, [xmin], [xmax], [ymin], [ymax], [allowable], [seed]);

// 2. Generate array of polygon vertices for voronoi pattern
polygon_vertices = fastvoronoi(points, cellsize, [thickness], [rcorner]);


The fastvoronoi() function generates an array of 2D polygon vertices. Each polygon can be rendered individually using linear_extrude() and polygon(), or using the BOSL2 functions like offset_sweep() for making extrusions with rounded edges.

The helper function voronoi_array() (from fastvoronoi.scad) creates an array of random nuclei locations such that each grid cell contains one nucleus, which is necessary for fastvoronoi() to work.

*/

include <BOSL2/std.scad>
include <BOSL2/rounding.scad>
include <fastvoronoi.scad>

// example of BOSL2-beveled pattern using more uniform random spacing
//demo(); // uncomment this line to view demo, comment it again before importing this script

// This demo appears slow because we are manipulating vertices directly rather than relying on OpenSCAD's internal polygon and intersection operations. Also the BOSL2 offset_sweep() operation also adds execution time.

module demo() {
    xsize = 100;
    ysize = 80;
    margin = 0.1;
    cellsize = 15;

    point_set = voronoi_array(cellsize=cellsize, xmin=margin, xmax=xsize-margin, ymin=margin, ymax=ysize-margin, allowable=0.95, seed=1234);

    vpoly = intersection(fastvoronoi(point_set, cellsize=15, thickness=3, rcorner=1), move([5,5], square([75,60])));

    difference() {
        cube([85, 70, 3]);
        translate([0,0,-0.1]) for(i=[0:len(vpoly)-1])
            offset_sweep(vpoly[i], height=3.2, bottom=os_chamfer(width=-0.9), top=os_chamfer(width=-0.9));
    }
    for(p=point_set) translate(p) color("blue") cylinder(10,d=2, $fn=8);
}
// ---------- functions ----------

/*
fast voronoi function - returns an array of polygon vertices for each cell

Parameters:
    points (required) = array of [x,y] nucleus coordinates with one nucleus per grid square
    cellsize (required) = size of a grid square that contains one nucleus
    thickness = width of boundaries between the cells (must be >0)
    rcorner = corner radius at cell corners (may be zero)

This function REQUIRES that points[] array of nuclei locations have ONE nucleus located randomly inside EACH grid cell of size 'cellsize'. You can build this points array using the voronoi_array() function below.
*/
function fastvoronoi(points, cellsize, thickness=3, rcorner=1) = let(maxsep = 2.1*sqrt(2)*cellsize) voronoi(points, maxsep, thickness, rcorner);

/*
voronoi function - returns an array of polygon vertices
called by fastvoronoi() function
calls normalize() from fastvoronoi.scad

Parameters:
    points (required) = array of [x,y] nucleus coordinates
    R = approximate radius of the "world" in which the pattern is built - this is a small value for fastvoronoi() but should be at least twice the size of the biggest bounding box dimension otherwise
    thickness = width of boundaries between the cells (must be >0)
    rcorner = corner radius at cell corners (may be zero)
*/
function voronoi(points, R=200, thickness=3, rcorner=1) = let(rect = [[-R,-R], [R,-R], [R,0], [-R,0]], rsquare = R*R) [
    for (p = points) let(
        rectangles = [
            for(p1=points) let(pdiff=p1-p)
                if (p != p1 && pdiff[0]*pdiff[0]+pdiff[1]*pdiff[1] <= rsquare) let(
                    angle = 90 + atan2(p[1]-p1[1], p[0]-p1[0]),
                    xlate = (p+p1)/2 - normalize(p1-p) * (thickness/2 + rcorner)
                ) move(xlate, zrot(angle, rect))
        ],
        vcell = intersection_paths(rectangles)
    ) if(len(vcell)>0) offset(vcell[0], r=rcorner, closed=true, $fn=16)
];

// calculate intersection of an array of polygon paths

function intersection_paths(p, i=0, res=undef) =
len(p)-1 <= i ? (res==undef ? p[0] : res) :
    (i==0 ? intersection_paths(p, 1, intersection(p[0], p[1]))
        : intersection_paths(p, i+1, intersection(res, p[i+1])));
