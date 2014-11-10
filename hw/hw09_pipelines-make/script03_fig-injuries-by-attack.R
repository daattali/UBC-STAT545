library(dplyr)
library(ggplot2)

# read the injuries by attack type data
injuryByAttack <- read.table("injuryByAttack.csv", header = TRUE,
															row.names = NULL, sep = ",", quote = "\"")

# read the order in which the attack levels should be and reorder the data
attackTypeOrder <- read.table("injuryByAttack-attackTypeOrder.txt", header = FALSE,
															row.names = NULL, quote = "\"")
attackTypeOrder <- attackTypeOrder %>% first
injuryByAttack <-
	injuryByAttack %>%
	mutate(attacktype = factor(attacktype, attackTypeOrder))

# plot people wounded/killed per attack type
ggplot(injuryByAttack, aes(x = attacktype, y = value, fill = stat)) +
	geom_bar(stat = "identity", position = position_dodge(width=0.9)) +
	coord_flip() +
	ggtitle("Number of People Wounded or Killed\nby Terrorist Attacks Since 1970 Globally") +
	xlab("") +
	ylab("# of People") +
	scale_fill_manual(name = "Injury Type", values = c("black", "red"), labels = c('Killed', 'Wounded')) +
	guides(fill = guide_legend(reverse = TRUE)) +
	theme_bw(20) +
	theme(panel.grid.major.y = element_blank(),
				plot.title = element_text(face="bold"))
ggsave("injuryByAttack.png", width = 10, height = 6)
