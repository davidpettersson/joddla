#
# model.py
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


class Point():
    def __init__(self, name, code, coords):
        self.name = name
        self.code = code
        self.coords = coords
        self.x = coords[0]
        self.y = coords[1]

    def __repr__(self):
        return u'Point(%s,%s,(%f,%f))' % (self.name, self.code, self.x, self.y)


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
