using LinearAlgebra
using SparseArrays


function _construir_matriz_para_metodo_explicito(n, r)
    """
    Recibe

    n: tamaño de la matriz
    r: coeficiente calculado como  dt * alpha / (h^2)
    """
    main_diag = fill(1 - 2r, n)
    off_diag = fill(r, n-1)
    tridiag_matrix = Tridiagonal(off_diag, main_diag, off_diag)

    return tridiag_matrix
end

function metodo_explicito(tf, n, m, alpha)
    """
    Resuelve la ecuación del calor homogénea unidimensional con condiciones de contorno Dirichlet 
    nulas en [0, 1] y condición inicial g(x) = x si x ∉ {0, 1}, g(0) = g(1) = 0

    Recibe

    tf: Tiempo final
    n: Cantidad de pasos en el tiempo
    m: Cantidad de pasos interiores en el espacio
    alpha: Constante de difusividad

    Devuelve
    U: Solución discretizada. U[i, j] representa la solución en el paso i de tiempo, en el paso j del espacio.
    """

    dt = tf / n
    h = 1 / (m + 1)
    r = dt * alpha / (h^2)
    M = _construir_matriz_para_metodo_explicito(m, r)  # aca va un m y en la otra un n
    U = zeros(n, m)

    for i in 1:n
        U[i, :] .= range(h, stop=1-h, step=h)
    end

    for i in 1:n-1
        U[i+1, :] .= *(M, U[i, :])
    end

    return hcat(zeros(n), U, zeros(n))
end


function metodo_implicito(tf, n, m, alpha)
    """

    Resuelve la ecuación del calor homogénea unidimensional con condiciones de contorno Dirichlet 
    nulas en [0, 1] y condición inicial g(x) = x si x ∉ {0, 1}, g(0) = g(1) = 0

    Recibe

    tf: Tiempo final
    n: Cantidad de pasos en el tiempo
    m: Cantidad de pasos interiores en el espacio
    alpha: Constante de difusividad

    Devuelve
    U: Solución discretizada. U[i, j] representa la solución en el paso i de tiempo, en el paso j del espacio.
    """

    dt = tf / n
    h = 1 / (m + 1)
    r = dt * alpha / (h^2)
    M = _construir_matriz_para_metodo_implicito(m, r)
    U = zeros(n, m)
    descM = lu(M)

    for i in 1:n
        U[i, :] .= range(h, stop=1-h, step=h)
    end

    for i in 1:n-1
        U[i+1, :] .= descM \ U[i, :]
    end

    return hcat(zeros(n), U, zeros(n))
end

function _construir_matriz_para_metodo_implicito(n, r)
    """
    Recibe

    n: tamaño de la matriz
    r: coeficiente calculado como  dt * alpha / (h^2)
    """
    main_diag = fill(1 + 2r, n)
    off_diag = fill(-r, n-1)
    tridiag_matrix = spdiagm(-1 => off_diag, 0 => main_diag, 1 => off_diag)

    return tridiag_matrix
end

function _construir_matriz_llena_para_metodo_implicito_2d(n, m, r_x, r_y)
    """
    Recibe

    n: cantidad de pasos espaciales interiores en x
    m: cantidad de pasos espaciales interiores en y
    r_x: coeficiente calculado como  dt * alpha / (h_x^2)
    r_y: coeficiente calculado como  dt * alpha / (h_y^2)
    """

    N = n*m
    beta = 1 + 2*r_x + 2*r_y

    # Matriz diagonal
    main_diag = fill(beta, n)
    off_diag = fill(-r_x, n-1)
    main_diag_matrix = Tridiagonal(off_diag, main_diag, off_diag)

    # Matriz subdiagonal
    main_diag = fill(-r_y, n)
    subdiagonal_matrix = diagm(main_diag)

    main_matrix = zeros(N, N)

    for i in 1:n:N-1
        for j in 1:n:N-1
            if i == j
                main_matrix[i : i+n-1, j : j+n-1] = main_diag_matrix
            elseif abs(i-j) == n
                main_matrix[i : i+n-1, j : j+n-1] = subdiagonal_matrix
            else
                main_matrix[i : i+n-1, j : j+n-1] = zeros(n, n)
            end
        end
    end

    return main_matrix
end

function _construir_matriz_rala_para_metodo_implicito_2d(n, m, r_x, r_y)
    """
    Recibe

    n: cantidad de pasos espaciales interiores en x
    m: cantidad de pasos espaciales interiores en y
    r_x: coeficiente calculado como  dt * alpha / (h_x^2)
    r_y: coeficiente calculado como  dt * alpha / (h_y^2)
    """
    N = n * m
    beta = 1 + 2 * r_x + 2 * r_y

    # Matriz diagonal
    main_diag = fill(beta, n)
    off_diag = fill(-r_x, n - 1)
    main_diag_matrix = spdiagm(-1 => off_diag, 0 => main_diag, 1 => off_diag)

    # Matriz subdiagonal
    main_diag = fill(-r_y, n)
    subdiagonal_matrix = spdiagm(0 => main_diag)

    main_matrix = spzeros(N, N)

    for i in 1:n:N - 1
        for j in 1:n:N - 1
            if i == j
                main_matrix[i:i + n - 1, j:j + n - 1] = main_diag_matrix
            elseif abs(i - j) == n
                main_matrix[i:i + n - 1, j:j + n - 1] = subdiagonal_matrix
            end
        end
    end

    return main_matrix
