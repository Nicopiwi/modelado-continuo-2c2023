using LinearAlgebra
using SparseArrays
using BenchmarkTools

#TODO: Crear Notebook utilizando estas funciones

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

function metodo_explicito(tf, h, dt, alpha)
    """
    Recibe

    tf: Tiempo final
    h: Paso en el espacio
    dt: Paso en el tiempo
    alpha: Constante de difusividad
    """

    r = dt * alpha / (h^2)
    n = Int(tf / dt)
    m = Int((1 - 2h) / h) + 1
    M = _construir_matriz_para_metodo_explicito(m, r)
    U = zeros(n, m)

    for i in 1:n
        U[i, :] .= range(h, stop=1-h, step=h)
    end

    for i in 1:n-1
        U[i+1, :] .= *(M, U[i, :])
    end

    return hcat(zeros(n), U, zeros(n))
end


function metodo_implicito(tf, h, dt, alpha)
    """
    Recibe

    tf: Tiempo final
    h: Paso en el espacio
    dt: Paso en el tiempo
    alpha: Constante de difusividad
    """

    r = dt * alpha / (h^2)
    n = Int(tf / dt)
    m = Int((1 - 2h) / h) + 1
    M = _construir_matriz_para_metodo_implicito(m, r)
    U = zeros(n, m)

    for i in 1:n
        U[i, :] .= range(h, stop=1-h, step=h)
    end

    for i in 1:n-1
        U[i+1, :] .= *(M, U[i, :])
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
    tridiag_matrix = Tridiagonal(off_diag, main_diag, off_diag)

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

#Preguntar Igna como corregir N y M
function _inital_heat_2d(n, m)
    M = zeros(n, m)
    M[(n÷3 + 1):2*(n÷3), (m÷3 + 1):2*(m÷3)] = 2*ones(n÷3, m÷3)

    return M
end

#Cual es la g(x)?
function metodo_implicito_2d(tf, h_x, h_y, dt, alpha)
    """
    Recibe

    tf: Tiempo final
    h_x: Paso en la dimension x
    h_y: Paso en la dimension y
    dt: Paso en el tiempo
    alpha: Constante de difusividad
    """

    r_x = dt * alpha / (h_x^2)
    r_y = dt * alpha / (h_y^2)
    n = Int(tf ÷ dt)
    m_x = Int((1 - 2*h_x) ÷ h_x) + 1
    m_y = Int((1 - 2*h_y) ÷ h_y) + 1
    M = _construir_matriz_llena_para_metodo_implicito_2d(m_x, m_y, r_x, r_y)
    initial_heat = reshape(_inital_heat_2d(m_x, m_y), :)

    U = zeros(n, m_x * m_y)
    U[1, :] = initial_heat
    descM = lu(M)

    for i in 1:n-1
        U[i+1, :] .= descM \ U[i, :]
    end

    U_definitiva = zeros(n, m_x + 2, m_y + 2)

    for i in 1:n
        #Preguntar a Igna
        time_state = reshape(U[i, :], (m_x, m_y))
        U_definitiva[i, 2:m_x+1, 2:m_y+1] .= time_state
    end

    return U_definitiva
end

#----------------------------------------------------
function _construir_matriz_para_metodo_implicito_2d_v2(n, m, r_x, r_y, llena)
    """
    Recibe

    n: cantidad de pasos espaciales interiores en x
    m: cantidad de pasos espaciales interiores en y
    r_x: coeficiente calculado como  dt * alpha / (h_x^2)
    r_y: coeficiente calculado como  dt * alpha / (h_y^2)
    metodo = 'llena', 'rala'
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
    if llena
        return main_matrix
    else
        return sparse(main_matrix)   
    end     
end

#Preguntar Igna como corregir N y M
function _inital_heat_2d(n, m)
    M = zeros(n, m)
    M[(n÷3 + 1):2*(n÷3), (m÷3 + 1):2*(m÷3)] = 2*ones(n÷3, m÷3)

    return M
end

#Cual es la g(x)?
function metodo_implicito_2d_v2(tf, h_x, h_y, dt, alpha, llena,Lu)
    """
    Recibe

    tf: Tiempo final
    h_x: Paso en la dimension x
    h_y: Paso en la dimension y
    dt: Paso en el tiempo
    alpha: Constante de difusividad
    llena = True o False (en caso de falso es Rala)
    Lu = true o false
    """

    r_x = dt * alpha / (h_x^2)
    r_y = dt * alpha / (h_y^2)
    n = Int(tf ÷ dt)
    m_x = Int((1 - 2*h_x) ÷ h_x) + 1
    m_y = Int((1 - 2*h_y) ÷ h_y) + 1
    M = _construir_matriz_para_metodo_implicito_2d_v2(m_x, m_y, r_x, r_y,llena)
    initial_heat = reshape(_inital_heat_2d(m_x, m_y), :)

    U = zeros(n, m_x * m_y)
    U[1, :] = initial_heat
    # decide si calcular LU o no
    if Lu
       descM = lu(M)
    else
       descM = M
    end      

    for i in 1:n-1
        U[i+1, :] .= descM \ U[i, :]
    end

    U_definitiva = zeros(n, m_x + 2, m_y + 2)

    for i in 1:n
        #Preguntar a Igna
        time_state = reshape(U[i, :], (m_x, m_y))
        U_definitiva[i, 2:m_x+1, 2:m_y+1] .= time_state
    end

    return U_definitiva
end
