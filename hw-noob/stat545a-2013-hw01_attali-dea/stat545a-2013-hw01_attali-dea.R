n <- 50
a <- 2
b <- -3
sigSq <- 0.5
x <- runif(n)
norm <- rnorm(n, sd = sqrt(sigSq))
y <- a + b * x + norm
plot(x,y)
abline(a, b, col = "blue")