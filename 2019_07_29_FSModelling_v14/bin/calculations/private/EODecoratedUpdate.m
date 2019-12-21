function EODecoratedUpdate(output, result, geometry, vf, band, color)
% Rely on the contract that is path, results and output to
% extract the required information and send it to Update & plot it.
% Plotting is done on the CURRENT figure. 
        
a = band('a');
b = band('b');
c = band('c');
id = band('id');
B = band('B');

path = geometry.CalcPath(result.a, result.b, true);
kf = @geometry.Points;
Bvec = [geometry.Ux, geometry.Uy, geometry.Uz] .* B;
time = TimeNewtonian(path, kf, vf, Bvec);
        
% The k-values are in the range +-pi/a (etc) so they are rescaled
% this way to more intuitive scales [-1,1]
freq = AreaToFrequency(result.area);
dfreq = AreaToFrequency(result.dArea);
[X, Y, Z] = kf(path(:,1), path(:,2));
[X, Y, Z] = FSTransformCoordinates(band, X, Y, Z);

output.Update(result.plane, freq, dfreq, time, id);
hold on;
plot3(X, Y, Z, 'Color', color); 
end %EODecoratedUpdate
