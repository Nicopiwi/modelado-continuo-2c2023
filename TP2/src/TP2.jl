"""
TP2: Compresión de Imágenes
"""

"""
Imports
"""

using FFTW
using Images
using Statistics
using .Colors
using StatsBase

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

function _zigzagNext(currentRow, currentCol, currentUp, n)
    row = currentRow
    col = currentCol
    up = currentUp

    # Si estamos moviéndonos en dirección "hacia arriba" de la matriz
    if up
        if col == n || row == 1
            up = false
            if col == n
                row += 1
            else
                col += 1
            end
        else
            row -= 1
            col += 1
        end
    else # Si estamos moviéndonos en dirección "hacia abajo"
        if row == n || col == 1
            up = true
            if row == n
                col += 1
            else
                row += 1
            end
        else
            row += 1
            col -= 1
        end
    end

    return row, col, up

end


function _zigzag(matrix::Matrix)
    """
    Recibe matriz M cuadrada, y retorna los valores de la matriz leídos en zigzag.
    """
    
    n, _ = size(matrix)
    row, col = 1, 1
    up = true
    result = []
    for i = 1:n*n
        push!(result, matrix[row, col])

        row, col, up = _zigzagNext(row, col, up, n)
    end

    return result
end

function _reconstruirMatrizDesdeZigzag(vect, n)
    """
    Recibe matriz vector unidimensional de tamaño n^2, y retorna una matriz
    de n x n con los valores leidos en zigzag.
    """
    
    row, col = 1, 1
    up = true
    M = zeros(n, n)
    for valor in vect
        M[row, col] = valor

        row, col, up = _zigzagNext(row, col, up, n)
    end

    return M
end


function compresion(M::Matrix)
   # c es el vector final de comrpesion
   c = []
   n, m = size(M)
   for i in 1:8:n
       for j in 1:8:m
         # Para cada submatriz de 8x8 aplicamos zigzag
         vals, reps = rle(_zigzag(M[i:i+7, j:j+7]))
         for k in 1:length(vals)
            push!(c, reps[k])
            push!(c, vals[k])
         end
       end
    end
   return c      
end


function decompresion(c::Vector, n, m)
   # c es el vector comprimido de la matriz 
   # Separamos a la comrpesión en los respresentates de cada matriz de 8x8
   subvect = []
   sum = 0
   j = 1

   # Separamos en subvectores para cada submatriz de 8x8
   for i in 1:length(c)
      esRepeticiones = (i % 2 == 1)
      seDebeCortar = (sum + c[i] == 64)
      if esRepeticiones && seDebeCortar
         sum = 0
         push!(subvect, c[j:i+1])
         j = i + 2
      elseif esRepeticiones
         sum = sum + c[i]
      end   
      
   end

   print("SUBVECT", subvect)
   
   submatrices = []
   for vect in subvect
      repeticion::Vector{Integer} = []
      valor::Vector{Integer} = []

      for num in 1:length(vect)
          esRep = num % 2 == 1
          if esRep
              push!(repeticion, vect[num])
          else
              push!(valor, vect[num])
          end
      end
      inverted_rle = inverse_rle(valor, repeticion)
      push!(submatrices, _reconstruirMatrizDesdeZigzag(inverted_rle, 8))
    end
    print("HOLAA", size(subvect))
    print("HOLAA", size(submatrices))

    l = 1
    M = zeros((n,m))
    for i in 1:8:n
       for j in 1:8:m
         M[i:i+7, j:j+7] = submatrices[l]
         l = l+1
       end
    end     

    return M
end

# Parte Guardado

function guardado(
    n::UInt16,
    m::UInt16, 
    quant::Matrix{UInt8},
    compressedY::Vector{Int8},
    compressedCb::Vector{Int8},
    compressedCr::Vector{Int8},
    fileName::String
)
    io = open("$fileName.imc","a")
    write(io,n)
    write(io,m)

    for i in 1:8 
        for j in 1:8
            write(io, quant[i,j])
        end   
    end

    for i in 1:length(compressedY)
        write(io, compressedY[i])
    end

    write(io, "|")

    for i in 1:length(compressedCb)
        write(io, compressedCb[i])
    end

    write(io, "|")

    for i in 1:length(compressedCr)
        write(io, compressedCr[i])
    end

    close(io)
end

function lectura(ruta::String)
     io = open(ruta, "r")

     # Leer los dos primeros UInt16
     n = read(io, UInt16)
     m = read(io, UInt16)
 
     # Leer la matriz de UInt8 de tamaño n x m
     quant = transpose([read(io, UInt8) for _ in 1:8, _ in 1:8])
 
     # Leer el resto del archivo como Int8 en un vector
     compressedY = Int8[]
     compressedCb = Int8[]
     compressedCr = Int8[]

    #  Y_read = false
    #  Cb_read = false

    #  while !eof(io)
    #     val = read(io, String)

    #     Y 
    #  end

    #  for i in 1:n*m
    #     push!(compressedY, read(io, Int8))
    #  end

    #  for i in 1:(n/2)*(m/2)
    #     push!(compressedCb, read(io, Int8))
    #  end

    #  for i in 1:(n/2)*(m/2)
    #     push!(compressedCr, read(io, Int8))
    #  end

    contenido = read(io, String)
    close(io)


    vectores = []

    vectores_crudos = split(contenido, "|")

    # Convertir cada vector crudo en un vector de UInt8
    for vector_crudo in vectores_crudos
        print(vector_crudo)
        if !isempty(vector_crudo)
            vector = [parse(UInt8, elemento) for elemento in split(vector_crudo)]
            push!(vectores, vector)
        end
    end

     compressedY, compressedCb, compressedCr = vectores
 
     return n, m, quant, compressedY, compressedCb, compressedCr
 end