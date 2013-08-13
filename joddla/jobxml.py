#
# jobxml.py
#
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
#

from xml.etree.ElementTree import fromstring
from joddla.model import Point
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


def load(filename, center=False, scale=None):
    return loads(open(filename, 'rb').read(), center, scale)


def loads(s, center=False, scale=None):
    root = fromstring(s)
    points = [parse_point(point) for point in root.findall('.//Point')]
    bbox = bounding_box(points)
    if center:
        for point in points:
            point.x -= bbox['min_x'] + (bbox['max_x'] - bbox['min_x'])
            point.y -= bbox['min_y'] + (bbox['max_y'] - bbox['min_y'])
    if scale:
        for point in points:
            point.x *= scale
            point.y *= scale
    return points
