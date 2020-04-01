#install.packages("devtools")
#library(devtools)
#devtools::install_github("BrandonEdwards/bbsBayes", ref = "v2.1.0")
library(bbsBayes)

# Run this the first time to download bbs data to disk
#fetch_bbs_data()

s <- "bbs_cws"
stratified_data <- stratify(by = s)

jags_data <- prepare_jags_data(strat_data = stratified_data,
                               species_to_run = "Wood Thrush",
                               model = "gamye")

jags_mod <- run_model(jags_data = jags_data,
                      n_adapt = 1000,
                      n_saved_steps = 1000,
                      n_burnin = 10000,
                      n_chains = 3,
                      n_thin = 10,
                      parallel = FALSE,
                      parameters_to_save = c("n",
                                             "n3",
                                             "taunoise",
                                             "strata",
                                             "B.X",
                                             "beta.X"))

jags_mod <- run_model(jags_data = jags_data,
                      n_saved_steps = 1000,
                      n_burnin = 0,
                      n_adapt = 0,
                      n_chains = 3,
                      n_thin = 1,
                      n_iter= 100,
                      parallel = TRUE,
                      parameters_to_save = c("n",
                                             "n3",
                                             "taunoise",
                                             "strata",
                                             "B.X",
                                             "beta.X"))

rhat <- r_hat(jags_mod = jags_mod,
              parameter_list = c("n", "n3"),
              threshold = 1.1)

# Generate indices at the continental, national, and stratum level
indices <- generate_indices(jags_mod = jags_mod,
                            jags_data = jags_data,
                            regions = c("continental",
                                        "national",
                                        "stratum"))

# Create a list of trajectory plots, with observed means
plot_list <- plot_indices(indices_list = indices,
                          species = "Wood Thrush",
                          add_observed_means = TRUE,
                          title_size = 18,
                          axis_title_size = 14,
                          axis_text_size = 12)

# Save the continental plot as png
png("Figures/Figure 2.png",
    width = 6.5, height = 4, res = 300, units = "in")
print(plot_list$Continental)
dev.off()

# Side-by-side national level trajectories, Canada and USA
library(gridExtra)
png("Figures/Figure 3.png",
    width = 6.5, height = 9, res = 300, units = "in")
grid.arrange(plot_list$Canada,
             plot_list$United_States_of_America,
             nrow = 2, ncol = 1)
dev.off()

png("Figures/Figure 4.png",
    width = 9, height = 5.5, res = 300, units = "in")
geo <- geofacet_plot(indices_list = indices,
                     stratify_by = s,
                     select = TRUE,
                     multiple = TRUE,
                     species = "Wood Thrush")
print(geo)
dev.off()


trends <- generate_trends(indices = indices,
                          Min_year = 2008,
                          Max_year = 2018,
                          prob_decrease = c(0, 50, 100))

png("Figures/Figure 5.png",
    width = 6.5, height = 4.5, res = 300, units = "in")
woth_map <- generate_map(trend = trends,
                         select = TRUE,
                         stratify_by = s,
                         species = "Wood Thrush")
woth_map
dev.off()
