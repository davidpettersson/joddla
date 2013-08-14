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


class Point(object):
    def __init__(self, ident, name, code, coords):
        self.ident = ident
        self.name = name
        self.code = code
        self.coords = coords
        self.x = coords[0]
        self.y = coords[1]
        self.z = self.elevation = coords[2]

    def __repr__(self):
        return u'Point(%d,%s,%s,(%f,%f,%f))' % (self.ident, self.name, self.code, self.x, self.y, self.z)


class BoundingBox(object):
    def __init__(self, points):
        self.min_x = self.max_x = points[0].x
        self.min_y = self.max_y = points[0].y
        self.min_z = self.max_z = points[0].z
        for point in points:
            self.min_x = min(self.min_x, point.x)
            self.min_y = min(self.min_y, point.y)
            self.min_z = min(self.min_z, point.z)
            self.max_x = max(self.max_x, point.x)
            self.max_y = max(self.max_y, point.y)
            self.max_z = max(self.max_z, point.z)
        self.width = self.max_x - self.min_x
        self.height = self.max_y - self.min_y
        self.depth = self.max_z - self.min_z


### TODO: Code below this line has not been revised yet


class Line():
    def __init__(self, k, m):
        self.k = k
        self.m = m

    def __repr__(self):
        return u'Line(%f,%f)' % (self.k, self.m)


class Problem():
    def __init__(self, x, y, k, m, a, b, p, q):
        self.x = x
        self.y = y
        self.k = k
        self.m = m
        self.a = a
        self.b = b
        self.p = p
        self.q = q

    def __repr__(self):
        return u'Problem(%f,%f,%f,%f,%s,%s,%s,%s)' % (self.x, self.y, self.k, self.m, self.a, self.b, self.p, self.q)
