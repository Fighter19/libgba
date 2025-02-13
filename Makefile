#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
ifeq ($(strip $(DEVKITARM)),)
$(error "Please set DEVKITARM in your environment. export DEVKITARM=<path to>devkitARM)
endif
ifeq ($(strip $(DEVKITPRO)),)
$(error "Please set DEVKITPRO in your environment. export DEVKITPRO=<path to>devkitPro)
endif
include $(DEVKITARM)/gba_rules

BUILD		:=	build
SOURCES		:=	src src/BoyScout src/disc_io
INCLUDES	:=	include build
DATA		:=	data


export LIBGBA_MAJOR	:= 0
export LIBGBA_MINOR	:= 5
export LIBGBA_PATCH	:= 4

VERSION	:=	$(LIBGBA_MAJOR).$(LIBGBA_MINOR).$(LIBGBA_PATCH)

ARCH	:=	-march=armv4t -mtune=arm7tdmi -mthumb

#---------------------------------------------------------------------------------
# options for code generation
#---------------------------------------------------------------------------------
CFLAGS	:=	-g -O3 -Wall -Wno-switch -Wno-multichar $(ARCH) $(INCLUDE)
ASFLAGS	:=	-g -Wa,--warn $(ARCH)

#---------------------------------------------------------------------------------
ifneq ($(BUILD),$(notdir $(CURDIR)))

export TARGET	:=	$(CURDIR)/lib/libgba.a

export VPATH	:=	$(foreach dir,$(DATA),$(CURDIR)/$(dir)) $(foreach dir,$(SOURCES),$(CURDIR)/$(dir))

CFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
SFILES		:=	$(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))
BINFILES	:=	$(foreach dir,$(DATA),$(notdir $(wildcard $(dir)/*.*)))

export OFILES_BIN	:=	$(addsuffix .o,$(BINFILES))

export OFILES_SRC	:=	$(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)

export OFILES	:=	$(OFILES_BIN) $(OFILES_SRC)

export HFILES	:=	$(addsuffix .h,$(subst .,_,$(BINFILES)))

export INCLUDE	:=	$(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir))
export DEPSDIR	:=	$(CURDIR)/build

.PHONY: $(BUILD) clean docs

$(BUILD):
	@[ -d lib ] || mkdir -p lib
	@[ -d $@ ] || mkdir -p $@
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile

docs:
	doxygen libgba.dox

clean:
	@echo clean ...
	@rm -fr $(BUILD) *.tar.bz2

install: $(BUILD)
	mkdir -p $(DESTDIR)$(DEVKITPRO)/libgba
	cp -rv include lib libgba_license.txt $(DESTDIR)$(DEVKITPRO)/libgba

#---------------------------------------------------------------------------------
else

DEPENDS	:=	$(OFILES:.o=.d)

#---------------------------------------------------------------------------------
$(TARGET): $(OFILES)

$(OFILES_SRC)	: $(HFILES)

#---------------------------------------------------------------------------------
%_fnt.h %.fnt.o	:	%.fnt
	$(SILENTMSG) $(notdir $<)
	$(SILENTCMD) $(bin2o)

-include $(DEPENDS)

endif
#---------------------------------------------------------------------------------
