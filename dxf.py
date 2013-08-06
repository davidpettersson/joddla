#
# dxf.py
#

from math import degrees

import ezdxf


LAYER_GEOM = 'Geometries'
LAYER_ANNO = 'Annotations'


def write_dxf(filename, points, lines, arcs):
    dwg = ezdxf.new(dxfversion='AC1024') # AutoCAD 2010
    layout = dwg.modelspace()
    for line in lines:
        l = layout.add_line((line[0], line[1]), (line[2], line[3]))
        l.set_dxf_attrib('layer', LAYER_GEOM)
    for arc in arcs:
        if arc[6]:
            a = layout.add_arc((arc[0], arc[1]), arc[2], degrees(arc[3]), degrees(arc[4]))
        else:
            a = layout.add_arc((arc[0], arc[1]), arc[2], degrees(arc[4]), degrees(arc[3]))
        a.set_dxf_attrib('layer', LAYER_GEOM)
    for point in points:
        s = point.name
        if point.code:
            s += ' (%s)' % point.code
        text = layout.add_text(s)
        text.set_pos((point.x, point.y), align='TOP_LEFT')
        text.set_dxf_attrib('height', 0.75)
        text.set_dxf_attrib('layer', LAYER_ANNO)
    dwg.saveas(filename)
