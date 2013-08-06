#
# util.py
#

from pprint import pprint

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
    return sqrt((y1-y0)**2 + (x1-x0)**2)