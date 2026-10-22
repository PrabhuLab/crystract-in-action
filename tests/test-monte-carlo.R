source('scripts/validate_uncertainty_monte_carlo.R')
x <- run_monte_carlo_validation()
stopifnot(nrow(x$draws)==4000,nrow(x$inputs)==12,
          all(x$summary$RelativeDifferencePercent < 6),
          isTRUE(all.equal(x$summary$AnalyticSU,c(.0135679682140531,.264378949552096),tolerance=1e-10)),
          isTRUE(all.equal(x$summary$MonteCarloSD,c(.0135275244940382,.265428672218074),tolerance=1e-10)),
          inherits(try(run_monte_carlo_validation(1),silent=TRUE),'try-error'))
cat('Monte Carlo notebook validation reproduces the package regression case.\n')
