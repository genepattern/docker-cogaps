override_plotP <- function(Pmean) 
{
    colors <- rainbow(nrow(Pmean))
    xlimits <- c(0, ncol(Pmean) + 1)
    ylimits <- c(0, (max(Pmean) * 1.05))

    plot(NULL, xlim=xlimits, ylim=ylimits, ylab="Relative Amplitude")

    for (i in 1:nrow(Pmean))
    {
        lines(x=1:ncol(Pmean), y=Pmean[i,], col=colors[i])
        points(x=1:ncol(Pmean), y=Pmean[i,], col=colors[i], pch=i)
    }

    legend("bottom", paste("Pattern", 1:nrow(Pmean), sep = ""),
       pch = 1:nrow(Pmean), lty=1, cex=0.8, col=colors, bty="y", ncol=5)
}

