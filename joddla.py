#
# joddla.py
#
# Copyright (C) 2013 City of Lund (Lunds kommun)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from pprint import pprint
from math import sqrt, acos, pi
import sys

from render import draw_screen
from joddla.model import Line, Problem
from parse import read_jobxml
from util import distance
from dxf import write_dxf


def tangent_from_points(p, q, r):
    dy = (q.y - r.y)
    dx = (q.x - r.x)
    k = dy / dx
    m = p.y - k * p.x
    return Line(k, m)


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


def solve(problem):
    print '----solving----'

    best_error = 100000000
    best_x = 0.0
    best_y = 0.0
    best_radius = 0.0

    step_size = 0.1
    step_start = -100000.0
    step_stop = 100000.0
    step_distance = step_stop - step_start
    step_count = step_distance / step_size

    steps = [(step_start + step_size * k) for k in range(int(step_count))]
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

        error = sqrt(error_a ** 2 + error_b ** 2)

        if error < best_error:
            best_error = error
            best_x = x
            best_y = y
            best_radius = radius

    angle_a = acos((problem.a.x - best_x) / best_radius)
    angle_b = acos((problem.b.x - best_x) / best_radius)

    switch = False

    if best_y >= problem.a.y:
        angle_a = 2 * pi - angle_a
        switch = True
    if best_y >= problem.b.y:
        angle_b = 2 * pi - angle_b
        switch = True

    return best_x, best_y, best_radius, angle_a, angle_b, best_error, switch


def main(filename, render):
    points = read_jobxml(filename, render)
    pprint(points)
    tangents = []
    active = False
    # find tangents
    for k in range(len(points)):
        point = points[k]
        if point.code == 'C1':
            tangent = tangent_from_points(point, point, points[k - 1])
            active = True
        elif point.code == 'C2':
            tangent = tangent_from_points(point, points[k + 1], point)
            active = False
        else:
            if active:
                tangent = tangent_from_points(point, points[k + 1], points[k - 1])
            else:
                tangent = None
        tangents.append(tangent)
    pprint(tangents)
    lines = []
    active = False
    for k in range(1, len(points)):
        if active:
            pass
        else:
            lines.append((points[k - 1].x, points[k - 1].y, points[k].x, points[k].y))

        if points[k].code == 'C1':
            active = True
        elif points[k].code == 'C2':
            active = False
        else:
            pass
    pprint(lines)
    # get problems that need to be solved
    problems = []
    for k in range(len(points) - 1):
        if tangents[k] and tangents[k + 1] and points[k].code != 'C2' and points[k + 1] != 'C1':
            problems.append(formulate_problem(points[k], points[k + 1],
                                              tangents[k], tangents[k + 1]))
    pprint(problems)
    circles = map(solve, problems)
    pprint(circles)
    if render:
        draw_screen(points, tangents, problems, circles, lines)
    else:
        write_dxf(filename + '.dxf', points, lines, circles)


if __name__ == '__main__':
    if len(sys.argv) != 3:
        print 'usage: joddla COMMAND FILE'
        sys.exit(1)

    filename = sys.argv[2]

    if sys.argv[1] == 'export':
        export = True
    elif sys.argv[1] == 'render':
        export = False
    else:
        print 'Command must be either export or render'
        sys.exit(1)

    main(filename, not export)
