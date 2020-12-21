# fractal_christmas_tree
Draw Christmas tree fractal that is similar to Barnsley fern fractal. This is done with less than 30 lines of python code. Code readability is slightly lost by making code compact.

Alpi Tolvanen 2020
Licence: MIT or Public Domain

## Code explanation
This fractal is based on modified version of [Barnsley fern](https://en.wikipedia.org/wiki/Barnsley_fern).

### Affine transformations
```python3
data = [([[ 0.1,  0.00],[ 0.00, 0.2]], [0.0, 0.3]),     # trunk
        ([[ 0.1,  0.00],[ 0.00, 0.2]], [0.0, 0.37]),    # trunk
        ([[ 0.87, 0.01],[-0.01, 0.87]], [0.0, 0.8]),    # copy branches
        ([[ 0.30,-0.3], [ 0.70, -0.2]], [0.0, 0.3]),    # left branch
        ([[-0.30, 0.3], [ 0.70, -0.2]], [-0.0, 0.3])]   # right branch
```

Variable `data` contains affine transformations that are in hearth of the fractal. Affine transformations map points of plane into another plane. Affine transormation of a point `r` is `M r + v`, where `M` is matrix, and `v` is vector.


The 5 transformations are:
1. Copy the whole tree to base of a trunk. That is, the trunk is actually just scaled down version of the tree.
2. Similar copy and pasting as in 1. This makes trunk a bit more dense and uniform.
3. Copy layer of branches one step vertically up. Only the lowest branches are actually needed, and all the rest are copied. Branches are also scaled down a bit so that they get smaller the higher they are.
4. Copy left half of a tree to the lowest left branch. This transformation also does some skewing so that sub brances look better.
5. Copy left half of a tree to lowest right branch.

[This online tool](https://www.desmos.com/calculator/avfh60ysiv) was very useful in figuring out the correct transformations.


### Iteration

The original Barnsley fern iteration happends as following:
    1. Start from one point
    2. Choose one transformation by random. Use specified probabilities for each transformation.
    3. Apply that transformation for the point and light up a pixel in this location.
    4. Repeat from 2.

However, this fractal contains a considerable modification compared to original Barnsley fern: Two points are itearated simultaneously instead of one. Transformations 1.-3. are applied identically to these both of the points, but transformations 4. is only applied to first point and 5. is only applied to latter. The latter point is always synchronized with first point so that tree remains symmetric.

The probabilities in step 2. are chosen so that points are somewhat evenly distributen. They were quite easy to fing out by just trying and testing.


```python3
def draw_tree(affines):
    img = np.zeros((h, w, 3), dtype=np.uint32)
    r = [np.array([0.0, 0.0]), np.array([0.0, 0.0])]
    for i in range(w*h*10):
        idx = np.random.choice([0, 1, 2, 3], p=[0.02, 0.02, 0.76, 0.2])
        if idx == 3:
            r[1] = r[0] # Copy left branch to right side
        for j in range(2):
            (mat, vec) = affines[idx+j] if idx == 3 else affines[idx]
            r[j] = mat @ r[j] + vec  # affine transformation
            x, y = int(w * (r[j][0]/3.5 - 0.5)), int(h * (r[j][1]/7.5 + 0.05))
            img[y, x, :] += np.array([1,8,1], dtype=np.uint8)
    return img
```


### Boring stuff
This part contains parts that are not important in algorithmic viewpoint.

```python3
data_numpy = list(map(lambda t: (np.array(t[0]), np.array(t[1])), data))
img = draw_tree(data_numpy)
img[...] = np.sqrt(img / img.max()) * 255
img[:h//17, :] = 0; img[-h//10:, :] = 0
fig = Image.fromarray(img[::-1,:].astype(np.uint8))
x, y = int(h*0.135), int(w*0.634)  # star
ImageDraw.Draw(fig).ellipse((y-8, x-8, y+8, x+8), fill='yellow')
```

* Variable `data_numpy` is just `data` but expressed as numpy arrays. This hack is done to only save few characters.
* Color values are scaled on range 0-255 and square root is used to make them a bit prettier
* The bottom and top part of image is erased. The bottom part is erased because the base trunk is not actually drawn. Istead, the lowest branches are erased to make it appear that three has trunk connected to ground. (On the other hand, the top part is erased because this code contains invalid indexing: negative indicies in python wrap around.)
* Star is drawn on top of tree.

## Running the code
**Rendering of picture takes ages!** Please consider using Numba if you do not want to wait half an hour. This repo contains git branch "numba" which has a version of code that renders the fractal in few secods. (It is not default branch because it has few extra code lines, and it requires Numba to be installed.)
