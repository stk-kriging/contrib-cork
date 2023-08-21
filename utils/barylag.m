%Modified to interpolate multiple functions simultaneously

function [p]=barylag(data,x)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% barylag.m
%
% Interpolates the given data using the Barycentric
% Lagrange Interpolation form [p] = barylag_mod(data, x)ula. Vectorized to remove all loops
%
% data - a two column vector where column one contains the
%        nodes and column two contains the function value
%        at the nodes
% p - interpolated data. Column one is just the
%     fine mesh x, and column two is interpolated data
%
% Reference:
%
% (1) Jean-Paul Berrut & Lloyd N. Trefethen, "Barycentric Lagrange
%     Interpolation"
%     http://web.comlab.ox.ac.uk/oucl/work/nick.trefethen/berrut.ps.gz
% (2) Walter Gaustschi, "Numerical Analysis, An Introduction" (1997) pp. 94-95
%
%
% Written by: Greg von Winckel       03/07/04
% Contact:    gregvw@chtm.unm.edu
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copyright (c) 2004, Greg von Winckel
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

M=size(data,1);     N=length(x);

% Compute the barycentric weights
X=repmat(data(:,1),1,M);

% matrix of weights
W=repmat(1./prod(X-X.'+eye(M),1),N,1);

% Get distances between nodes and interpolation points
xdist=repmat(x,1,M)-repmat(data(:,1).',N,1);

% Find all of the elements where the interpolation point is on a node
[fixi,fixj]=find(xdist==0);

% Use NaNs as a place-holder
xdist(fixi,fixj)=NaN;
H=W./xdist;

% Compute the interpolated polynomial
p=(H*data(:,2:end))./sum(H,2);

% Replace NaNs with the given exact values.
p(fixi)=data(fixj,2:end);

