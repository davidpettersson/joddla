#
# render.py
#

import pyprocessing as proc

def render(points, tangents, problems, arcs, straights):
    proc.size(1600, 1000)
    proc.background(255, 255, 255)
    proc.smooth()
    for k in range(len(points)):
        if tangents[k]:
            p = points[k]
            l = tangents[k]
            if l.k and l.m:
                x0 = p.x - 5
                y0 = l.k * x0 + l.m
                x1 = p.x + 5
                y1 = l.k * x1 + l.m
                # proc.line(x0, y0, x1, y1)
    if False:
        proc.fill(0, 255, 0)
        for problem in problems:
            proc.rect(problem.x-2, problem.y-2, 4, 4)
            x0 = problem.x - 5
            y0 = problem.k * x0 + problem.m
            x1 = problem.x + 5
            y1 = problem.k * x1 + problem.m
            proc.line(x0, y0, x1, y1)
    # arcs
    proc.ellipseMode(proc.RADIUS)
    proc.noFill()
    for arc in arcs:
        proc.stroke(127, 127, 127, 15)
        proc.ellipse(arc[0], arc[1], arc[2], arc[2])
        proc.stroke(0, 0, 0, 255)
        proc.arc(arc[0], arc[1], arc[2], arc[2], arc[3], arc[4])
    # straights
    proc.stroke(0, 0, 0, 255)
    for straight in straights:
        proc.line(straight[0], straight[1], straight[2], straight[3])
    # Points
    proc.fill(255, 0, 0)
    proc.stroke(0, 0, 0)
    for p in points:
        proc.rect(p.x-2, p.y-2, 4, 4)
    proc.run()
