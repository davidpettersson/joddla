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


from unittest import TestCase

from nose.tools import assert_equal, assert_raises
from numpy import array

from joddla.model import Point, BoundingBox


class PointTest(TestCase):
    def test_constructor(self):
        p = Point(74, 'foo', 'bar', array([1, 2, 3]))
        assert p.ident == 74
        assert p.name == 'foo'
        assert p.code == 'bar'
        assert p.coords.all() == array([1, 2, 3]).all()
        assert p.x == 1
        assert p.y == 2
        assert p.z == 3
        assert p.elevation == 3

    def test_constructor_too_few_coords(self):
        with assert_raises(Exception):
            Point(74, 'foo', 'bar', array([1, 2]))


class BoundingBoxTest(TestCase):
    def test_no_points(self):
        with assert_raises(Exception):
            BoundingBox([])

    def test_single_point(self):
        bb = BoundingBox([Point(1, 'a', 'b', array([1, 2, 3]))])
        assert_equal(bb.min_x, 1)
        assert_equal(bb.min_y, 2)
        assert_equal(bb.min_z, 3)
        assert_equal(bb.max_x, 1)
        assert_equal(bb.max_y, 2)
        assert_equal(bb.max_z, 3)

    def test_two_points(self):
        bb = BoundingBox([
            Point(1, 'a', 'b', array([1, 2, 3])),
            Point(1, 'a', 'b', array([-1, -2, -3]))
        ])
        assert_equal(bb.min_x, -1)
        assert_equal(bb.min_y, -2)
        assert_equal(bb.min_z, -3)
        assert_equal(bb.max_x, 1)
        assert_equal(bb.max_y, 2)
        assert_equal(bb.max_z, 3)
