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


from xml.etree.ElementTree import fromstring

from numpy import array

from joddla.model import Point, BoundingBox


def _parse_code(c):
    parts = c.split()
    if len(parts) == 1:
        return ''
    else:
        return parts[1]


def _parse_point(p):
    ident = int(p.find('ID').text, 16)
    name = p.find('Name').text
    code = _parse_code(p.find('Code').text)
    coords = (float(p.find('Grid/East').text),
              float(p.find('Grid/North').text),
              float(p.find('Grid/Elevation').text))
    return Point(ident, name, code, array(coords))


def load(filename, center=False, scale=None):
    return loads(open(filename, 'rb').read(), center, scale)


def loads(s, center=False, scale=None):
    root = fromstring(s)
    points = [_parse_point(point) for point in root.findall('.//Point')]
    bbox = BoundingBox(points)
    if center:
        for point in points:
            point.coords[0] = point.x() - bbox.min_x + bbox.width
            point.coords[1] = point.y() - bbox.min_y + bbox.height
            point.coords[2] = point.z() - bbox.min_z + bbox.depth
    if scale:
        for point in points:
            point.coords *= scale
    return points
