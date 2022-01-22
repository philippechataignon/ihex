CC=gcc
CFLAGS=-Wall -std=c99 -O2
LDFLAGS=
AR=ar
ARFLAGS=rcs

OBJS = kk_ihex_write.o kk_ihex_read.o bin2ihex.o ihex2bin.o
BINPATH = ./
LIBPATH = ./
BINS = $(BINPATH)bin2ihex $(BINPATH)ihex2bin $(BINPATH)split16bit $(BINPATH)merge16bit
BINS += $(BINPATH)split32bit $(BINPATH)merge32bit
LIB = $(LIBPATH)libkk_ihex.a
TESTFILE = $(LIB)
TESTER = 
#TESTER = valgrind

all: $(BINS) $(LIB)

$(OBJS): kk_ihex.h
$(BINS): | $(BINPATH)
$(LIB): | $(LIBPATH)
bin2ihex.o kk_ihex_write.o: kk_ihex_write.h
ihex2bin.o kk_ihex_read.o: kk_ihex_read.h

$(LIB): kk_ihex_write.o kk_ihex_read.o
	$(AR) $(ARFLAGS) $@ $+

$(BINPATH)bin2ihex: bin2ihex.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $+

$(BINPATH)ihex2bin: ihex2bin.o $(LIB)
	$(CC) $(LDFLAGS) -o $@ $+

$(BINPATH)split16bit: split16bit.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+

$(BINPATH)merge16bit: merge16bit.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+

$(BINPATH)split32bit: split32bit.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+

$(BINPATH)merge32bit: merge32bit.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $+

$(sort $(BINPATH) $(LIBPATH)):
	@mkdir -p $@

.PHONY: all clean distclean test

test: $(BINPATH)bin2ihex $(BINPATH)ihex2bin $(TESTFILE)
	@$(TESTER) $(BINPATH)bin2ihex -v -a 0x80 -i '$(TESTFILE)' | \
	    $(TESTER) $(BINPATH)ihex2bin -A -v | \
	    diff '$(TESTFILE)' -
	@echo Loopback test success!

clean:
	rm -f $(OBJS)

distclean: | clean
	rm -f $(BINS) $(LIB)
	@rmdir $(BINPATH) $(LIBPATH) >/dev/null 2>/dev/null || true

