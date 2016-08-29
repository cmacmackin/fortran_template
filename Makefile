#  
#  Copyright 2016 Christopher MacMackin <cmacmackin@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  

# The compiler
FC := gfortran

# Flags for debugging or for maximum performance
FCFLAGS = -Ofast -Wall #-fpic

# Include paths
FCFLAGS += -J$(MDIR) -I$(INCDIR) -I/usr/include

# Link-time flags
LDFLAGS := -Ofast

# Directories
SDIR := ./src
MDIR := ./mod

# Extensions of Fortran files, case insensitive
F_EXT := f for fpp f90 f95 f03 f08 f15

# Output
EXEC := a.out
LIB := libfort
PREFIX := $(HOME)/.local
LIBDIR := $(PREFIX)/lib
INCDIR := $(PREFIX)/include
BINDIR := $(PREFIX)/bin

# Temporary work variables
_F_EXT := $(F_EXT) $(shell echo $(F_EXT) | tr a-z A-Z)
null :=
space := $(null) $(null)
EXT_PATTERN_GREP := '.*\.\($(subst $(space),\|,$(_F_EXT))\)'
EXT_PATTERN_SED := 's/([^ ]*)\.($(subst $(space),|,$(_F_EXT)))/\1.o/g;'

# Objects to compile
OBJS := $(shell find $(SDIR) -iregex $(EXT_PATTERN_GREP) | sed -r $(EXT_PATTERN_SED))

# "make" builds all
all: all_objects lib

all_objects: $(OBJS)

exec: $(EXEC)

$(EXEC): $(OBJS)
	$(FC) $(LDFLAGS) $^ -o $@

install_exec: exec
	cp $(EXEC) $(BINDIR)

lib: $(LIB)

$(LIB): $(OBJS)
	$(FC) $(LDFLAGS) -shared $^ -o $@

install_lib: lib
	cp $(LIB) $(LIBDIR)
	cp $(MDIR)/*.mod $(INCDIR)

ifeq ($(MAKECMDGOALS),clean)
else ifeq ($(MAKECMDGOALS),doc)
else
-include $(OBJS:.o=.d)
endif

# General rule for building Fortran files, where $(1) is the file extension
define fortran_rule
%.o: %.$(1) | $(MDIR)
	$$(FC) $$(FCFLAGS) -c $$< -o $$@

%.d: %.$(1)
	./get_deps $$(MDIR) $$< > $$@
endef

# Register compilation rules for each Fortran extension
$(foreach EXT,$(_F_EXT),$(eval $(call fortran_rule,$(EXT))))

$(MDIR):
	@mkdir -p $@

clean:
	@echo Deleting all object, module, and dependency files
	@/bin/rm -rf $(OBJS) ./tmp $(MDIR) $(OBJS:.o=.d) *~ $(SRC)/*~

doc: documentation.md
	ford $<
