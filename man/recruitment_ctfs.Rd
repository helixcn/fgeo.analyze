% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/demography_ctfs.R
\name{recruitment_ctfs}
\alias{recruitment_ctfs}
\alias{mortality_ctfs}
\alias{growth_ctfs}
\title{Recruitment, mortality, and growth.}
\usage{
recruitment_ctfs(census1, census2, mindbh = NULL, alivecode = NULL,
  split1 = NULL, split2 = NULL, quiet = FALSE)

mortality_ctfs(census1, census2, alivecode = NULL, split1 = NULL,
  split2 = NULL, quiet = FALSE)

growth_ctfs(census1, census2, rounddown = FALSE, method = "I",
  stdev = FALSE, dbhunit = "mm", mindbh = NULL, growthcol = "dbh",
  err.limit = 1000, maxgrow = 1000, split1 = NULL, split2 = NULL,
  quiet = FALSE)
}
\arguments{
\item{census1, census2}{Two census tables, each being a ForestGEO-like \emph{tree}
table (dataframe). A \emph{stem} table won't fail, but you should use a \emph{tree}
table because demography analyses make more sense at the scale of trees
than at the scale of stems.}

\item{mindbh}{The minimum diameter above which the counts are done. Trees
smaller than \code{mindbh} are excluded. By default all living trees of any size
are included.}

\item{alivecode}{Character; valid values of \code{status} indicating that a tree
is alive. The default, 'A', is the standard CTFS designation for living
trees or stems.}

\item{split1, split2}{Optional vector(s) to aggregate results by. Each vector
should be a column of either \code{census1} or \code{census2}. The default aggregates
the result across the entire census datasets.}

\item{quiet}{Use \code{TRUE} to suppress messages.}

\item{rounddown}{If \code{TRUE}, all \code{dbh < 55} are rounded down to the nearest
multiple of 5.}

\item{method}{Either "I" or "E":
\itemize{
\item Use "I" to calculate annual dbh increment as \code{(dbh2 - dbh1)/time}
\item Use "E" to calculate the relative growth rate as
\code{(log(dbh2) - log(dbh1)) / time}
}}

\item{stdev}{Logical:
\itemize{
\item \code{FALSE} returns confidence limits.
\item \code{TRUE} returns the SD in growth rate per group.
}}

\item{dbhunit}{"cm" or "mm".}

\item{growthcol}{Either "dbh" or "agb" to define how growth is measured.}

\item{err.limit, maxgrow}{A number. Numbers such as 10000 are high and will
return all measures.}
}
\value{
Metrics of recruitment: Similar to metrics of mortality.

Metrics of mortality:
\itemize{
\item \code{N}: the number of individuals alive in the census 1 per category
selected.
\item \code{D}: the number of individuals no longer alive in census 2.
\item \code{rate}: the mean annualized mortality rate constant per category
selected, calculated as (log(N)-log(S))/time.
\item \code{upper}: upper confidence limit of mean rate.
\item \code{lower}: lower confidence limit of mean rate.
\item \code{time}: mean time interval in years.
\item \code{date1}: mean date included individuals were measured in census 1, as
julian object (R displays as date, but treats as integer).
\item \code{date2}: mean date in census 2.
\item \code{dbhmean}: mean dbh in census 1 of individuals included.
}

Metrics of growth:
\itemize{
\item \code{rate}, the mean annualized growth rate per category selected, either dbh
increment, or relative growth.
\item \code{N}, the number of individuals included in the mean (not counting any
excluded).
\item \code{clim} (or sd with \code{stdev = TRUE}), width of confidence interval; add this
number to the mean rate to get upper confidence limit, substract to get
lower.
\item \code{dbhmean}, mean dbh in census 1 of individuals included.
\item \code{time}, mean time interval in years.
\item \code{date1}, mean date included individuals were measured in census 1, as
julian object (R displays as date, but treats as integer).
\item \code{date2}, mean date in census 2.
}
}
\description{
\Sexpr[results=rd, stage=render]{fgeo.analyze:::lifecycle("questioning")}

These functions are adapted from the CTFS-R package. Compared to the
original functions, these ones have a similar interface but use more
conservative defaults and allow suppressing messages. These functions also
feature formal tests, bug fixes, additional assertions, and improved
messages.
}
\details{
Survivors are all individuals alive in both censuses, with \code{status == A} in
the first census, and a diameter greater than \code{mindbh} in the first census.
The total population in the second census includes all those alive plus any
other survivors. Individuals whose status is \code{NA} in either census are
deleted from all calculations.
}
\examples{
assert_is_installed("fgeo.x")

census1 <- fgeo.x::tree5
census2 <- fgeo.x::tree6

as_tibble(
  recruitment_ctfs(census1, census2)
)

# Use `interaction(...)` to aggregate by any number of grouping variables
sp_quadrat <- interaction(census1$sp, census1$quadrat)

recruitment <- recruitment_ctfs(
  census1, census2,
  split1 = sp_quadrat,
  quiet = TRUE
)
as_tibble(recruitment)

mortality <- mortality_ctfs(
  census1, census2,
  split1 = sp_quadrat, quiet = TRUE
)
as_tibble(mortality)

growth <- growth_ctfs(census1, census2, split1 = sp_quadrat, quiet = TRUE)
as_tibble(growth)

# Easy way to separate grouping variables
tidyr_is_installed <- requireNamespace("tidyr", quietly = TRUE)
if (tidyr_is_installed) {
  library(tidyr)

  as_tibble(growth) \%>\%
    separate(groups, into = c("sp", "quadrat"))
}
}
\author{
Rick Condit, Suzanne Lao.
}
\concept{demography functions}
\concept{functions for ForestGEO data.}
\concept{functions for fgeo census.}
