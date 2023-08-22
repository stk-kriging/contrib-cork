# Complex rational kernel-based interpolation

## What is this?

This directory contains some code & data associated with the paper:

Julien Bect (‡), Niklas Georg (†,§), Ulrich Römer (†), Sebastian Schöps (§),  
__Rational kernel-based interpolation for complex-valued frequency response functions__,  
[arXiv:2307.13484](https://arxiv.org/abs/2307.13484)

‡ [Laboratoire des signaux et systèmes](https://l2s.centralesupelec.fr/),
CentraleSupélec, Univ. Paris-Sud, CNRS, Université Paris-Saclay, Paris, France

† [Institut für Dynamik und Schwingungen](https://www.tu-braunschweig.de/ids),
Technische Universität Braunschweig, Braunschweig, Germany

§ [Computational Electromagnetics Group](https://www.cem.tu-darmstadt.de/),
Technische Universität Darmstadt, Darmstadt, Germany

## How to use it?

This software should run with any reasonably recent version of Matlab.

FIXME: Be more specific.  Make it work on Octave too.

Start Matlab from the root of the project: the initialization script
([`startup.m`](./startup.m)) will automatically start, download the
dependencies and then set the path.
(If Matlab is already started, you can run `startup.m` manually.)

Then have a look at the `script` directory, which contains all the
scripts needed to reproduce the results of the article.

## Directory layout

The code is organized as follows:
 * [`BenchmarkFunctions`](./BenchmarkFunctions): test cases
 * [`CplxGPR`](./CplxGPR): main functions implementing the proposed method
 * [`dependencies`](./dependencies): helper function for dependencies
 * [`scripts`](./scripts): scripts to reproduce the results
 * [`utils`](./utils): various helper functions, wrapper for other methods, etc.

## Dependencies

This software has three dependencies:
[Chebfun](https://www.chebfun.org/),
[STK](https://stk-kriging.github.io),
and [VFIT3](https://www.sintef.no/projectweb/vectorfitting/).

Only STK is actually needed to use the proposed method.  The other two
(Chebfun, VFIT3) provide the state-of-the-art methods AAA and vector
fitting, used in the benchmarking scripts.

The startup script will automatically download, on its first run, a
suitable version of each dependency.  For Chebfun and STK, this is
done by cloning the git repository (therefore `git` is needed).  For
VFIT3, the downloaded file is checked for correctness using its SHA1
checksum (on Linux/Mac, `sha1sum` is needed for that).

If for some reason the startup script does not work for you, you can
alternatively download manually the source code for each of the
dependencies and unpack inside the `dependencies` directory with a
suitable directory name (cf. [`startup.m`](./startup.m)).
 * Chebfun: https://github.com/chebfun/chebfun/archive/refs/heads/master.zip
 * STK: https://github.com/n-georg/stk/archive/refs/heads/lm-param.zip
 * VFIT3: https://www.sintef.no/globalassets/project/vectfit/vfit3.zip

## Authors

Most of the code for this research has been written by Niklas Georg,
with occasional contributions by Julien Bect.

The file [barylag.m](./utils/barylag.m) has been written by Greg von
Winckel.

## Acknowledgments

The work of Niklas Georg and Ulrich Römer was funded by the [Deutsche
Forschungsgemeinschaft](https://www.dfg.de/) (DFG, German Research
Foundation) – RO4937/1-1.

The work of Niklas Georg was also supported by the Graduate School CE
within the [Centre for Computational Engineering at Technische
Universität Darmstadt](https://www.ce.tu-darmstadt.de/).

We thank Christopher Blech, Harikrishnan Sreekumar and Sabine Langer for suggesting acoutstic benchmarks and for providing the implementation of the finite element solver used to compute the vibroacoustics data set.

## Copyright & license

Copyright 2023 TU Braunschweig & CentraleSupélec

Copyright 2004 Greg von Winckel

These computer programs are free software: you can redistribute them
and/or modify them under the terms of the GNU General Public License
as published by the Free Software Foundation, either version 3 of the
license, or (at your option) any later version.

They are distributed in the hope that they will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the license for more details.

You should have received a copy of the license along with the software
(see [COPYING.md](./COPYING.md)).  If not, see <http://www.gnu.org/licenses/>.
