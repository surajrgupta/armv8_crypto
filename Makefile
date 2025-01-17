#
#   BSD LICENSE
#
#   Copyright (C) Cavium networks Ltd. 2016.
#
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions
#   are met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in
#       the documentation and/or other materials provided with the
#       distribution.
#     * Neither the name of Cavium networks nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

SRCDIR := ${CURDIR}
OBJDIR := ${CURDIR}/obj
# build flags
CC = aarch64-linux-gnu-gcc
CFLAGS += -O3
CFLAGS += -Wall -static
CFLAGS += -I$(SRCDIR)/asm/include

# library c files
SRCS += $(SRCDIR)/interface.c
# library asm files
SRCS += $(SRCDIR)/asm/aes_core.S
SRCS += $(SRCDIR)/asm/sha1_core.S
SRCS += $(SRCDIR)/asm/sha256_core.S
SRCS += $(SRCDIR)/asm/aes128cbc_sha1_hmac.S
SRCS += $(SRCDIR)/asm/aes128cbc_sha256_hmac.S
SRCS += $(SRCDIR)/asm/sha1_hmac_aes128cbc_dec.S
SRCS += $(SRCDIR)/asm/sha256_hmac_aes128cbc_dec.S

OBJS  := $(SRCS:.S=.o)
OBJS  += $(SRCS:.c=.o)

# runtime generated assembly symbols
all: libarmv8_crypto.a

.PHONY:	clean
clean:
	@rm -rf $(SRCDIR)/asm/assym.s *.a $(OBJDIR)

assym.s: genassym.c
	@$(CC) $(CFLAGS) -O0 -S $< -o - | \
		awk '($$1 == "<genassym>") { print "#define " $$2 "\t" $$3 }' > \
		$(SRCDIR)/asm/$@
$(OBJDIR):
	mkdir $(OBJDIR)

%.o: %.S $(OBJDIR) assym.s
	$(CC) $(CFLAGS) -c $< -o $(OBJDIR)/$(notdir $@)

%.o: %.c $(OBJDIR)
	$(CC) $(CFLAGS) -c $< -o $(OBJDIR)/$(notdir $@)


libarmv8_crypto.a: $(OBJS)
	ar -rcs $@ $(OBJDIR)/*.o
