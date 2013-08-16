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


from math import sin, radians

from numpy.linalg import norm

from joddla.model import BoundingBox


VIEW_WIDTH = 1024
VIEW_HEIGHT = 640

RENDER_SLOPES = False
RENDER_CIRCLES = False

SLOPE_LENGTH = 1000
BOX_WIDTH = 16


def draw_screen(points, slopes, line_segments, arc_segments):
    # Setup processing
    import pyprocessing as proc

    proc.size(VIEW_WIDTH, VIEW_HEIGHT)
    proc.smooth()
    proc.background(255, 255, 255)
    proc.ellipseMode(proc.RADIUS)

    # Prepare camera
    bbox = BoundingBox(points)
    eye_x = bbox.min_x + bbox.width / 2.0
    eye_y = bbox.min_y + bbox.height / 2.0
    eye_z = (1.5 * max(bbox.width, bbox.height) / 2.0) / sin(radians(50))
    center_x = bbox.min_x + bbox.width / 2.0
    center_y = bbox.min_y + bbox.height / 2.0
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

    if RENDER_CIRCLES:
        proc.noFill()
        proc.stroke(232, 232, 232)
        for arc in arc_segments:
            proc.ellipse(arc.c[0], arc.c[1], arc.r, arc.r)

    if RENDER_SLOPES:
        proc.stroke(127, 127, 127)
        for k in range(len(points)):
            if slopes[k]:
                p = points[k]
                s = slopes[k].vector / norm(slopes[k].vector)  # normalize
                x0 = p.x() - s[0] * SLOPE_LENGTH
                y0 = p.y() - s[1] * SLOPE_LENGTH
                x1 = p.x() + s[0] * SLOPE_LENGTH
                y1 = p.y() + s[1] * SLOPE_LENGTH
                proc.line(x0, y0, x1, y1)

    # line_segments
    proc.stroke(0, 0, 0, 255)
    for line in line_segments:
        proc.line(line.a.x(), line.a.y(), line.b.x(), line.b.y())

    # arc_segments
    proc.noFill()
    proc.stroke(255, 0, 0, 255)
    for arc in arc_segments:
        proc.arc(arc.c[0], arc.c[1], arc.r, arc.r, arc.alfa, arc.beta)

    # Points
    proc.fill(255, 0, 0)
    proc.stroke(0, 0, 0)
    for p in points:
        proc.rect(p.x() - BOX_WIDTH / 2.0, p.y() - BOX_WIDTH / 2.0, BOX_WIDTH, BOX_WIDTH)

    # Execute! :-)
    proc.run()
