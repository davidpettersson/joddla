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


from nose.tools import assert_equal

from joddla.jobxml import loads, _parse_code


SAMPLE_POINT_XML = '''
<JOBFile>
   <Reductions>
        <Point>
            <ID>000000eb</ID>
            <Name>20</Name>
            <Code>2</Code>
            <SurveyMethod>NetworkFix</SurveyMethod>
            <Classification>Normal</Classification>

            <WGS84>
                <Latitude>55.691877153688</Latitude>
                <Longitude>13.239356628868</Longitude>
                <Height>66.77630583795</Height>
            </WGS84>

            <Grid>
                <North>6174287.7118201</North>
                <East>133608.61283017</East>
                <Elevation>30.943859706291</Elevation>
            </Grid>
        </Point>
    </Reductions>
</JOBFile>
'''


def test__parse_point():
    points = loads(SAMPLE_POINT_XML)
    assert_equal(len(points), 1)
    point = points[0]
    assert_equal(point.ident, 235)
    assert_equal(point.name, '20')
    assert_equal(point.code, '')
    assert_equal(point.x, 133608.61283017)
    assert_equal(point.y, 6174287.7118201)
    assert_equal(point.z, 30.943859706291)


def test__parse_code_single_word():
    out = _parse_code('ABC')
    assert out == ''


def test__parse_code_double_word():
    out = _parse_code('ABC DEF')
    assert out == 'DEF'