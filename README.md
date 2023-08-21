# Complex rational kernel-based interpolation

## What is this?

This directory contains some code & data associated with the paper:

Julien Bect, Niklas Georg, Ulrich Römer, Sebastian Schöps  
__Rational kernel-based interpolation for complex-valued frequency response functions__  
[arXiv:2307.13484](https://arxiv.org/abs/2307.13484)

## How to use it?

Start Matlab from the root of the project: the initialization script
([`startup.m`](./startup.m)) will automatically download the
dependencies and then set the path.

Then have a look at the `script` directory, which contains all the
scripts needed to reproduce the results of the article.

## Directory layout

The code is organized as follows:
 * [`BenchmarkFunctions`](./BenchmarkFunctions): test cases
 * [`CplxGPR`](./CplxGPR): main functions implementing the proposed method
 * [`requirements`](./requirements): helper function for dependencies
 * [`scripts`](./scripts): scripts to reproduce the results
 * [`utils`](./utils): various helper functions, wrapper for other methods, etc.

## Dependencies

This repository makes use of three dependencies:
[Chebfun](https://www.chebfun.org/),
[STK](https://stk-kriging.github.io),
and [VFIT3](https://www.sintef.no/projectweb/vectorfitting/).

The startup script will automatically download a suitable version of
each dependency.  For Chebfun and STK, this is done by cloning the git
repository, therefore git is needed.

If git is not installed on your machine, or if for some reason the
startup script does not work for you, you can alternatively download
manually the source code for each of the dependencies and unpack
inside the `requirements` directory with a suitable directory name
(cf. [`startup.m`](./startup.m)).
 * Chebfun: https://github.com/chebfun/chebfun/archive/refs/heads/master.zip
 * STK: https://github.com/n-georg/stk/archive/refs/heads/lm-param.zip
 * VFIT3: https://www.sintef.no/globalassets/project/vectfit/vfit3.zip

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
