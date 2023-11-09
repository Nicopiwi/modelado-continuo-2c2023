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
include("./src/TP2")
functionName(...)
```


## Tests Compresion

using Pkg; 
Pkg.activate(".");
Pkg.instantiate();
include("src/TP2.jl");
img = prepareImage("./images/bolitas.bmp")
pooling(img)
matrizTestZigZag = rand(1:10, 3, 3)
