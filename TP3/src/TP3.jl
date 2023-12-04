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