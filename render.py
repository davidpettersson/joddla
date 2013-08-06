#
# render.py
#

import pyprocessing as proc
from math import tan, pi
from pprint import pprint
from util import bounding_box

RENDER_PROBLEMS = True
RENDER_TANGENTS = True
RENDER_CIRCLES = True

TANGENT_LENGTH = 500       
BOX_WIDTH = 16

def render(points, tangents, problems, arcs, straights):
    bbox = bounding_box(points)
    proc.size(1600, 1000)
    proc.smooth()
    eye_x = bbox['min_x'] + bbox['width'] / 2.0
    eye_y = bbox['min_y'] + bbox['height'] / 2.0
    eye_z = (bbox['height'] / 2.0) / tan(pi * 30.0 / 180.0)
    eye_z = max(bbox['width'], bbox['height'])
    print eye_x, eye_y, eye_z
    center_x = bbox['min_x'] + bbox['width'] / 2.0
    center_y = bbox['min_y'] + bbox['height'] / 2.0
    print center_x, center_y
    proc.camera(
        eye_x,
        eye_y,
        eye_z,
        center_x,
        center_y,
        0,
        0,
        1,
        0)
    proc.background(255, 255, 255)
    proc.stroke(127, 127, 127)
    if RENDER_TANGENTS:
        for k in range(len(points)):
            if tangents[k]:
                p = points[k]
                l = tangents[k]
                if l.k and l.m:
                    x0 = p.x - TANGENT_LENGTH / 2.0
                    y0 = l.k * x0 + l.m
                    x1 = p.x + TANGENT_LENGTH / 2.0
                    y1 = l.k * x1 + l.m
                    proc.line(x0, y0, x1, y1)
                    print x0, y1, x1, y1
    if RENDER_PROBLEMS:
        proc.fill(0, 255, 0)
        for problem in problems:
            proc.rect(problem.x-BOX_WIDTH / 2.0, problem.y-BOX_WIDTH/2.0, BOX_WIDTH, BOX_WIDTH)
            x0 = problem.x - 5
            y0 = problem.k * x0 + problem.m
            x1 = problem.x + 5
            y1 = problem.k * x1 + problem.m
            proc.line(x0, y0, x1, y1)
    # arcs
    proc.ellipseMode(proc.RADIUS)
    proc.noFill()
    for arc in arcs:
        if RENDER_CIRCLES:
            proc.stroke(127, 127, 127, 15)
            proc.ellipse(arc[0], arc[1], arc[2], arc[2])
        proc.stroke(255, 0, 0, 255)
        proc.arc(arc[0], arc[1], arc[2], arc[2], arc[3], arc[4])
    # straights
    proc.stroke(0, 0, 0, 255)
    for straight in straights:
        proc.line(straight[0], straight[1], straight[2], straight[3])
    # Points
    proc.fill(255, 0, 0)
    proc.stroke(0, 0, 0)
    for p in points:
        proc.rect(p.x-BOX_WIDTH/2.0, p.y-BOX_WIDTH/2.0, BOX_WIDTH, BOX_WIDTH)
    proc.run()
