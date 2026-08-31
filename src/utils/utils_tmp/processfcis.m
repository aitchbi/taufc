function fcicis = processfcis(fcicis, opts)

fcicis = hb_fc_thresh(fcicis, opts.thresh_FC, opts.density_FC, opts.knn_FC);

assert(not(and(opts.AbsoluteValueFC, opts.PositiveValueFC)));

if opts.AbsoluteValueFC

    fcicis = abs(fcicis);

elseif opts.PositiveValueFC

    fcicis(fcicis<0) = 0;
end
end
