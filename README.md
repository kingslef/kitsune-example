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
The process id is (17032).
Initializing 20971520 elements, each 8 bytes
Initialized
Calculating checksum
Data checksum: 45037069120309576
0
1
2
<doupd in other terminal>
Updating, 20971520 elements, each 16 bytes
Calculating checksum
Data checksum: 45037069120309576
3
4
5
```
