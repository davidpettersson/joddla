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


from joddla.model import BoundingBox


RENDER_PROBLEMS = True
RENDER_TANGENTS = True
RENDER_CIRCLES = True

TANGENT_LENGTH = 500
BOX_WIDTH = 16


def draw_screen(points, tangents, problems, arcs, straights):
    import pyprocessing as proc

    bbox = BoundingBox(points)
    proc.size(1600, 1000)
    proc.smooth()
    eye_x = bbox.min_x + bbox.width / 2.0
    eye_y = bbox.min_y + bbox.height / 2.0
    # eye_z = (bbox['height'] / 2.0) / tan(pi * 30.0 / 180.0)
    eye_z = max(bbox.width, bbox.height)
    print eye_x, eye_y, eye_z
    center_x = bbox.min_x + bbox.width / 2.0
    center_y = bbox.min_y + bbox.height / 2.0
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
                x0 = p.x() - TANGENT_LENGTH / 2.0
                y0 = l.k() * (x0 - p.x()) + p.y()
                x1 = p.x() + TANGENT_LENGTH / 2.0
                y1 = l.k() * (x1 - p.x()) + p.y()
                proc.line(x0, y0, x1, y1)
                print x0, y1, x1, y1
    if RENDER_PROBLEMS:
        proc.fill(0, 255, 0)
        for problem in problems:
            proc.rect(problem.c[0] - BOX_WIDTH / 2.0, problem.c[1] - BOX_WIDTH / 2.0, BOX_WIDTH, BOX_WIDTH)
            x0 = problem.c[0] - problem.s.x() * 5.0
            y0 = problem.c[0] - problem.s.y() * 5.0
            x1 = problem.c[0] + problem.s.x() * 5.0
            y1 = problem.c[0] + problem.s.y() * 5.0
            proc.line(x0, y0, x1, y1)

    # arcs
    proc.ellipseMode(proc.RADIUS)
    proc.noFill()
    for arc in arcs:
        if RENDER_CIRCLES:
            proc.stroke(127, 127, 127, 15)
            proc.ellipse(arc.c[0], arc.c[1], arc.r, arc.r)
        proc.stroke(255, 0, 0, 255)
        proc.arc(arc.c[0], arc.c[1], arc.r, arc.r, arc.alfa, arc.beta)

    # straights
    proc.stroke(0, 0, 0, 255)
    for straight in straights:
        proc.line(straight.a.x(), straight.a.y(), straight.b.x(), straight.b.y())

    # Points
    proc.fill(255, 0, 0)
    proc.stroke(0, 0, 0)
    for p in points:
        proc.rect(p.x() - BOX_WIDTH / 2.0, p.y() - BOX_WIDTH / 2.0, BOX_WIDTH, BOX_WIDTH)
    proc.run()
