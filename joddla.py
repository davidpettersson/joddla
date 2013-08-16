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
import sys
from joddla.alg import find_slopes, find_line_segments, formulate_problems, solve_problem
from joddla.model import ArcSegment, LineSegment
from joddla.render import draw_screen
from joddla.jobxml import load
from joddla.dxf import dump


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

    print '--- PROBLEMS'
    problems = formulate_problems(points, slopes)
    pprint(problems)

    print '--- SOLUTIONS'
    solutions = map(solve_problem, problems)
    pprint(solutions)

    arc_segments = filter(lambda s: isinstance(s, ArcSegment), solutions)
    line_segments.extend(filter(lambda s: isinstance(s, LineSegment), solutions))

    if render:
        draw_screen(points, slopes, line_segments, arc_segments)
    else:
        dump(filename + '.dxf', points, line_segments, arc_segments)


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
