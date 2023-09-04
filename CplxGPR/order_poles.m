function poles = order_poles(poles, xmin, xmax, max_dist, max_num_poles)

dist_y = imag(poles);
dist_x = (xmin-real(poles)) .* (real(poles)<xmin) + (real(poles)-xmax).*(real(poles)>xmax);
dist = sqrt(dist_y.^2+dist_x.^2);
[dist,idx] = sort(dist);
poles=poles(idx);
poles=poles(dist<max_dist);

if length(poles)>max_num_poles
    poles = poles(1:max_num_poles);
end

end