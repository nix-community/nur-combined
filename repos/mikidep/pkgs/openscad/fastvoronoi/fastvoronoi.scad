/*
Fast voronoi generator - for use with BOSL2 library
by Alex Matulich
April 2024

On Printables: https://www.printables.com/model/831732
On Thingiverse: https://www.thingiverse.com/thing:6563356

Inspired by OpenSCAD Voronoi Generator by Felipe Sanches at https://www.thingiverse.com/thing:47649

Usage:
------
use <fastvoronoi.scad>

// display a fast voronoi pattern with voronoi cells averaging 'cellsize' in
// size, in a rectangle bounded by [xmin,ymin], [xmax,ymax] with
// boundaries of 'thickness' size and 'rcorner' radius between boundariesrandom_voronoi(cellsize, [xmin], [xmax], [ymin], [ymax], [thickness], [rcorner], [$fn]);

// The random_voronoi() module above does the following, which you can do separately:

// 1. Generate an array of random points compatible with fast voronoi
points = voronoi_array(cellsize, [xmin], [xmax], [ymin], [ymax], [allowable], [seed]);

// 2. display the voronoi pattern
fastvoronoi(points, cellsize, [thickness], [corner_radius]);


Speed improvements:
-------------------
The original voronoi algorithm requires N^2 intersection() operations, which is slow. For exmample, 100 nucleus points requires 10,000 (100^2) intersection operations.

By comparison, this fastvoronoi method requires 8*N intersection operations (depending on how points are distributed; some nuclei may require 9 or 10 operations). Therefore, 100 nuclei require about 800-1000 intersections, less than 10% of the original! Moreover, the execution time increases LINEARLY with the number of points, rather than exponentially. In practice, the execution is a bit slower due to overhead from other operations taking place.

How does this work? We generate an array of randomly located nuclei on a grid, such that each grid square contains exactly one nucleus. The nucleus can be anywhere in the grid square (and can be confined further by the 'allowable' parameter). This arrangement still looks random, but guarantees that each voronoi cell is constructed from nuclei no more than two grid squares apart. Therefore, to generate any voronoi cell around a given nucleus, we can ignore any other nuclei more than this distance away.

Because each grid cell (except those on the edges and corners) have 8 other cells around it, the nucleus in a given cell is never further than two cells away diagnoally. Typically 8 intersections would be needed to calculate the voronoi cell shape for a given nucleus, and maybe an extra intersection or two for special cases where nuclei are bunched into their grid square corners causing more than 8 nuclei to be within a radius the size of two grid square diagonals.

Initial changes to original code by Felipe Sanches:
---------------------------------------------------
* Stripped out the minkowski() operation and substituted offset() instead, but that made only a tiny difference in execution speed, likely because minkowski() in 2D on a polygon with few sides is pretty fast.
* Corrected thickness error (boundaries were twice as thick as they should have been). This of course made no difference in speed, it was a bugfix.

Functional improvements:
------------------------
* The fastvoronoi() module generates a 2D voronoi pattern based on an array of nucleus coordinates provided, like the original version.
* The helper function voronoi_array() creates an array of random nuclei locations such that each grid cell contains one nucleus, which is necessary for fastvoronoi() to work.
* Rewrote the original random_voronoi() wrapper to work with the fastvoronoi() module.
*/


// ---------- demo (comment/uncomment as needed) ----------

// example random fast voronoi pattern subtracted from a rectangle
// COMMENT OUT THIS LINE before you include this script elsewhere!
//color("lightblue") linear_extrude(3, convexity=10) random_voronoi(cellsize=10, xmin=0, xmax=100, ymin=0, ymax=80, thickness=2, rcorner=1.5, $fn=16);

/*
Benchmark results on my computer, testing 400 points in a 20x20 array of cells.
Testing 400 points in a 20x20 array on my computer. Times are approximate averages from several runs. Fast voronoi is about 12 times faster.

Voronoi times include 0.27 sec of array initializing:
* fastvoronoi() = 1.3 sec
* voronoi using offset() instead of minkowski() = ~16 sec
* original voronoi by Felipe Sanches (using minkowski) = ~16 sec

*/

// uncomment this block to do benchmarks

// initialize = 0.24 sec average
cellsize = 5;
bpoints = voronoi_array(cellsize=cellsize, xmin=0, xmax=100, ymin=0, ymax=100, seed=1234);
// fast voronoi - uncomment to measure
//color("blue") fastvoronoi(bpoints, cellsize, thickness=1, rcorner=0.1, $fn=20);
// voronoi using offset() instead of minkowski()
//voronoi(points=bpoints, R=200, thickness=1, rcorner=0.1, $fn=20);
// original voronoi by Felipe Sanches - uncomment to measure
//felipe_sanches_voronoi(points=bpoints, L=200, thickness=0.5, round=0.1, nuclei=false);



// ---------- modules ----------

