CFLAGS := -std=c99
CFLAGS += -Wall -Wextra
CFLAGS += -Wswitch-default -Wcast-align -Winline
CFLAGS += -Wshadow -Wwrite-strings -Wconversion
CFLAGS += -Wundef -Wunused-result

CFLAGS += -D_POSIX_C_SOURCE=199309L

.PHONY: all

all: kitsune-example.so

kitsune_%-v1.ktt: %.c
	$(KITSUNE_PATH)/bin/ktcc $(CFLAGS) -fPIC -isystem $(KITSUNE_PATH)/include -include data.h \
	 -c $^ -o $(subst .ktt,.o,$@) --doktsavetypes --typesfile-out=$@

kitsune_%-v2.ktt: %.c
	$(KITSUNE_PATH)/bin/ktcc $(CFLAGS) -fPIC -isystem $(KITSUNE_PATH)/include -include data_v2.h \
	 -c $^ -o $(subst .ktt,.o,$@) --doktsavetypes --typesfile-out=$@

kitsune.ktt: kitsune_main-v1.ktt
	$(KITSUNE_PATH)/bin/kttjoin $@ $^

kitsune2.ktt: kitsune_main-v2.ktt
	$(KITSUNE_PATH)/bin/kttjoin $@ $^

dsu.c: kitsune.ktt kitsune2.ktt transformation.xf
	$(KITSUNE_PATH)/bin/xfgen $@ $^

dsu.o: dsu.c
	$(CC) -fPIC -Wno-unused-parameter $(CFLAGS) -isystem $(KITSUNE_PATH)/include $(LDFLAGS) -c $^ -o $@

%.so: kitsune_main-v1.ktt
	$(CC) -shared -o $@ $(subst .ktt,.o,$^) -L$(KITSUNE_PATH)/lib -lkitsune -ldl

%-v2.so: dsu.o kitsune_main-v2.ktt kitsune_main-v1.ktt
	$(CC) -shared -o $@ \
		dsu.o kitsune_main-v2.o \
		-L$(KITSUNE_PATH)/lib -lkitsune -ldl

.PHONY: clean

clean:
	rm -f *.o *.so dsu.c *.ktt
