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


from numpy import array
from numpy.linalg import norm

from model import Slope, LineSegment, Problem


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
