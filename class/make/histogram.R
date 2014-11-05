words <- read.delim("words.tsv", stringsAsFactors = FALSE)[[1]]
wordLengths <- nchar(words)
counts <- table(wordLengths)
write.table(counts, "histogram.tsv",
						sep = "\t", row.names = FALSE, quote = FALSE)
