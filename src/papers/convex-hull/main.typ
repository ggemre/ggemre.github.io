#import "template.typ": *

#show: project.with(
  title: "Convex Hull",
  authors: (
    "Gage Moore",
  ),
  date: "October 1, 2023",
)


= Introduction
The convex hull problem describes a set of points that must be bounded by the smallest possible polygon in which every point either lies on the polygon's borders or within its interior. It has applications in a variety of domains from image processing to financial analysis.

This algorithm finds the convex hull given points across a 2-D plane using a divide and conquer approach, in which the points are split into left and right subsets recursively during the calculation.

= Time and Space Complexity

=== Max and min functions
The following two functions calculate the maximum value and the minimum value of the given set of points respectively.

```py
def max(self, points):
  maximum_point = points[0]

  for point in points:
    if point.x() >= maximum_point.x():
      maximum_point = point

  return maximum_point
  
def min(self, points):
  minimum_point = points[0]

  for point in points:
    if point.x() <= minimum_point.x():
      minimum_point = point

  return minimum_point
```

Both functions behave very similarily and each have a time complexity of $O(n)$ because the points are iterated from the beginning to end once. The space complexity is $O(1)$ for each function because the maxiumum/minimum is stored in a single variable that is updated when needed, aside from this there is no dynamic space allocation.

=== Maximum distance function
The following function finds the single point with the maximum distance from a line between two extreme points.

```py
def max_distance(self, min_extreme, max_extreme, points):
  max_distance = 0
  max_index = 0

  for i in range(0, len(points)):
    curr_distance = abs((points[i].y() - min_extreme.y()) *  
                        (max_extreme.x() - min_extreme.x()) - 
                        (max_extreme.y() - min_extreme.y()) * 
                        (points[i].x() - min_extreme.x()))
    if curr_distance > max_distance:
      max_distance = curr_distance
      max_index = i

  return points[max_index]
```

Like before, the function iterates through each point, calculating the distance between it and the line, (a constant time operation), and updating the associated variables when necessary. It's time complexity is $O(n)$ with a space complexity of $O(1)$.

=== Divide function
This function takes a set of points and splits them into two lists for the leftmost and rightmost points.

```py
def divide(self, min_extreme, max_extreme, points):
  left_hull = []
  right_hull = []

  for point in points:
    determinant = (min_extreme.x() * max_extreme.y()) + \
            (min_extreme.y() * point.x()) + (max_extreme.x() * point.y()) - \
            (point.x() * max_extreme.y()) - (point.y() * min_extreme.x()) - \
            (max_extreme.x() * min_extreme.y())

    if point != min_extreme:
      if point != max_extreme:
        if determinant > 0:
          left_hull.append(point)
        if determinant < 0:
          right_hull.append(point)

  return left_hull, right_hull
```

It works in a similar fashion to the maximum distance function, except it calculates the determinant of each point to identify its location relative to the given extreme points, (left or right), and it stores the points in two growing lists that will each grow to hold $n/2$ elements. As a result, the time complexity is $O(n)$ since it iterates over each $n$ points once, and the space complexity is $O(n)$, since the two lists will grow by a combined $n$ elements.

=== Find sub hull functions
The following two functions perform the same recursive procedure on a set of points. Each splits the list of points into two lists, (left and right), then adds the furthest point from the given centerline to the full convex hull, (called `polygon` in this case). If the number of points in a subhull is 0, it exits out of the recursive calls.

```py
def find_left_hull(self, points, min_extreme, max_extreme):
  if len(points) == 0: return

  else:
    max_point = self.max_distance(min_extreme, max_extreme, points)
    first_side, _ = self.divide(min_extreme, max_point, points)
    second_side, _ = self.divide(max_point, max_extreme, points)
    points.remove(max_point)
    self.polygon.append(max_point)
    self.find_left_hull(first_side, min_extreme, max_point)
    self.find_left_hull(second_side, max_point, max_extreme)


def find_right_hull(self, points, min_extreme, max_extreme):
  if len(points) == 0: return

  else:
    max_point = self.max_distance(min_extreme, max_extreme, points)
    _, first_side = self.divide(min_extreme, max_point, points)
    _, second_side = self.divide(max_point, max_extreme, points)
    points.remove(max_point)
    self.polygon.append(max_point)
    self.find_right_hull(first_side, min_extreme, max_point)
    self.find_right_hull(second_side, max_point, max_extreme)
```

