#
# parse_dxf.py
#

from xml.etree.ElementTree import parse
from pprint import pprint
import pyprocessing as proc
from math import sqrt, acos, pi, atan, cos, sin
from random import choice

class Point():
    def __init__(self, name, code, coords):
        self.name = name
        self.code = code
        self.coords = coords
        self.x = coords[0]
        self.y = coords[1]
    def __repr__(self):
        return u'Point(%s,%s,(%f,%f))' % (self.name, self.code, self.x, self.y)

class Line():
    def __init__(self, k, m):
        self.k = k
        self.m = m
    def __repr__(self):
        return u'Line(%f,%f)' % (self.k, self.m)

class Problem():
    def __init__(self, x, y, k, m, a, b, p, q):
        self.x = x
        self.y = y
        self.k = k
        self.m = m
        self.a = a
        self.b = b
        self.p = p
        self.q = q
    def __repr__(self):
        return u'Problem(%f,%f,%f,%f,%s,%s,%s,%s)' % (self.x, self.y, self.k, self.m, self.a, self.b, self.p, self.q)

def parse_code(c):
    parts = c.split()
    if len(parts) == 1:
        return ''
    else:
        return parts[1]
        
def parse_point(p):
    name = p.find('Name').text
    code = parse_code(p.find('Code').text)
    coords = (35.0 * (float(p.find('Grid/East').text) - 142025),
              35.0 * (float(p.find('Grid/North').text) - 6169660))
    return Point(name, code, coords)

def tangent_from_points(p, q, r):
    dy = (q.y - r.y)
    dx = (q.x - r.x)
    k = dy / dx
    m = p.y - k * p.x
    return Line(k, m)
    
def solve(problem):
    print '----solving----'
    circles = [ ]
    best_error = 100000000
    
    step_size = 0.1
    step_start = -1000.0
    step_stop = 1000.0
    step_distance = step_stop - step_start
    step_count = step_distance / step_size
    
    steps = [ (step_start + step_size * k) for k in range(int(step_count)) ]
    print len(steps), 'steps'
    print 'first steps', steps[0:10]
    
    horizontal = abs(problem.a.x - problem.b.x) > abs(problem.a.y - problem.b.y)
    
    for step in steps:
        if horizontal:
            x = problem.x + step
            y = problem.k * x + problem.m
        else:
            y = problem.y + step
            x = (y - problem.m) / problem.k
        radius = distance(problem.a.x, problem.a.y, x, y)
        
        # Calculate tangent for a
        dx = (problem.a.x - x)
        dy = (problem.a.y - y)
        a_k = -dx / dy
        error_a = a_k - problem.p.k
        
        # Calculate tangent for b
        dx = (problem.b.x - x)
        dy = (problem.b.y - y)
        b_k = -dx / dy
        error_b = b_k - problem.q.k

        error = sqrt(error_a**2 + error_b**2)
        
        if error < best_error:
            best_error = error
            best_x = x
            best_y = y
            best_radius = radius
            
    if best_y < problem.a.y:
        angle_a = acos((problem.a.x - best_x)/best_radius)
        angle_b = acos((problem.b.x - best_x)/best_radius)
    else:
        angle_a = pi + acos((best_x - problem.a.x)/best_radius)
        angle_b = pi + acos((best_x - problem.b.x)/best_radius)
    return (best_x, best_y, best_radius, angle_a, angle_b, best_error)
    
    
def render(points, tangents, problems, arcs):
    proc.size(1024, 576)
    proc.background(255, 255, 255)
    proc.smooth()
    for k in range(len(points)):
        if tangents[k]:
            p = points[k]
            l = tangents[k]
            if l.k and l.m:
                x0 = p.x - 5
                y0 = l.k * x0 + l.m
                x1 = p.x + 5
                y1 = l.k * x1 + l.m
                # proc.line(x0, y0, x1, y1)
    if False:
        proc.fill(0, 255, 0)
        for problem in problems:
            proc.rect(problem.x-2, problem.y-2, 4, 4)
            x0 = problem.x - 5
            y0 = problem.k * x0 + problem.m
            x1 = problem.x + 5
            y1 = problem.k * x1 + problem.m
            proc.line(x0, y0, x1, y1)
    # arcs
    proc.ellipseMode(proc.RADIUS)
    proc.noFill()
    for circle in circles:
        proc.stroke(127, 127, 127, 15)
        proc.ellipse(circle[0], circle[1], circle[2], circle[2])
        proc.stroke(0, 0, 0, 255)
        proc.arc(circle[0], circle[1], circle[2], circle[2], circle[3], circle[4])
    # Points
    proc.fill(255, 0, 0)
    proc.stroke(0, 0, 0)
    for p in points:
        proc.rect(p.x-2, p.y-2, 4, 4)
    proc.run()

def distance(x0, y0, x1, y1):
    return sqrt((y1-y0)**2 + (x1-x0)**2)
    
def formulate_problem(a, b, p, q):
    # Find midpoint
    dx = (b.x - a.x)
    dy = (b.y - a.y)
    c_x = a.x + dx / 2.0
    c_y = a.y + dy / 2.0
    
    # Get perpendicular line
    c_k = -dx / dy
    c_m = c_y - c_k * c_x
    return Problem(c_x, c_y, c_k, c_m, a, b, p, q)
    
if __name__ == '__main__':
    tree = parse('158.jxl')
    root = tree.getroot()
    points = [ parse_point(point) for point in root.findall('.//Point') ]
    pprint(points)
    tangents = [ ]
    active = False
    # find tangents
    for k in range(len(points)):
        point = points[k]
        if point.code == 'C1':
            tangent = tangent_from_points(point, point, points[k-1])
            active = True
        elif point.code == 'C2':
            tangent = tangent_from_points(point, points[k+1], point)
            active = False
        else:
            if active:
                tangent = tangent_from_points(point, points[k+1], points[k-1])
            else:
                tangent = None
        tangents.append(tangent)
    pprint(tangents)
    # get problems that need to be solved
    problems = [ ]
    for k in range(len(points) - 1):
        if tangents[k] and tangents[k+1]:
            problems.append(formulate_problem(points[k], points[k+1],
                            tangents[k], tangents[k+1]))
    pprint(problems)
    circles = map(solve, problems)
    pprint(circles)
    render(points, tangents, problems, circles)
    