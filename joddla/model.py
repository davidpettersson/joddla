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


from numpy import array, inf


class Point(object):
    def __init__(self, ident, name, code, coords):
        assert type(array([])) == type(coords)
        assert len(coords) == 3
        self.ident = ident
        self.name = name
        self.code = code
        self.coords = coords

    def x(self):
        return self.coords[0]

    def y(self):
        return self.coords[1]

    def z(self):
        return self.coords[2]

    def elevation(self):
        return self.coords[2]

    def __repr__(self):
        return u'Point(%d,%s,%s,%s)' % (self.ident, self.name, self.code, str(self.coords))


class BoundingBox(object):
    def __init__(self, points):
        self.min_x = self.max_x = points[0].x()
        self.min_y = self.max_y = points[0].y()
        self.min_z = self.max_z = points[0].z()
        for point in points:
            self.min_x = min(self.min_x, point.x())
            self.min_y = min(self.min_y, point.y())
            self.min_z = min(self.min_z, point.z())
            self.max_x = max(self.max_x, point.x())
            self.max_y = max(self.max_y, point.y())
            self.max_z = max(self.max_z, point.z())
        self.width = self.max_x - self.min_x
        self.height = self.max_y - self.min_y
        self.depth = self.max_z - self.min_z

    def __repr__(self):
        return u'BBox(%f,%f,%f,%f)' % (self.min_x, self.min_y, self.max_x, self.max_y)


class Slope(object):
    def __init__(self, vector):
        self.vector = vector

    def x(self):
        return self.vector[0]

    def y(self):
        return self.vector[1]

    def k(self):
        if self.vector[0] != 0:
            return self.vector[1] / self.vector[0]
        else:
            return inf

    def __repr__(self):
        return u'Slope(%f)' % self.k


class LineSegment(object):
    def __init__(self, a, b):
        self.a = a
        self.b = b

    def __repr__(self):
        return u'LineSegment(%s,%s)' % (self.a, self.b)


class ArcSegment(object):
    def __init__(self, center, radius, start_angle, stop_angle):
        self.c = center
        self.r = radius
        self.alfa = start_angle
        self.beta = stop_angle

    def __repr__(self):
        return u'ArcSegment(%s,%s,%f,%f)' % (self.c, self.r, self.alfa, self.beta)


class Problem():
    def __init__(self, c, k, m, a, b, p, q):
        self.c = c
        self.k = k
        self.m = m
        self.a = a
        self.b = b
        self.p = p
        self.q = q

    def __repr__(self):
        return u'Problem(%s,%f,%f,%s,%s,%s,%s)' % (self.c, self.k, self.m, self.a, self.b, self.p, self.q)


### TODO: Code below this line has not been revised yet


class Line():
    def __init__(self, k, m):
        self.k = k
        self.m = m

    def __repr__(self):
        return u'Line(%f,%f)' % (self.k, self.m)


