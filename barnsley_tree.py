import numpy as np
from PIL import Image, ImageDraw  # Run 'pip3 install pillow'
from numba import jit  # Run 'pip3 install numba'
from numba.typed import List
w, h = 1280, 1920  # width, height
data = [([[ 0.1,  0.0], [ 0.0,  0.2]],  [ 0.0, 0.3]),   # trunk
        ([[ 0.1,  0.0], [ 0.0,  0.2]],  [ 0.0, 0.37]),  # trunk
        ([[ 0.87, 0.01],[-0.01, 0.87]], [ 0.0, 0.8]),   # copy branches
        ([[ 0.3, -0.3], [ 0.7, -0.2]],  [ 0.0, 0.3]),   # left branch
        ([[-0.3,  0.3], [ 0.7, -0.2]],  [-0.0, 0.3])]   # right branch
@jit(nopython=True)
def draw_tree(affines):
    img = np.zeros((h, w, 3), dtype=np.uint32)
    r = [np.array([0.0, 0.0]), np.array([0.0, 0.0])]
    for _ in range(w*h*10):
        rnd = np.random.rand()
        if rnd < 0.02:
            idx = 0
        elif rnd < 0.04:
            idx = 1
        elif rnd < 0.8:
            idx = 2
        else:
            idx = 3
        if idx == 3:
            r[1] = r[0] # Copy left branch to right side
        for j in range(2):
            (mat, vec) = affines[idx+j] if idx == 3 else affines[idx]
            r[j] = mat @ r[j] + vec  # affine transformation
            x, y = int(w * (r[j][0]/3.5 - 0.5)), int(h * (r[j][1]/7.5 + 0.05))
            img[y, x, :] += np.array([1,8,1], dtype=np.uint8)
    return img
data_numpy = List(map(lambda t: (np.array(t[0]), np.array(t[1])), data))
img = draw_tree(data_numpy)
img[...] = np.sqrt(img / img.max()) * 255
img[:h//17, :] = 0; img[-h//10:, :] = 0
fig = Image.fromarray(img[::-1, :].astype(np.uint8))
x, y = int(h*0.135), int(w*0.634)  # star
ImageDraw.Draw(fig).ellipse((y-8, x-8, y+8, x+8), fill='yellow')
fig.save('tree.png'); fig.save('tree_lossless.webp', lossless=True)
