"""
TP2: Compresión de Imágenes
"""

"""
Imports
"""

using FFTW
using Images
using Statistics
using Colors

function prepareImage(path::String)::Matrix{RGB{N0f8}}
    """
    Preparamos la imagen con padding negro para que las dimensiones sean 
    de tamaño múltiplo de 16.
    """
    input_image = load(path)
    height, width = size(input_image)
    new_height = ((height - 1) ÷ 16 + 1) * 16
    new_width = ((width - 1) ÷ 16 + 1) * 16

    paddedImage = PaddedView(0.0, input_image, (1:new_height, 1:new_width), (1:height, 1:width))

    return Matrix(paddedImage)
end

function pooling(rgb_image::Matrix{RGB{N0f8}})
    """
    Recibe: rgb_image imagen en formato RGB de tamaño n x m
    Devuelve: 
    - Matriz Y del formato YCbCr de tamaño n x m, con valores entre -128 y 127
    - Matriz Cb del formato YCbCr aplicando pooling 2x2 de tamaño n/2 x m/2, con valores entre -128 y 127
    - Matriz Cr del formato YCbCr aplicando pooling 2x2 de tamaño n/2 x m/2, con valores entre -128 y 127
    """
    ycbcr_image = YCbCr.(rgb_image)
    channels = channelview(ycbcr_image)
    Y = channels[1,:,:] .- 128
    res = []

    for l in 2:3
        # Tomamos Cb o Cr
        C = channels[l,:,:]
        height, width = size(C)
        # Creamos la nueva matriz
        new_C = zeros(height ÷ 2, width ÷ 2)
        # Los new índices son para la nueva matriz
        new_i = 1
        new_j = 1

        for i in 1:2:height-1
            for j in 1:2:width-1
                new_C[new_i,new_j] = Statistics.mean(C[i:i+1,j:j+1]) - 128
                new_j = new_j + 1
            end
            new_j = 1
            new_i = new_i + 1
        end
        push!(res, new_C)
    end
    
    
    return  Y, res[1], res[2] # Y,Cb,Cr
end

function _reconstructMatrixForInversePooling(M::Matrix)
    n, m = size(M)
    res = zeros(2*n, 2*m) 

    for i in 1:2*(n-1)
        for j in 1:2*(m-1)
            res[i, j] = M[i ÷ 2 + 1, j ÷ 2 + 1] + 128
        end
    end

    return res
end

function inversePooling(Y, Cb, Cr)
    """
    Recibe: 
    - Matriz Y del formato YCbCr de tamaño n x m, con valores entre -128 y 127
    - Matriz Cb del formato YCbCr con pooling 2x2 de tamaño n/2 x m/2, con valores entre -128 y 127
    - Matriz Cr del formato YCbCr con pooling 2x2 de tamaño n/2 x m/2, con valores entre -128 y 127
    Devuelve: Imagen en formato RGB
    """

    imageData = (
        Y .+ 128,
        _reconstructMatrixForInversePooling(Cb),
        _reconstructMatrixForInversePooling(Cr) 
    )

    ycbcr_image = colorview(YCbCr, imageData...)
    rgb_image = RGB.(ycbcr_image)

    return rgb_image
end


function applyTransform(M::Matrix)
"""
Recibe:
    - M matriz de n x m con n, m múltiplos de 16.
    Modifica M calculando la transformada del coseno en cada submatriz de 8x8
"""
    n, m = size(M)

    for i in 1:8:n
        for j in 1:8:m
            dct!(view(M, i:i+7, j:j+7))
        end
    end

end


function applyInverseTransform(M::Matrix)
    """
    Recibe:
        - M matriz de n x m con n, m múltiplos de 16.
        Modifica M calculando la transformada inversa del coseno en cada submatriz de 8x8
    """
    n, m = size(M)

    for i in 1:8:n
        for j in 1:8:m
            idct!(view(M, i:i+7, j:j+7))
        end
    end
    
end

function applyQuantization(M::Matrix, quant::Matrix)
    """
    Recibe:
        - M matriz de n x m con n, m múltiplos de 16.
        - quant matriz de 8x8 de cuantización
        Modifica M dividiendo punto a punto en cada submatriz de 8x8, por los valores de quant y redondeando el cociente
    """
    n, m = size(M)

    for i in 1:8:n
        for j in 1:8:m
            M[i:i+7, j:j+7] = round.(view(M, i:(i+7), j:(j+7)) ./ quant)
        end
    end
end

function applyInverseQuantization(M::Matrix, quant::Matrix)
    """
    Recibe:
        - M matriz de n x m con n, m múltiplos de 16.
        - quant matriz de 8x8 de cuantización
        Modifica M multiplicando punto a punto en cada submatriz de 8x8, por los valores de quant
    """
    n, m = size(M)

    for i in 1:8:n
        for j in 1:8:m
            view(M, i:i+7, j:j+7) .*= quant
        end
    end
end



function zigzag(M::Matrix)
    n, m = size(M)
    vector = []
    i, j = 1, 1
    while i <= n && j <= m
        push!(vector, M[i, j])
        if (i + j) % 2 == 0
            # nos movemos para arriba si la sumade indices es par
            if i > 1
                i -= 1
            else
                j += 1
            end
        else
            # nos movemos para abajo si la sumade indices es impar
            if j > 1
                j -= 1
            else
                i += 1
            end
        end
    end
    return vector
end
