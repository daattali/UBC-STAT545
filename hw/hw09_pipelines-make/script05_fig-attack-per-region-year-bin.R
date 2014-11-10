library(dplyr)
library(ggplot2)

# read the attacks per region binned data
attackByRegion5YearBin <- read.table("attackByRegion5YearBin.csv", header = TRUE,
														 row.names = NULL, sep = ",", quote = "\"")

# read the order in which the region levels should be and reorder the data
regionOrder <- read.table("attackByRegion5YearBin-regionOrder.txt", header = FALSE,
													row.names = NULL, quote = "\"")
regionOrder <- regionOrder %>% first
attackByRegion5YearBin <-
	attackByRegion5YearBin %>%
	mutate(region = factor(region, regionOrder))

# plot!
c12 <- c("dodgerblue2","#E31A1C", "green4", "#6A3D9A", "#FF7F00", "black",
				 "gold1", "skyblue2","#FB9A99", "palegreen2", "#CAB2D6", "#FDBF6F")
ggplot(attackByRegion5YearBin, aes(x = region, y = nattacks, fill = region)) +
	geom_bar(stat = "identity", show_guide=FALSE) +
	facet_wrap(~bin, ncol = 4) +
	ylab("# of Attacks") + 
	ggtitle("Number of Terrorist Attacks in World Regions\nin 5-Year Intervals Since 1970") + 
	xlab("") +
	coord_flip() +  # to make the bars horizontal so that reading the regions is easier
	scale_fill_manual(values = c12) +
	theme_bw(15) +
	theme(panel.background = element_rect(fill='#EEEEEE'),
				panel.grid.major.y = element_blank(),
				strip.text = element_text(face="bold"),
				plot.title = element_text(face="bold"))
ggsave("attackByRegion5YearBin.png", width = 10, height = 6)
