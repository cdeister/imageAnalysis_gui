function out = crtiloc(hits, misses)

out = -0.5*(norminv(hits) + norminv(misses));

