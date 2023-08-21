# Benchmark Functions
For details on each of the different benchmarks functions, please refer to our article cited in the main README file. Here, we only briefly summarize the origin of the different data sets.

## data_pacmanRight.mat
Frequency response function for the PAC-MAN benchmark example, introduced in [1]. For the calculation of the data set, we employed the Python implementation provided in the same paper with minor modifications, i.e., replacing the python module scipy by mpmath, in order to enable accurate computations of higher order Bessel functions (truncation order was set to 300). 

## data_VibroAcoustics.mat
Frequency response function for an vibroacoustic model, taken from [2]. In particular, a 2D Mindlin plate is excited by a point force and strongly coupled to a 3D accoustic domain where the response at a point in the fluid is evaluated. We thank Christopher Blech and Sabine Langer for providing the implementation of the finite element solver used to compute the data set.

## data_Spiral.mat
Frequency response function for the reflection coefficient of a spiral antenna model. It is a demo example of CST Microwave Studio [3], where we employed the boundary element method solver to compute the data set.

## data_WGjunctionS**.mat
Frequency response function for the scattering parameters of an electromagnetic waveguide model with 4 ports. It is a demo example of CST Microwave Studio [3], where we employed the finite element solver to compute the dataset.


# References
- [1] H. Ziegelwanger and P. Reiter, The PAC-MAN model: Benchmark case for linear acoustics in computational physics, J. Comput. Phys., 346 (2017), pp. 152–171.
- [2] An adaptive sparse grid rational arnoldi method for uncertainty quantification of dynamical systems in the
frequency domain, Int. J. Numer. Meth., (2021), pp. 5487–5511.
- [3] Dassault Systemes, CST STUDIO SUITE 2019, https://www.cst.com
