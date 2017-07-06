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
    fun=list(median, sd, length),
    value.var=c("A", "B", "R", "v")
    )

aggregated[, sample := paste(name, region, smoke, sep="_")]

print(aggregated)


width = 7
aspect.ratio = 1
height = width * aspect.ratio

base = ggplot(aggregated, aes(x=factor(sample, levels=aggregated[order(smoke, region), sample])))
ratio = base +
    geom_point(aes(y=R_median_.), size=2) +
    geom_errorbar(aes(ymax = R_median_. + R_sd_., ymin = R_median_. - R_sd_.)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(
         x="",
         y="R"
         )
absorption = base +
    geom_point(aes(y=A_median_.), size=2) +
    geom_errorbar(aes(ymax = A_median_. + A_sd_., ymin = A_median_. - A_sd_.)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(
         x="",
         y="transmission"
         )
darkfield = base +
    geom_point(aes(y=B_median_.), size=2) +
    geom_errorbar(aes(ymax = B_median_. + B_sd_., ymin = B_median_. - B_sd_.)) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(
         x="",
         y="dark field"
         )
visibility = base +
    geom_point(aes(y=v_median_.), size=2) +
    geom_errorbar(aes(ymax = v_median_. + v_sd_., ymin = v_median_. - v_sd_.)) +
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
