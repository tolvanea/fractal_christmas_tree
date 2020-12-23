# This is a Julia implementation of the file barnsley_tree.py
# Written because Julia is the author's second favourite language.
#
# author: Santtu Söderholm <santtu.soderholm@hotmail.com>

println("Importing and compiling modules. This might take a while, if Julia was restarted...")

import StatsBase, Colors, Images

const IMAGE_PATH = joinpath(@__DIR__, "kuusipuu.png")

# Width and height of the image in pixels
const IMAGE_WIDTH, IMAGE_HEIGHT = 1280, 1920

# Initial data for constructing the tree
# The short circuit condition is here to prevent a redifinition
# and the subsequent warning form the REPL,
# when this script is ran more than once.
isdefined(Main, :INITIAL_DATA) || const INITIAL_DATA = (
    ([ 0.1  0.0; 0.0 0.2],  [ 0.0, 0.3]),    # trunk
    ([ 0.1  0.0; 0.0 0.2],  [ 0.0, 0.37]),   # trunk
    ([ 0.87 0.01; -0.01 0.87], [ 0.0, 0.8]), # copy branches
    ([ 0.3 -0.3; 0.7 -0.2],  [ 0.0, 0.3]),   # left branch
    ([-0.3  0.3; 0.7 -0.2],  [-0.0, 0.3])    # right branch
)


"""
The function responsible for "drawing" the tree.
Takes the affine transformations as a parameter.
"""
function generate_tree_(affines)
    # Preallocate black image
    image = [0.0 for col ∈ 1:IMAGE_WIDTH, row ∈ 1:IMAGE_HEIGHT ]#fill([0.0, 0.0, 0.0], (IMAGE_WIDTH, IMAGE_HEIGHT))
    rows, cols = size(image)
    # The points of the image under modification, with left and right branches.
    points = [
        [0.0, 0.0], # Left
        [0.0, 0.0], # right
    ]
    # Go over the image and conditionally set its pixels to something other than 0 (black)
    for _ ∈ 1:IMAGE_WIDTH * IMAGE_HEIGHT * 10
        index = StatsBase.sample(
            [1, 2, 3, 4],                               # indices to choose from
            StatsBase.Weights([0.02, 0.02, 0.76, 0.2])  # statistical weights, skewed towards right
        )
        if index == 4
            points[2] = points[1] # Copy left branch to right side
        end
        for j ∈ 1:2
            # Choose affine transformation
            mat, vec = index == 4 ? affines[index+j-1] : affines[index]
            # Apply it to the point pair
            points[j] = mat * points[j] + vec
            # Choose a pixel based on the transformation
            row = ceil(Int32, rows * (points[j][2] / 7.5 + 0.05))
            col = ceil(Int32, cols * (points[j][1] / 3.5 - 0.5))
            # Simulate Python's negative indexing
            col = validindex(col, cols)
            row = validindex(row, rows)
            # Set pixel color (from bottom up, to keep tree upright)
            image[end-row+1,col] = 180/255
        end
    end
    image
end

"""
Removes the tops and bottoms of the image, caused by "negative indexing".
"""
function trim_tree_(image_array)

    rows, cols = size(image_array)

    for col in 1:cols
        for row in rows - div(rows,20):rows
            image_array[row,col] = 0.0
        end
    end
    for col in 1:cols
        for row in 1:div(rows, 16)
            # println(row,col)
            image_array[row,col] = 0.0
        end
    end
    image_array
end

"""
Tha main routine.
"""
function main()
    # Draw tree
    println("Generating image $IMAGE_PATH...")
    @time image_array = generate_tree_(INITIAL_DATA)
    println("Trimming the image...")
    @time image = trim_tree_(image_array)
    println("Transforming image into RGB values...")
    @time image = map(x -> Colors.RGB(0.0,x,0.0), image_array)
    println("Saving image...")
    @time Images.save(IMAGE_PATH, image)
    println("Done.")
end

"""
Converts an index < 1 into a valid positive one,
indexing from the end like in Python.
"""
function validindex(index::Int32, length)
    if index < 1
        length + index
    else
        index
    end
end

# Program start
main()
