#
# model_tests.py
#

from unittest import TestCase
from joddla.model import Point


class PointTest(TestCase):
    def test_constructor_xy(self):
        p = Point('foo', 'bar', [1, 2])
        assert p.name == 'foo'
        assert p.code == 'bar'
        assert p.coords == [1, 2]
        assert p.x == 1
        assert p.y == 2
        assert p.z == 0
        assert p.elevation == 0

    def test_constructor_xyz(self):
        p = Point('foo', 'bar', [1, 2, 3])
        assert p.name == 'foo'
        assert p.code == 'bar'
        assert p.coords == [1, 2, 3]
        assert p.x == 1
        assert p.y == 2
        assert p.z == 3
        assert p.elevation == 3
