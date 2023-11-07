"""
TP2: Compresión de Imágenes
"""

"""
Imports
"""

using FFTW
using Images
using Statistics

# preparamos la imagen con padding modulo 16 y channelview
function prepareImage(path::String)
    input_image = load(path)
    height, width = size(input_image)
    new_height = ((height - 1) ÷ 16 + 1) * 16
    new_width = ((width - 1) ÷ 16 + 1) * 16

    paddedImage = PaddedView(0.0, input_image, (1:new_height, 1:new_width), (1:height, 1:width))
    save("./images/completed_image.bmp", paddedImage)

    return channelview(paddedImage)
end

# a la Imagen A en formato YCbCr se le aplica pooling 4x4 a Cb y Cr
function Pooling(A)
     res = []
     for l in 2:3
         # tomamos Cb o Cr
         C = A[l,:,:]
         height, width = size(C)
         # creamos la nueva matriz 
         new_C = zeros((height/2, width/2))
         # los new indices son para la nueva matriz
         i = 1
         j = 1
         new_i = 1
         new_j = 1
         # corremos la ventana de izquierda a derecha primero y luego baja 4 lugares
         while  i+3<= height
             while  j+3<= width
                 # la ventana es de 4x4 en este caso
                 new_C[new_i,new_j] = Statistics.mean(C[i:i+3:,j:j+3]) 
                 j = j+4
                 new_j = new_j+1
             end
             j = 0
             new_j = 0
             i = i +4
             new_i = new_i+1
         end
         push!(res,new_C)
     end
    
    

    return A[1,:,:],res[1],res[2] # Y, Cb,Cr
end
