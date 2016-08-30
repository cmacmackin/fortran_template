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

# Directories
SDIR := ./src
MDIR := ./mod

# Output
EXEC := a.out
LIB := libfort
PREFIX := $(HOME)/.local
LIBDIR := $(PREFIX)/lib
INCDIR := $(PREFIX)/include
BINDIR := $(PREFIX)/bin

# The compiler
FC := gfortran

# Flags for debugging or for maximum performance
FCFLAGS := -Ofast -Wall #-fpic

# Include paths internal to project
PROJECT_INCDIRS :=

# A regular expression for names of modules provided by external libraries
# and which won't be contained in the module directory of this codebase
EXTERNAL_MODS := ^iso_(fortran_env|c_binding)|ieee_(exceptions|arithmetic|features)|openacc|omp_lib(_kinds)?|mpi$$

# Include paths
FCFLAGS += -J$(MDIR) $(PROJECT_INCDIR:%=-I%) -I$(INCDIR) -I/usr/include

# Link-time flags
LDFLAGS := -Ofast -L$(LIBDIR)

# Extensions of Fortran files, case insensitive
F_EXT := f for fpp f90 f95 f03 f08 f15

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
	$(FC) $^ $(LDFLAGS) -o $@

install_exec: exec
	cp $(EXEC) $(BINDIR)

lib: $(LIB)

$(LIB): $(OBJS)
	$(FC) $^ $(LDFLAGS) -shared -o $@

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

%.d: %.$(1) get_deps
	./get_deps $$< \$$$$\(MDIR\) "$$(EXTERNAL_MODS)" $$(PROJECT_INCDIRS) > $$@
endef

# Register compilation rules for each Fortran extension
$(foreach EXT,$(_F_EXT),$(eval $(call fortran_rule,$(EXT))))

$(MDIR):
	@mkdir -p $@

.PHONEY: clean clean_obj clean_mod clean_backups doc

clean: clean_obj clean_mod clean_deps clean_backups

clean_obj:
	@echo Deleting all object files
	@/bin/rm -rf $(OBJS)

clean_mod:
	@echo Deleting all module files
	@/bin/rm -rf $(MDIR)

clean_deps:
	@echo Deleting all dependency files
	@/bin/rm -rf $(OBJS:.o=.d)

clean_exec:
	@echo Deleting executable file
	@/bin/rm -rf $(EXEC)

clean_backups:
	@echo Deleting emacs backup files
	@/bin/rm -rf $(shell find '.' -name '*~') $(shell find '.' -name '\#*\#')

doc: documentation.md
	ford $<
