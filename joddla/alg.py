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


from math import sqrt, acos, pi

from numpy import array

from numpy.linalg import norm

from model import Slope, LineSegment, Problem, ArcSegment


def _calc_slope(p, q):
    d = q.coords - p.coords
    return Slope(d)


def find_slopes(points):
    slopes = []
    active = False
    for k in range(len(points)):
        point = points[k]
        if point.code == 'C1':
            slope = _calc_slope(points[k - 1], points[k])
            active = True
        elif point.code == 'C2':
            slope = _calc_slope(points[k], points[k + 1])
            active = False
        else:
            if active:
                slope = _calc_slope(points[k - 1], points[k + 1])
            else:
                slope = None
        slopes.append(slope)
    return slopes


def find_line_segments(points):
    line_segments = []
    active = False
    for k in range(1, len(points)):
        if active:
            pass
        else:
            line_segments.append(LineSegment(points[k - 1], points[k]))
        if points[k].code == 'C1':
            active = True
        elif points[k].code == 'C2':
            active = False
        else:
            pass
    return line_segments


def _formulate_problem(a, b, p, q):
    # Find midpoint
    deltas = b.coords - a.coords
    c = a.coords + deltas / 2.0

    # Get perpendicular slope
    v = array([deltas[1], -deltas[0]])
    v /= norm(v)
    s = Slope(v)
    return Problem(c, s, a, b, p, q)


def formulate_problems(points, slopes):
    problems = []
    for k in range(len(points) - 1):
        if slopes[k] and slopes[k + 1] and points[k].code != 'C2' and points[k + 1] != 'C1':
            problems.append(_formulate_problem(points[k], points[k + 1],
                                               slopes[k], slopes[k + 1]))
    return problems


# TODO: Need to decide suitable threshold
LINE_SNAP_THRESHOLD = 0.95


def _distance(x0, y0, x1, y1):
    return sqrt((y1 - y0) ** 2 + (x1 - x0) ** 2)


def _quadrant_offset(p, x, y):
    if p.x() >= x:
        if p.y() >= y:
            return 0, 1
        else:
            return 2.0 * pi, -1
    else:
        if p.y() >= y:
            return pi, -1
        else:
            return pi, 1


def solve_problem(problem):
    print '--- SOLVING'

    d = _distance(problem.a.x(), problem.a.y(), problem.b.x(), problem.b.y())
    print 'Distance between points:', d

    # TODO: Lots of magic constants
    step_size = d / 1000
    step_extension = d * 100
    step_start = -step_extension
    step_stop = step_extension
    step_distance = step_stop - step_start
    step_count = step_distance / step_size
    steps = [(step_start + step_size * k) for k in range(int(step_count))]

    # TODO: This is an extremely naive numerical search. Replace with an
    #   analytical solution (probably some derivative stuff).

    best_error = 100000000
    best_x = 0.0
    best_y = 0.0
    best_radius = 0.0
    improvements = 0

    for step in steps:
        x = problem.c[0] + problem.s.x() * step
        y = problem.c[1] + problem.s.y() * step
        radius = _distance(problem.a.x(), problem.a.y(), x, y)

        # Calculate tangent for a
        dx = (problem.a.x() - x)
        dy = (problem.a.y() - y)
        a_k = -dx / dy
        error_a = a_k - problem.p.k()

        # Calculate tangent for b
        dx = (problem.b.x() - x)
        dy = (problem.b.y() - y)
        b_k = -dx / dy
        error_b = b_k - problem.q.k()

        # Figure out the error
        error = sqrt(error_a ** 2 + error_b ** 2)

        # Pick the lowest error
        if error < best_error:
            best_error = error
            best_x = x
            best_y = y
            best_radius = radius
            improvements += 1

    print 'Step:', step_size
    print 'Improvements:', improvements
    print 'Error:', best_error
    print 'Radius:', best_radius
    print 'Extension', step_extension

    if (best_radius / step_extension) > LINE_SNAP_THRESHOLD:
        return LineSegment(problem.a, problem.b)

    o, m = _quadrant_offset(problem.a, best_x, best_y)
    angle_a = o + m * acos(abs(problem.a.x() - best_x) / best_radius)

    o, m = _quadrant_offset(problem.b, best_x, best_y)
    angle_b = o + m * acos(abs(problem.b.x() - best_x) / best_radius)

    if angle_a > angle_b:
        angle_a, angle_b = angle_b, angle_a

    dz = problem.b.z() - problem.a.z()
    best_z = problem.a.z() + dz / 2.0

    return ArcSegment(
        array([best_x, best_y, best_z]),
        best_radius,
        angle_a,
        angle_b)
