#!/usr/bin/env Rscript

library(ggplot2)
library(data.table)
library(argparse)

theme_set(theme_bw(base_size=12) + theme(
    legend.key.size=unit(1, 'lines'),
    text=element_text(face='plain', family='CM Roman'),
    legend.title=element_text(face='plain'),
    axis.line=element_line(color='black'),
    axis.title.y=element_text(vjust=0.1),
    axis.title.x=element_text(vjust=0.1),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.key = element_blank(),
    panel.border = element_blank()
))

commandline_parser = ArgumentParser(
        description="make plots")
commandline_parser$add_argument('-f', '--file',
            type='character', nargs='?', default='reconstructed.csv',
            help='file with the data.table')
args = commandline_parser$parse_args()

table = readRDS(args$f)
print(table)
aggregated = dcast(
    table,
    smoke + name + region ~ .,
    fun=list(mean, sd, length),
    value.var=c("A", "B", "R", "v")
    )

aggregated[, sample := paste(name, region, smoke, sep="_")]

print(aggregated)


width = 7
factor = 1
height = width * factor

ratio = ggplot(aggregated, aes(x=factor(sample))) +
    geom_point(aes(y=R_mean_.), size=2) +
    geom_errorbar(aes(ymax = R_mean_. + R_sd_., ymin = R_mean_. - R_sd_.)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(
         x="",
         y="R"
         )
absorption = ggplot(aggregated, aes(x=factor(sample))) +
    geom_point(aes(y=A_mean_.), size=2) +
    geom_errorbar(aes(ymax = A_mean_. + A_sd_., ymin = A_mean_. - A_sd_.)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(
         x="",
         y="transmission"
         )
darkfield = ggplot(aggregated, aes(x=factor(sample))) +
    geom_point(aes(y=B_mean_.), size=2) +
    geom_errorbar(aes(ymax = B_mean_. + B_sd_., ymin = B_mean_. - B_sd_.)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(
         x="",
         y="dark field"
         )
visibility = ggplot(aggregated, aes(x=factor(sample))) +
    geom_point(aes(y=v_mean_.), size=2) +
    geom_errorbar(aes(ymax = v_mean_. + v_sd_., ymin = v_mean_. - v_sd_.)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(
         x="",
         y="flat field visibility"
         )

print(ratio)

ggsave("plots/visibility.png", visibility, width=width, height=height, dpi=300)
ggsave("plots/absorption.png", absorption, width=width, height=height, dpi=300)
ggsave("plots/ratio.png", ratio, width=width, height=height, dpi=300)
ggsave("plots/darkfield.png", darkfield, width=width, height=height, dpi=300)

invisible(readLines(con="stdin", 1))
