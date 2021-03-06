library(twitteR)
library(igraph)

source("./funs/get_tweets.R")
source("./funs/lemmatize.R")
set.seed(23)
load("./data/katab_ego.rda")

network <- graph.edgelist(katab_ego, directed = FALSE)
high_degree_nodes <- names(igraph::degree(network, mode="all")[igraph::degree(network, mode="all")>3])

imc <- infomap.community(network)

# sub graph of the high degree nodes
high_degree_subnet <- subgraph.edges(network, V(network)[name %in% high_degree_nodes])
hd_df <- as_data_frame(high_degree_subnet)

hd_df$community <- imc$membership[imc$name %in% high_degree_nodes]

# names of high degree users and communities they belong to
twitter_sub <- data.frame(name = unique(c(hd_df$from,hd_df$to)),
                          community = imc$membership[imc$name %in% unique(c(hd_df$from,hd_df$to))])

# trying to fetch users tweets
test <- get_tweets(as.character(twitter_sub$name)[1:155], as.character(twitter_sub$community)[1:155])
test2 <- get_tweets(as.character(twitter_sub$name)[156], as.character(twitter_sub$community)[156])

txt_data <- rbind(test, test2)

# lemmatize tweets
txt_data$Lem <- lemmatize(txt_data$Tweet)
txt_data$Lem[txt_data$Lem=="      "] <- NA
txt_data$Cluster <- paste("comm", txt_data$Cluster, sep="")

# Save txt data
save(txt_data, file="./data/txt_data.rda")
write.csv(txt_data, "./data/txt_data.csv")  # for mining with RtEmIs

