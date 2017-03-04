CC ?= gcc
CFLAGS_common ?= -Wall -std=gnu99 -g -DDEBUG -O0
ifeq ($(strip $(PROFILE)),1)
CFLAGS_common += -DCORRECT
endif
ifeq ($(strip $(MP)),1)
CFLAGS_common += -fopenmp -DMP
endif
EXEC = \
	recursive.o \
	iteration.o \
	binary.o \
	byte.o \
	harley.o

GIT_HOOKS := .git/hooks/pre-commit
.PHONY: all
all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

benchmark_correct_rate: $(addprefix correct_test_,$(subst .o,,$(EXEC)))
	
correct_test_%:
	$(CC) $(CFLAGS_common) -D$(shell echo $(subst correct_test_,,$@) | tr a-z A-Z) -o $@ benchmark_correct_rate.c -lm

SRCS_common = main.c

%.o: $(SRCS_common) %.c clz.h
	$(CC) $(CFLAGS_common) -o $@ -D$(shell echo $(subst .o,,$@) | tr a-z A-Z) $(SRCS_common)

run: $(EXEC)
	for method in $(EXEC); do\
		taskset -c 1 ./$$method 67100000 67116384; \
	done

TEST = $(addprefix correct_test_,$(subst .o,,$(EXEC)))

generrcsv: benchmark_correct_rate
	for method in $(TEST);do \
		./$$method;\
		printf "\n";\
	done > result_error_rate.csv

plot: iteration.txt iteration.txt binary.txt byte.txt harley.txt
	gnuplot scripts/runtime.gp

.PHONY: clean
clean:
	$(RM) $(EXEC) correct_test_* *.o *.txt *.png *.csv
