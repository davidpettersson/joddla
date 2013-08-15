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

from pprint import pprint
from math import sqrt, acos, pi
import sys
from joddla.alg import find_slopes, find_line_segments, formulate_problems
from render import draw_screen
from joddla.jobxml import load
from joddla.dxf import dump


def distance(x0, y0, x1, y1):
    return sqrt((y1 - y0) ** 2 + (x1 - x0) ** 2)


def solve(problem):
    print '----solving----'

    best_error = 100000000
    best_x = 0.0
    best_y = 0.0
    best_radius = 0.0

    step_size = 10
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
            x = problem.c[0] + step
            y = problem.k * x + problem.m
        else:
            y = problem.c[1] + step
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
    if render:
        center = True
        scale = 100.0
    else:
        center = False
        scale = None

    print '--- POINTS'
    points = load(filename, center, scale)
    pprint(points)

    print '--- SLOPES'
    slopes = find_slopes(points)
    pprint(slopes)

    print '--- LINE SEGMENTS'
    line_segments = find_line_segments(points)
    pprint(line_segments)

    # get problems that need to be solved
    print '--- PROBLEMS'
    problems = formulate_problems(points, slopes)
    pprint(problems)
    circles = map(solve, problems)
    pprint(circles)

    if render:
        draw_screen(points, slopes, problems, circles, line_segments)
    else:
        dump(filename + '.dxf', points, line_segments, circles)


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
