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

from math import degrees
import ezdxf


LAYER_POINTS = 'Points'
LAYER_LINES_AND_CURVES = 'Lines and Curves'
LAYER_ANNO = 'Annotations'


def dump(filename, points, line_segments, arc_segments):
    dwg = ezdxf.new(dxfversion='AC1024')  # AutoCAD 2010
    layout = dwg.modelspace()
    for line in line_segments:
        l = layout.add_line(
            line.a.coords,
            line.b.coords)
        l.set_dxf_attrib('layer', LAYER_LINES_AND_CURVES)
    for arc in arc_segments:
        a = layout.add_arc(arc.c, arc.r, degrees(arc.alfa), degrees(arc.beta))
        a.set_dxf_attrib('layer', LAYER_LINES_AND_CURVES)
    for point in points:
        v = layout.add_point(point.coords)
        v.set_dxf_attrib('layer', LAYER_POINTS)
        s = point.name
        if point.code:
            s += ' (%s)' % point.code
        text = layout.add_text(s)
        text.set_pos((point.x(), point.y(), point.z()), align='TOP_LEFT')
        text.set_dxf_attrib('height', 0.75)
        text.set_dxf_attrib('layer', LAYER_ANNO)
    dwg.saveas(filename)
