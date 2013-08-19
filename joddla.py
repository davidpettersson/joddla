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


from sys import argv, stdout
from logging import info, basicConfig, WARN, debug
from multiprocessing import Pool
from time import sleep

from joddla.alg import find_slopes, find_line_segments, formulate_problems, solve_problem
from joddla.model import ArcSegment, LineSegment
from joddla.render import draw_screen
from joddla.jobxml import load
from joddla.dxf import dump


def spinner(k):
    SPINNER = '-\\|/'
    s = '\b%s' % (SPINNER[k % len(SPINNER)])
    stdout.write(s)


def main(filename, render):
    basicConfig(level=WARN)

    if render:
        center = True
        scale = 100.0
    else:
        center = False
        scale = None

    points = load(filename, center, scale)
    print 'Loaded %d points from %s' % (len(points), filename)

    slopes = find_slopes(points)
    print 'Calculated %d slopes' % (len(slopes), )

    line_segments = find_line_segments(points)
    print 'Found %d line segments' % (len(line_segments), )

    problems = formulate_problems(points, slopes)
    print 'Formulated %d problems' % (len(problems), )

    pool = Pool()
    print 'Calculating solutions...  ',
    token = pool.map_async(solve_problem, problems)

    k = 0
    while not token.ready():
        sleep(1.0)
        spinner(k)
        k += 1

    solutions = token.get()
    print '\bdone'

    arc_segments = filter(lambda s: isinstance(s, ArcSegment), solutions)
    line_segments.extend(filter(lambda s: isinstance(s, LineSegment), solutions))

    if render:
        draw_screen(points, slopes, line_segments, arc_segments)
    else:
        dump(filename + '.dxf', points, line_segments, arc_segments)
        print 'Solution consists of %d lines and %d arcs' % (len(line_segments), len(arc_segments))
        print 'Results written to %s' % (filename + '.dxf', )
        raw_input('Press enter to exit...')


if __name__ == '__main__':
    main(argv[1], False)