/*
The random_voronoi() module is a wrapper to generate a fast voronoi pattern from random nuclei sites distributed into a rectangular area.

Parameters:
    cellsize (required) = size of a grid square that contains one nucleus 
    xmin, xmax = minimum and maximum x coordinates
    ymin, ymax = minimum and maximum y coordinates
    thickness = thickness of boundaries between cells
    rcorner = radius of cell corners
    allowable = fraction of a grid cell available for locating a nucleus
    seed = optional seed for the random number generator (random if undefined)
*/
module random_voronoi(cellsize, xmin=0, xmax=100, ymin=0, ymax=80, thickness=2, rcorner=1, allowable=0.95, seed=undef) {
	rseed = seed == undef ? round(rands(0, 10000, 1)[0]) : seed;
	echo("Seed", rseed);
    points = voronoi_array(cellsize=cellsize, xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, allowable=allowable, seed=rseed);
    difference() {
        translate([xmin,ymin]) square([xmax-xmin, ymax-ymin]);
        fastvoronoi(points, cellsize, thickness=thickness, rcorner=rcorner);
    }
}

/*
fast voronoi module

Parameters:
    points (required) = array of [x,y] nucleus coordinates with one nucleus per grid square
    cellsize (required) = size of a grid square that contains one nucleus
    thickness = width of boundaries between the cells (must be >0)
    rcorner = corner radius at cell corners (may be zero)

This module REQUIRES that points[] array of nuclei locations have ONE nucleus located randomly inside EACH grid cell of size 'cellsize'. You can build this points array using the voronoi_array() function below.
*/
module fastvoronoi(points, cellsize, thickness=3, rcorner=1) {
    maxsep = 2.1*sqrt(2)*cellsize;
    voronoi(points, maxsep, thickness=thickness, rcorner=rcorner);
}

/*
voronoi module - called by fastvoronoi()

Parameters:
    points (required) = array of [x,y] nucleus coordinates
    R = approximate radius of the "world" in which the pattern is built - this is a small value for fastvoronoi() but should be at least twice the size of the biggest bounding box dimension otherwise
    thickness = width of boundaries between the cells (must be >0)
    rcorner = corner radius at cell corners (may be zero)
*/
module voronoi(points, R=200, thickness=3, rcorner=1) {
    rsquare = R*R;
	offset(r=rcorner, $fn=16) for (p = points) {
        intersection_for(p1 = points) {
            pdiff = p1-p;
            if (p != p1 && pdiff[0]*pdiff[0]+pdiff[1]*pdiff[1] <= rsquare ) {
                angle = 90 + atan2(p[1]-p1[1], p[0]-p1[0]);
                translate((p+p1)/2 - normalize(p1-p) * (thickness/2 + rcorner))
                    rotate([0,0,angle]) translate([-R,-R])
                        square([R+R, R]);
            }
        }
	}
}


// original voronoi module for benchmarking
module felipe_sanches_voronoi(points, L=200, thickness=3, round=1, nuclei=false) {
	for (p = points) {
		difference() {
			minkowski() {
				intersection_for(p1 = points){
					if (p != p1) {
						angle = 90 + atan2(p[1] - p1[1], p[0] - p1[0]);
						translate((p+p1)/2 - normalize(p1-p) * (thickness+round))
						rotate([0, 0, angle]) translate([-L, -L]) square([2 * L, L]);
					}
				}
				circle(r = round, $fn = 20);
			}
			if (nuclei)	translate(p) circle(r = 1, $fn = 20);
		}
	}
}


// ---------- helper functions ----------

// helper functions

// convert a vector to length 1, maintaining directional orientation
function normalize(v) = v / (sqrt(v[0] * v[0] + v[1] * v[1]));

/*
The voronoi_array() function generates an array of randomly-located nuclei, but avoids the clumping characteristic of sparse random distributions. The voronoi area is subdivided into a grid, and each nucleus is located randomly within its own grid cell. The 'allowable' parameter determines how far from the center of the grid cell the nucleus can be, with 1.0 allowing it to be anywhere in the grid cell.

Parameters:
    cellsize = grid cell size; average spacing between randomly-positioned nuclei
    xmin, xmax = minimum and maximum x values for voronoi area
    ymin, ymax = minimum and maxiumy y values for voronoi area
    allowable = how much of a grid cell is available for random location of a nucleus; 0=all nuclei are in the center of each cell, 1.0=all nuclei can occupy any location in their cells.
*/
function voronoi_array(cellsize=10, xmin=0, xmax=100, ymin=0, ymax=80, allowable=0.99, seed=undef) = let(
    sd = seed == undef ? round(rands(0, 10000, 1)[0]) : seed,
    hs = cellsize/2,
    xgrids = floor((xmax-xmin) / cellsize),
    ygrids = floor((ymax-ymin) / cellsize),
    seedinc = 0.5*(sqrt(5)+1),
    rnd = [
        for(y=[0:ygrids]) [
            rands(hs-allowable*hs, hs+allowable*hs, xgrids+1, sd+y),
            rands(hs-allowable*hs, hs+allowable*hs, xgrids+1, sd+y+seedinc),
            rands(0,1, xgrids+1, sd+y+2*seedinc)
        ]
    ]
    ) [ for(y=[0:ygrids]) for(x=[0:xgrids])
        [ x*cellsize+rnd[y][0][x]+xmin-hs, y*cellsize+rnd[y][1][x]+ymin-hs ]
];
