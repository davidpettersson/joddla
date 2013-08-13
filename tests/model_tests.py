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

from nose.tools import assert_equal

from joddla.model import Point


class PointTest(TestCase):
    def test_constructor_xy(self):
        p = Point(74, 'foo', 'bar', [1, 2])
        assert p.ident == 74
        assert p.name == 'foo'
        assert p.code == 'bar'
        assert p.coords == [1, 2]
        assert p.x == 1
        assert p.y == 2
        assert p.z == 0
        assert p.elevation == 0

    def test_constructor_xyz(self):
        p = Point(19, 'foo', 'bar', [1, 2, 3])
        assert p.ident == 19
        assert p.name == 'foo'
        assert p.code == 'bar'
        assert p.coords == [1, 2, 3]
        assert p.x == 1
        assert p.y == 2
        assert p.z == 3
        assert p.elevation == 3
