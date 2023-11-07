"""
TP2: Compresión de Imágenes
"""

"""
Imports
"""

using FFTW
using Images

function prepareImage(path)
    input_image = load(path)
    height, width = size(input_image)
    new_height = ((height - 1) ÷ 16 + 1) * 16
    new_width = ((width - 1) ÷ 16 + 1) * 16

    paddedImage = PaddedView(0.0, input_image, (1:new_height, 1:new_width), (1:height, 1:width))
    save("./images/completed_image.bmp", paddedImage)
end
