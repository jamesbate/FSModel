function [volume, error] = ConvexVolume(func, delta, maxA, maxB)
% Calculate the volume enclosed by a 2D parametrization.
% ! do not use this any longer outside of tests !
%
% The problem is that this works only for convex shapes, no concave
% part in it because convhull() basically triangulizes the object in such a
% way that the maximum possible volume enclosed by the points is obtained.
% This means any cavity will have a straight cutoff over it and the volume
% is not correct. This has no warning either and is hard to find.
%
% Secondly, this is really slow even for a simple figure such as a cilinder
% you can take a full second to obtain 1% accuracy. But it is robust if you
% know the shape is convex, which means it is ok for tests
%
% func : function of 2 arguments (A, B)
%   Both are assumed to run [0, 2pi]
% delta : double
%   Fractional error that should be aimed at, defaulted 0.001.
% maxA : int
%   The maximum number of points to use along the A dimension.
%   Defaulted 1000
% maxB : int
%   The maximum number of points to use along the B dimension.
%   Defaulted 1000
%
% Note that time complexity is O(maxA*maxB)
% Space complexity is O(maxA*maxB)
% Error scaling is O(1/(maxA*maxB))
%
% Error determined using the above scaling. A and B are increased a factor 
% 2 in the last stage and the resulting difference is an indication.
% The actual error is expected 1/4 of that difference, instead 1/2 is
% returned. Meaning the maximum error is double 'error', the actual error
% is half of 'error'.

args = nargin;
if args < 2
    delta = 0.001;
end
if args < 3
    maxA = 1000;
end
if args < 4
    maxB = 1000;
end


nrA = 10;
nrB = 10;
last_res = 1e99;
this_res = ConvexVolumeDirect(func, nrA, nrB);
while abs(last_res - this_res) / this_res > delta * 2 && nrA < maxA / 2
    nrA = nrA * 2;
    last_res = this_res;
    this_res = ConvexVolumeDirect(func, nrA, nrB);
end

last_res = 1e99;
while abs(last_res - this_res) / this_res > delta * 2 && nrB < maxB / 2
    nrB = nrB * 2;
    last_res = this_res;
    this_res = ConvexVolumeDirect(func, nrA, nrB);
end
rough = this_res;
volume = ConvexVolumeDirect(func, nrA * 2, nrB * 2);

% abs should not be necessary here as volume should be strictly increasing
% towards what it should be.
error = (volume - rough) / 2;
end %ConvexVolume
