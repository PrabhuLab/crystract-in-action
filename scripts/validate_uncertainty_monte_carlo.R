run_monte_carlo_validation <- function(samples = 4000L, seed = 10L) {
  stopifnot(length(samples) == 1L, is.finite(samples), samples >= 2, samples == as.integer(samples))
  cell <- data.table::data.table(
    `_cell_length_a` = 7, `_cell_length_b` = 8, `_cell_length_c` = 9,
    `_cell_angle_alpha` = 79, `_cell_angle_beta` = 83, `_cell_angle_gamma` = 74,
    `_cell_length_a_error` = .002, `_cell_length_b_error` = .002, `_cell_length_c_error` = .002,
    `_cell_angle_alpha_error` = .01, `_cell_angle_beta_error` = .01, `_cell_angle_gamma_error` = .01)
  atoms <- data.table::data.table(Label = c("A", "B"), x_a = c(.1,.2), y_b = c(.05,.12),
    z_c = c(.07,.3), x_error = .001, y_error = .001, z_error = .001)
  operations <- data.table::data.table(x = c("x","-x"), y = c("y","-y"), z = c("z","-z"))
  images <- crystract::expand_transformed_coords(crystract::apply_symmetry_operations(atoms, operations, cell), c(0,0,0))
  bond <- crystract::calculate_distances(atoms[Label == "A"], images[Label == "B_2_0_0_0"], cell)
  angle <- data.table::data.table(CentralAtom = "A", Neighbor1 = "B_1_0_0_0", Neighbor2 = "B_2_0_0_0", Angle = 0)
  analytic <- c(crystract::propagate_distance_error(bond, atoms, cell, images)$DistanceError,
                crystract::propagate_angle_error(angle, atoms, images, cell)$AngleError)
  mean_input <- c(7,8,9,c(79,83,74)*pi/180,.1,.05,.07,.2,.12,.3)
  sd_input <- c(rep(.002,3),rep(.01*pi/180,3),rep(.001,6))
  evaluate <- function(p) { # p = (a,b,c,alpha,beta,gamma,A_x,A_y,A_z,B_x,B_y,B_z); angles in radians.
    ca <- cos(p[4]); cb <- cos(p[5]); cg <- cos(p[6]); sg <- sin(p[6])
    D <- 1-ca^2-cb^2-cg^2+2*ca*cb*cg
    M <- rbind(c(p[1],p[2]*cg,p[3]*cb), c(0,p[2]*sg,p[3]*(ca-cb*cg)/sg), c(0,0,p[3]*sqrt(D)/sg))
    first <- as.numeric(M %*% (p[10:12]-p[7:9])) # u = M(B-A).
    second <- as.numeric(M %*% (1-p[10:12]-p[7:9])) # v = M((1-B)-A); reuse the same sampled B.
    c(Distance = sqrt(sum(second^2)), Angle = acos(sum(first*second)/sqrt(sum(first^2)*sum(second^2)))*180/pi)
  }
  set.seed(seed)
  inputs <- matrix(stats::rnorm(samples*12,mean_input,sd_input),ncol=12,byrow=TRUE)
  simulated <- t(apply(inputs,1,evaluate))
  observed <- apply(simulated,2,stats::sd) # Sample SD of q(p) estimates sigma_q without analytic derivatives.
  summary <- data.table::data.table(Quantity=c("Distance","Angle"),Unit=c("angstrom","degree"),
    AnalyticSU=analytic, MonteCarloSD=unname(observed),
    RelativeDifferencePercent=100*abs(analytic/observed-1), Samples=samples, Seed=seed)
  stopifnot(all(is.finite(simulated)),all(is.finite(analytic)),all(analytic > 0))
  input_table <- data.table::data.table(Parameter=c("a","b","c","alpha","beta","gamma","A_x","A_y","A_z","B_x","B_y","B_z"),
    Mean=c(7,8,9,79,83,74,.1,.05,.07,.2,.12,.3), StandardUncertainty=c(rep(.002,3),rep(.01,3),rep(.001,6)),
    Unit=c(rep("angstrom",3),rep("degree",3),rep("fractional",6)))
  list(summary=summary, inputs=input_table, draws=data.table::as.data.table(simulated), nominal=evaluate(mean_input))
}

export_monte_carlo_validation <- function(result, output_dir) {
  dir.create(output_dir,recursive=TRUE,showWarnings=FALSE)
  data.table::fwrite(result$summary,file.path(output_dir,"monte_carlo_summary.csv"))
  data.table::fwrite(result$inputs,file.path(output_dir,"monte_carlo_inputs.csv"))
  data.table::fwrite(result$draws,file.path(output_dir,"monte_carlo_draws.csv"))
  long <- data.table::melt(result$draws,measure.vars=c("Distance","Angle"),variable.name="Quantity",value.name="Value")
  curve <- data.table::rbindlist(lapply(seq_len(nrow(result$summary)),function(i) {
    q <- result$summary$Quantity[i]
    x <- seq(min(long[Quantity==q,Value]),max(long[Quantity==q,Value]),length.out=400)
    data.table::data.table(Quantity=q,Value=x,Density=stats::dnorm(x,result$nominal[q],result$summary$AnalyticSU[i]))
  }))
  plot <- ggplot2::ggplot(long,ggplot2::aes(x=Value)) +
    ggplot2::geom_histogram(ggplot2::aes(y=ggplot2::after_stat(density)),bins=45,fill="#74a9cf",color="white") +
    ggplot2::geom_line(data=curve,ggplot2::aes(y=Density),color="#a50f15",linewidth=.9) +
    ggplot2::facet_wrap(~Quantity,scales="free",labeller=ggplot2::as_labeller(c(Distance="Distance (angstrom)",Angle="Angle (degrees)"))) +
    ggplot2::labs(x="Recalculated value",y="Probability density",title="Monte Carlo validation of propagated uncertainty",
      subtitle=sprintf("%s draws; bars: simulated values; line: normal density using the analytic standard uncertainty",result$summary$Samples[1])) +
    ggplot2::theme_bw(base_size=14)
  ggplot2::ggsave(file.path(output_dir,"monte_carlo_validation.png"),plot,width=11,height=4.5,dpi=400)
  invisible(plot)
}
