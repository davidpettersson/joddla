#
# util.py
#
# Copyright (C) 2013 City of Lund (Lunds kommun)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from pprint import pprint
from math import sqrt


def bounding_box(points):
    bbox = {
        'min_x': 1e10,
        'max_x': 0.0,
        'min_y': 1e10,
        'max_y': 0.0,
    }
    for point in points:
        bbox['min_x'] = min(bbox['min_x'], point.x)
        bbox['min_y'] = min(bbox['min_y'], point.y)
        bbox['max_x'] = max(bbox['max_x'], point.x)
        bbox['max_y'] = max(bbox['max_y'], point.y)
    bbox['width'] = bbox['max_x'] - bbox['min_x']
    bbox['height'] = bbox['max_y'] - bbox['min_y']
    print 'Bounding box:'
    pprint(bbox)
    return bbox


def distance(x0, y0, x1, y1):
    return sqrt((y1 - y0) ** 2 + (x1 - x0) ** 2)