For both functions, each recursive call works on half the number of points as before, ($O(log n)$). Within each recursion, by dividing the points and calculating the maximum distance, the time complexity if $O(n)$. As a result, the full time complexity of both functions is $O(n log n)$.

The space complexity is based on the variables `left_hull` and `right_hull`, both of which grow to hold $n/2$ points. As a result, both of the above functions have a space complexity of $O(n)$.

=== Find hull parent function
The main function to calculate the convex hull of a set of points is given below.

```py
def find_hull(self, points):
  self.polygon = []
  list_of_lines = []
  min_extreme = self.min(points)
  max_extreme = self.max(points)
  self.polygon.append(min_extreme)
  self.polygon.append(max_extreme)

  # divide the points into left & right
  left_hull, right_hull = self.divide(min_extreme, max_extreme, points)

  # recursively find the convex hull for each side
  self.find_left_hull(left_hull, min_extreme, max_extreme)
  self.find_right_hull(right_hull, min_extreme, max_extreme)

  # sort points by angle
  central_x = sum(point.x() for point in self.polygon) / len(self.polygon)
  central_y = sum(point.y() for point in self.polygon) / len(self.polygon)
  self.polygon.sort(key = lambda point: atan2(point.x() - central_x, point.y() - central_y))

  # iterate through circular list of points to generate lines
  for i in range(0, len(self.polygon)):
    if i == len(self.polygon)-1:
      list_of_lines.append(QLineF(self.polygon[i],self.polygon[0]))
    else:
      list_of_lines.append(QLineF(self.polygon[i],self.polygon[i+1]))

  return list_of_lines
```

It divides the sorted points into two lists, one for the leftmost points and one for the rightmost points. After this, the recursive sub hull functions are run on each sublist which ultimately stores all of the outermost points into the `polygon` variable. This list is sorted in the order that is conducive to pairing up each line of the polygon's border, (according to angle), and lines are generated on each two points. The time complexity falls within $O(n log n)$ because the recursive functions `find_left_hull()` and `find_right_hull()` supersede the $O(n)$ calculations, such as when forming the lines or the `divide()` function.

The worst case scenario for the space complexity is $O(n)$, because the polygon variable will at most grow to contain every point passed into `find_hull()`. 

=== Entrance function
The following function is called by the GUI in order to visualize the convex hull algorithm described above. It sorts the points by the x-axis and calls `find_hull()`. It also has a time complexity of $O(n log n)$ due to the `find_hull()` call and a space complexity of $O(n)$ since it calls the `find_hull()` function, which grows the `polygon` class variable.

```py
def compute_hull( self, points, pause, view):
  self.pause = pause
  self.view = view
  assert( type(points) == list and type(points[0]) == QPointF )

  t1 = time.time()
  points = sorted(points, key=lambda p: p.x())
  t2 = time.time()

  t3 = time.time()
  polygon = self.find_hull(points)
  t4 = time.time()

  # when passing lines to the display, pass a list of QLineF objects.  Each QLineF
  # object can be created with two QPointF objects corresponding to the endpoints
  self.showHull(polygon,RED)
  self.showText('Time Elapsed (Convex Hull): {:3.3f} sec'.format(t4-t3))
```

= Performance Analysis
In order to evaluate the performance of my algorithm, I ran it against the following values of $n$, where $n$ is the number of points across the 2-D plane, with 5 rounds for each $n$ value: $n in {10, 100, 1000, 10000, 100000, 500000, 1000000}$. The results from that experiment are as follows, (truncated to the nearest thousandth):

#table(
  columns: (auto, auto, auto),
  inset: 10pt,
  align: horizon,
  [*n*], [*Times (in seconds)*], [*Mean*],
  [10], [0, 0, 0.001, 0, 0], [0.0002],
  [100], [0.002, 0.002, 0.003, 0.002, 0.003], [0.0024],
  [1000], [0.018, 0.015, 0.017, 0.016, 0.016], [0.0164],
  [10000], [0.166, 0.149, 0.150, 0.153, 0.151], [0.1538],
  [100000], [1.962, 1.610, 1.616, 1.657, 1.603], [1.6896],
  [500000], [8.891, 8.297, 8.163, 8.205, 8.298], [8.3708],
  [1000000], [18.026, 16.540, 16.660, 17.978, 17.969], [17.4346]
)

