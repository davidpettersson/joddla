#
# model.py
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
