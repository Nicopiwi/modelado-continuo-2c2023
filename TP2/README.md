## Activar entorno

```
using Pkg
Pkg.activate(".")
```

## Instalar dependencias

```
using Pkg
Pkg.instantiate()

```

## Correr funciones específicas

```
include("./src/TP2.jl")
functionName(...)
```

En el archivo ´src/tests.jl´ se encuentra un notebook de Pluto mostrando la utilización
de las funciones pedidas para codificar/decodificar las imágenes