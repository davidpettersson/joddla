#
# parse_dxf.py
#

from xml.etree.ElementTree import parse
from pprint import pprint
import pyprocessing as proc
from math import sqrt

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
    coords = (15.0 * (float(p.find('Grid/East').text) - 142000),
              15.0 * (float(p.find('Grid/North').text) - 6169650))
    return Point(name, code, coords)

def tangent_from_points(p, q, r):
    dy = (q.y - r.y)
    dx = (q.x - r.x)
    k = dy / dx
    m = p.y - k * p.x
    return Line(k, m)
    
def render(points, tangents, problems):
    proc.size(1024, 576)
    proc.fill(255, 0, 0)
    for p in points:
        proc.rect(p.x-2, p.y-2, 4, 4)
    for k in range(len(points)):
        if tangents[k]:
            p = points[k]
            l = tangents[k]
            if l.k and l.m:
                x0 = p.x - 5
                y0 = l.k * x0 + l.m
                x1 = p.x + 5
                y1 = l.k * x1 + l.m
                proc.line(x0, y0, x1, y1)
    proc.fill(0, 255, 0)
    for problem in problems:
        proc.rect(problem.x-2, problem.y-2, 4, 4)
        x0 = problem.x - 5
        y0 = problem.k * x0 + problem.m
        x1 = problem.x + 5
        y1 = problem.k * x1 + problem.m
        proc.line(x0, y0, x1, y1)
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
    render(points, tangents, problems)
    