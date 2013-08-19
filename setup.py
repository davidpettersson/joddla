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

from distutils.core import setup
from distutils.sysconfig import get_python_lib
from os.path import join

import py2exe

data_files = [
    ('ezdxf\\templates', [join(get_python_lib(), 'ezdxf\\templates\\AC1024.dxf')])
]

setup(console=['joddla.py'],
      options={
          'py2exe': {
              'optimize': 2,
              'skip_archive': True
          }
      },
      data_files=data_files,
      requires=['nose', 'numpy', 'ezdxf', 'pyprocessing'])