Graphing the means from the table above reveals an interesting pattern. The graph below plots the mean values as red dots alongside $n log n$ as the blue line for comparison. The entire plot is on a logarithmic scale, so logarithmic data will appear linear.

#image("theoretical.png", height: 30%)

Our experimental data is closely parallel to the theoretical data shown in the graph above, (comparing the blue line to the red points). This indicates that our algorithm is correctly implemented in the $O(n log n)$ procedure as described by the powerpoint and textbook. The experimental and theoretical data does not completely overlap, (the blue line lies $4.66567475$ units higher than the red points on average), because of minor factors related to the speed of my computer and the context of using wall clock time as opposed to a more agnostic way to measure performance.

The constant of proportionality between the two lines is $0.97886651$, meaning the slope of the blue line, ($n log n$) multiplied by this constant is roughly equal to the approximated slope of our experimental data.

= Example Screenshots
Below are some examples of the algorithm as visualized by a separate UI. Included are 100 points and 1000 points, (each with uniform and gaussian examples).

#table(
  columns: (auto),
  inset: 0pt,
  align: horizon,
  stroke: none,
  [#image("Screen Shot 2023-09-27 at 9.14.26 PM.png", fit: "contain", height: 50%)],
  [#image("Screen Shot 2023-09-27 at 9.16.44 PM.png", fit: "contain", height: 50%)],
  [#image("Screen Shot 2023-09-27 at 9.17.12 PM.png", fit: "contain", height: 50%)],
  [#image("Screen Shot 2023-09-27 at 9.17.25 PM.png", fit: "contain", height: 50%)]
)









= The Full Code
```py
from which_pyqt import PYQT_VER
if PYQT_VER == 'PYQT5':
	from PyQt5.QtCore import QLineF, QPointF, QObject
elif PYQT_VER == 'PYQT4':
	from PyQt4.QtCore import QLineF, QPointF, QObject
elif PYQT_VER == 'PYQT6':
	from PyQt6.QtCore import QLineF, QPointF, QObject
else:
	raise Exception('Unsupported Version of PyQt: {}'.format(PYQT_VER))


import time
from math import atan2

# Some global color constants that might be useful
RED = (255,0,0)
GREEN = (0,255,0)
BLUE = (0,0,255)

# Global variable that controls the speed of the recursion automation, in seconds
PAUSE = 0.25

#
# This is the class you have to complete.
#
class ConvexHullSolver(QObject):

# Class constructor
	def __init__( self):
		super().__init__()
		self.pause = False

# Some helper methods that make calls to the GUI, allowing us to send updates
# to be displayed.

	def showTangent(self, line, color):
		self.view.addLines(line,color)
		if self.pause:
			time.sleep(PAUSE)

	def eraseTangent(self, line):
		self.view.clearLines(line)

	def blinkTangent(self,line,color):
		self.showTangent(line,color)
		self.eraseTangent(line)

	def showHull(self, polygon, color):
		self.view.addLines(polygon,color)
		if self.pause:
			time.sleep(PAUSE)

	def eraseHull(self,polygon):
		self.view.clearLines(polygon)

	def showText(self,text):
		self.view.displayStatusText(text)


	polygon = []


	'''
	Return the maximum point out of a list of points.
	Iterate through each point in points list once, comparing to current maximum point.
	Time complexity: O(n)
	Space complexity: O(1)
	'''
	def max(self, points):
		maximum_point = points[0]

		for point in points:
			if point.x() >= maximum_point.x():
				maximum_point = point

		return maximum_point
	

	'''
	Return the minumum point out of a list of points.
	Iterate through each point in points list once, comparing to current minimum point.
	Time complexity: O(n)
	Space complexity: O(1)
	'''
	def min(self, points):
		minimum_point = points[0]

		for point in points:
			if point.x() <= minimum_point.x():
				minimum_point = point

		return minimum_point
		

	'''
	Finds the point with the maximum distance from a line.
	Iterate through each point in points list once, comparing to current maximum distance.
	Time complexity: O(n)
	Space complexity: O(1)
	'''
	def max_distance(self, min_extreme, max_extreme, points):
		max_distance = 0
		max_index = 0

		for i in range(0, len(points)):
			curr_distance = abs((points[i].y() - min_extreme.y()) * (max_extreme.x() - min_extreme.x()) - 
					   			(max_extreme.y() - min_extreme.y()) * (points[i].x() - min_extreme.x()))
			if curr_distance > max_distance:
				max_distance = curr_distance
				max_index = i

		return points[max_index]
	

	'''
	Split the points into two lists, one for the left side of the line and one for the right side of the line.
	Time complexity: O(n)
	Space complexity: O(n)
	'''
	def divide(self, min_extreme, max_extreme, points):
		left_hull = []
		right_hull = []

		for point in points:
			determinant = (min_extreme.x() * max_extreme.y()) + \
						  (min_extreme.y() * point.x()) + (max_extreme.x() * point.y()) - \
						  (point.x() * max_extreme.y()) - (point.y() * min_extreme.x()) - \
						  (max_extreme.x() * min_extreme.y())

			if point != min_extreme:
				if point != max_extreme:
					if determinant > 0:
						left_hull.append(point)
					if determinant < 0:
						right_hull.append(point)

		return left_hull, right_hull


	'''
	Given a list of points, return the convex hull (left side).
	Each recursive call works on half of the points from before.
	Time complexity: O(nlogn)
	Space complexity: O(n)
	'''
	def find_left_hull(self, points, min_extreme, max_extreme):
		if len(points) == 0: return

		else:
			max_point = self.max_distance(min_extreme, max_extreme, points)
			first_side, _ = self.divide(min_extreme, max_point, points)
			second_side, _ = self.divide(max_point, max_extreme, points)
			points.remove(max_point)
			self.polygon.append(max_point)
			self.find_left_hull(first_side, min_extreme, max_point)
			self.find_left_hull(second_side, max_point, max_extreme)


	'''
	Given a list of points, return the convex hull (right side).
	Each recursive call works on half of the points from before.
	Time complexity: O(nlogn)
	Space complexity: O(n)
	'''
	def find_right_hull(self, points, min_extreme, max_extreme):
		if len(points) == 0: return

		else:
			max_point = self.max_distance(min_extreme, max_extreme, points)
			_, first_side = self.divide(min_extreme, max_point, points)
			_, second_side = self.divide(max_point, max_extreme, points)
			points.remove(max_point)
			self.polygon.append(max_point)
			self.find_right_hull(first_side, min_extreme, max_point)
			self.find_right_hull(second_side, max_point, max_extreme)


	'''
	Calculate the convex hull given a list of points.
	Time complexity: O(nlogn)
	Space complexity: O(n)
	'''
	def find_hull(self, points):
		self.polygon = []
		list_of_lines = []
		min_extreme = self.min(points)
		max_extreme = self.max(points)
		self.polygon.append(min_extreme)
		self.polygon.append(max_extreme)

		# divide the points into right & left
		left_hull, right_hull = self.divide(min_extreme, max_extreme, points)

		# recursively find the convex hull for each side
		self.find_left_hull(left_hull, min_extreme, max_extreme)
		self.find_right_hull(right_hull, min_extreme, max_extreme)

		# sort points by angle
		central_x = sum(point.x() for point in self.polygon) / len(self.polygon)
		central_y = sum(point.y() for point in self.polygon) / len(self.polygon)
		self.polygon.sort(key = lambda point: atan2(point.x() - central_x, point.y() - central_y))

		# iterate through circular list of points to generate lines
		for i in range(0, len(self.polygon)):
			if i == len(self.polygon)-1:
				list_of_lines.append(QLineF(self.polygon[i],self.polygon[0]))
			else:
				list_of_lines.append(QLineF(self.polygon[i],self.polygon[i+1]))

		return list_of_lines

	'''
	This is the method that gets called by the GUI and actually executes the finding of the hull
	Time complexity: O(nlogn)
	Space complexity: O(n)
	'''
	def compute_hull( self, points, pause, view):
		self.pause = pause
		self.view = view
		assert( type(points) == list and type(points[0]) == QPointF )

		t1 = time.time()
		points = sorted(points, key=lambda p: p.x())
		t2 = time.time()

		t3 = time.time()
		polygon = self.find_hull(points)
		t4 = time.time()

		# when passing lines to the display, pass a list of QLineF objects.  Each QLineF
		# object can be created with two QPointF objects corresponding to the endpoints
		self.showHull(polygon,RED)
		self.showText('Time Elapsed (Convex Hull): {:3.3f} sec'.format(t4-t3))

```