end

function _inital_heat_2d(n, m)
    M = zeros(n, m)
    M[(n÷3 + 1):2*(n÷3), (m÷3 + 1):2*(m÷3)] = 2*ones(n÷3, m÷3)

    return M
end

function metodo_implicito_2d(tf, steps_space_x, steps_space_y, n, alpha; llena=false, LU=true)
    """
    Recibe

    tf: Tiempo final
    steps_space_x: Cantidad de pasos interiores en la dimension x
    steps_space_y: Cantidad de pasos interiores en la dimension y
    n: Cantidad de pasos en el tiempo
    alpha: Constante de difusividad
    llena = true o false (en caso de falso es Rala)
    LU = true o false (se debe precalcular descomposicion LU)
    """

    dt = tf / n
    h_x = 1 / (steps_space_x+1)
    h_y = 1 / (steps_space_y+1)
    r_x = dt * alpha / (h_x^2)
    r_y = dt * alpha / (h_y^2)

    if llena
        M = _construir_matriz_llena_para_metodo_implicito_2d(steps_space_x, steps_space_y, r_x, r_y)
    else
        M = _construir_matriz_rala_para_metodo_implicito_2d(steps_space_x, steps_space_y, r_x, r_y)
    end
    initial_heat = _inital_heat_2d(steps_space_x, steps_space_y)[:]

    U = zeros(n, steps_space_x * steps_space_y)
    U[1, :] = initial_heat
    
    if LU
        descM = lu(M)
     else
        descM = M
     end   

    for i in 1:n-1
        U[i+1, :] .= descM \ U[i, :]
    end

    U_definitiva = zeros(n, steps_space_x + 2, steps_space_y + 2)

    for i in 1:n
        time_state = reshape(U[i, :], (steps_space_x, steps_space_y))
        U_definitiva[i, 2:steps_space_x+1, 2:steps_space_y+1] .= time_state
    end

    return U_definitiva
end


function _construir_matriz_rala_para_difusion_transporte(n, r, s)
    """
    Recibe

    n: cantidad de pasos espaciales en cada dimension
    r: coeficiente calculado como  dt * alpha / (h ^ 2)
    s: coeficiente calculado como dt * beta / 2 * h
    """
    N = (n + 1) * n

    # Matriz diagonal
    main_diag = fill(1 + 4*r, n + 1)
    off_lower_diag = fill(-r+s, n)
    off_upper_diag = fill(-r-s, n)
    main_diag_matrix = spdiagm(-1 => off_lower_diag, 0 => main_diag, 1 => off_upper_diag)
    main_diag_matrix[1, end] = -r + s
    main_diag_matrix[end, 1] = -r - s


    # Matriz subdiagonal
    main_diag = fill(-r, n + 1)
    subdiagonal_matrix = spdiagm(0 => main_diag)

    main_matrix = spzeros(N, N)

    for i in 1:n+1:N - 1
        for j in 1:n+1:N - 1
            if i == j
                main_matrix[i:i + n, j:j + n] = main_diag_matrix
            elseif abs(i - j) == n + 1
                if (
                    i == 1 && j == n + 2 
                    || i == N - (n + 1) + 1 && j == N - 2 * (n + 1) + 1
                )     
                    main_matrix[i:i + n, j:j + n] = 2*subdiagonal_matrix
                else
                    main_matrix[i:i + n, j:j + n] = subdiagonal_matrix
                end
            end
        end
    end

    return main_matrix
end

function _condicion_inicial_transporte(n, m)
    matriz = zeros(n, m)
    centro_n, centro_m = cld(n, 2), cld(m, 2)
    radio = min(cld(n, 4), cld(m, 4))

    for i in 1:n
        for j in 1:m
            if (i - centro_n)^2 + (j - centro_m)^2 <= radio^2
                matriz[i, j] = 1
            end
        end
    end

    return matriz
end


function metodo_implicito_problema_transporte_2d(tf, steps_space, n, alpha, beta)
    """
    Recibe

    tf: Tiempo final
    steps_space: Cantidad de pasos interiores en cada dimension espacial
    n: Cantidad de pasos en el tiempo
    alpha: Constante de difusividad
    beta: Constante de transporte
    """

    dt = tf / n
    h = 1 / (steps_space + 1)
    r = dt * alpha / (h^2)
    s = beta * dt / (2 * h)

    M = _construir_matriz_rala_para_difusion_transporte(steps_space, r, s)
    initial_heat = _condicion_inicial_transporte(steps_space + 1, steps_space)[:]

    U = zeros(n, (steps_space + 1) * steps_space)
    U[1, :] = initial_heat
    descM = lu(M)  

    for i in 1:n-1
        U[i+1, :] .= descM \ U[i, :]
    end

    U_definitiva = zeros(n, steps_space + 2, steps_space + 2)

    for i in 1:n
        time_state = reshape(U[i, :], (steps_space + 1, steps_space))
        U_definitiva[i, 1:steps_space+1, 1:steps_space] .= time_state

        # Copiamos la primera columna por simetría
        U_definitiva[i, 1:steps_space+1, steps_space+1] = U_definitiva[i, 1:steps_space+1, 1]
    end

    return U_definitiva
end
