Kitsune Example
===============

Small example application using [kitsune-dsu](http://kitsune-dsu.com/).

Application has an array of 160 MB data (20971520 elements, each element contains two
uint32_t values). v2 updates the uint32_t's to two uint64_t values instead.

Compilation
-----------

* Clone and compile [kitsune-core](https://github.com/kitsune-dsu/kitsune-core).

* Compile initial version:
``` sh
KITSUNE_PATH=<path_to_kitsune-core/bin> make kitsune-example.so
```

* Compile v2:
``` sh
KITSUNE_PATH=<path_to_kitsune-core/bin> make kitsune-v2.so
```

* Start initial version:
``` sh
<path_to_kitsune-core/bin>/bin/driver kitsune-example.so
```

* Update:
``` sh
<path_to_kitsune-core/bin>/bin/doupd $(pidof driver) kitsune-v2.so
```

Example output
--------------

``` sh
$ /home/aatos/sources/kitsune-core/bin/bin/driver kitsune-example.so
The process id is (12985).
20971520, 167772160
<doupd in other terminal>
20971520, 335544320
```
