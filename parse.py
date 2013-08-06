#
# parse.py
#

from xml.etree.ElementTree import parse
from model import Point
from util import bounding_box


def parse_code(c):
    parts = c.split()
    if len(parts) == 1:
        return ''
    else:
        return parts[1]


def parse_point(p):
    name = p.find('Name').text
    code = parse_code(p.find('Code').text)
    coords = (float(p.find('Grid/East').text),
              float(p.find('Grid/North').text))
    return Point(name, code, coords)


def read_jobxml(filename, adjust=False):
    tree = parse(filename)
    root = tree.getroot()
    points = [parse_point(point) for point in root.findall('.//Point')]
    bbox = bounding_box(points)
    if adjust:
        for point in points:
            point.x -= bbox['min_x']
            point.y -= bbox['min_y']
            point.x *= 100.0
            point.y *= 100.0
    return points