Fortran Project
================

This is a skeleton of a Fortran project. It contains a Makefile
capable of automatically handling dependencies (with the help of the
`get_deps` script). The first 27 lines of the Makefile are the ones
which you will be most likely to need to edit. Depending on whether
you are building a library or an executable, you may want to modify
the `install_lib` and `install_exec` rules as well.


##License

This software is licenses under the GNU General Public License (GPL)
v3.0 or later, which is provided in the file `LICENSE`. It is
acceptable to me for them to be used and distributed with software
under a different license, so long as it has been deemed free by the
[Free Software Foundation](https://www.gnu.org/licenses/license-list.html).
If you do this, please indicate that the Makefile and/or `get_deps`
program are covered by the GPL.

This README, the contents of `doc.md`, and the program stub in
`src/program.f90` are available under the terms of the
[CC0 license](https://creativecommons.org/choose/zero/).


##Acknowledgements

The mechanism for dependency resolution in the Makefile is based off
of that described by Peter Miller in his paper
[Recursive Make Considered Harmful](http://aegis.sourceforge.net/auug97.pdf).
