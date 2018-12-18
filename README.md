
<!-- README.md is generated from README.Rmd. Please edit that file -->

# <img src="https://i.imgur.com/vTLlhbp.png" align="right" height=88 /> Analyze fgeo data

[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build
status](https://travis-ci.org/forestgeo/fgeo.analyze.svg?branch=master)](https://travis-ci.org/forestgeo/fgeo.analyze)
[![Coverage
status](https://coveralls.io/repos/github/forestgeo/fgeo.analyze/badge.svg)](https://coveralls.io/r/forestgeo/fgeo.analyze?branch=master)
[![CRAN
status](https://www.r-pkg.org/badges/version/fgeo.analyze)](https://cran.r-project.org/package=fgeo.analyze)

The goal of **fgeo.analyze** is to analyze fgeo data.

## Installation

    # install.packages("devtools")
    devtools::install_github("forestgeo/fgeo.analyze")

Or [install all **fgeo** packages in one
step](https://forestgeo.github.io/fgeo/index.html#installation).

For details on how to install packages from GitHub, see [this
article](https://goo.gl/dQKEeg).

## Example

``` r
library(fgeo.tool)
#> 
#> Attaching package: 'fgeo.tool'
#> The following object is masked from 'package:stats':
#> 
#>     filter
library(fgeo.analyze)
```

### Abundance

Your data may have multiple stems per treeid and even multiple measures
per stemid (if trees have
buttresses).

``` r
# Trees with buttresses may have multiple measurements of a single stem. 
# Main stems have highest `HOM`, then largest `DBH`.
vft <- tribble(
  ~CensusID, ~TreeID, ~StemID, ~DBH, ~HOM,
          1,     "1",   "1.1",   88,  130,
          1,     "1",   "1.1",   10,  160,  # Main stem
          1,     "2",   "2.1",   20,  130,
          1,     "2",   "2.2",   30,  130,  # Main stem
)
```

Fundamentally, `abundance()` counts rows. All of these results are the
same:

``` r
nrow(vft)
#> [1] 4
count(vft)
#> # A tibble: 1 x 1
#>       n
#>   <int>
#> 1     4
summarize(vft, n = n())
#> # A tibble: 1 x 1
#>       n
#>   <int>
#> 1     4
abundance(vft)
#> Warning: `treeid`: Duplicated values were detected. Do you need to pick
#> main stems?
#> # A tibble: 1 x 1
#>       n
#>   <int>
#> 1     4
```

But that result is likely not what you expect. Instead, you likely
expect this:

``` r
summarize(vft, n = n_distinct(TreeID))
#> Warning in summarise_impl(.data, dots): hybrid evaluation forced for
#> `n_distinct`. Please use dplyr::n_distinct() or library(dplyr) to remove
#> this warning.
#> # A tibble: 1 x 1
#>       n
#>   <int>
#> 1     2
```

As shown above, you can get a correct result by combining `summarize()`
and `n_distinct()` (from the **dplyr** package). But `abundance()`
includes some useful additional features (see `?abundance()`). This code
conveys your intention more clearly, i.e. to calculate tree abundance by
counting the number of main stems:

``` r
(main_stems <- pick_main_stem(vft))
#> # A tibble: 2 x 5
#>   CensusID TreeID StemID   DBH   HOM
#>      <dbl> <chr>  <chr>  <dbl> <dbl>
#> 1        1 1      1.1       10   160
#> 2        1 2      2.2       30   130
abundance(main_stems)
#> # A tibble: 1 x 1
#>       n
#>   <int>
#> 1     2
```

If you have data from multiple censuses, then you can compute by census
(or any other group).

``` r
vft2 <- tibble::tribble(
  ~CensusID, ~TreeID, ~StemID, ~DBH, ~HOM,
          1,     "1",   "1.1",   10,  130,
          1,     "1",   "1.2",   20,  130,  # Main stem
          2,     "1",   "1.1",   12,  130,
          2,     "1",   "1.2",   22,  130   # Main stem
)
by_census <- group_by(vft2, CensusID)
(main_stems_by_census <- pick_main_stem(by_census))
#> # A tibble: 2 x 5
#> # Groups:   CensusID [2]
#>   CensusID TreeID StemID   DBH   HOM
#>      <dbl> <chr>  <chr>  <dbl> <dbl>
#> 1        1 1      1.2       20   130
#> 2        2 1      1.2       22   130
abundance(main_stems_by_census)
#> # A tibble: 2 x 2
#> # Groups:   CensusID [2]
#>   CensusID     n
#>      <dbl> <int>
#> 1        1     1
#> 2        2     1
```

Often you will need to first subset data (e.g. by `status` or `DBH`) and
then count.

``` r
over20 <- filter(main_stems_by_census, DBH > 20)
abundance(over20)
#> # A tibble: 1 x 2
#> # Groups:   CensusID [1]
#>   CensusID     n
#>      <dbl> <int>
#> 1        2     1
```

### Basal area

If trees have buttresses, then you may need to pick the main stemid of
each stem so you do not count the same stem more than once.

``` r
vft3 <- tribble(
  ~CensusID, ~TreeID, ~StemID, ~DBH, ~HOM,
          1,     "1",   "1.1",   88,  130,
          1,     "1",   "1.1",   10,  160,  # Main stem
          1,     "2",   "2.1",   20,  130,
          1,     "2",   "2.2",   30,  130,  # Main stem
          2,     "1",   "1.1",   98,  130,
          2,     "1",   "1.1",   20,  160,  # Main stem
          2,     "2",   "2.1",   30,  130,
          2,     "2",   "2.2",   40,  130,  # Main stem
)
(main_stemids <- pick_main_stemid(vft3))
#> # A tibble: 6 x 5
#>   CensusID TreeID StemID   DBH   HOM
#>      <dbl> <chr>  <chr>  <dbl> <dbl>
#> 1        1 1      1.1       10   160
#> 2        1 2      2.1       20   130
#> 3        1 2      2.2       30   130
#> 4        2 1      1.1       20   160
#> 5        2 2      2.1       30   130
#> 6        2 2      2.2       40   130
main_stemids
#> # A tibble: 6 x 5
#>   CensusID TreeID StemID   DBH   HOM
#>      <dbl> <chr>  <chr>  <dbl> <dbl>
#> 1        1 1      1.1       10   160
#> 2        1 2      2.1       20   130
#> 3        1 2      2.2       30   130
#> 4        2 1      1.1       20   160
#> 5        2 2      2.1       30   130
#> 6        2 2      2.2       40   130
basal_area(main_stemids)
#> Warning: `stemid`: Duplicated values were detected. Do you need to pick
#> largest `hom` values?
#> Warning: `censusid`: Multiple values were detected. Do you need to group by
#> censusid?
#> # A tibble: 1 x 1
#>   basal_area
#>        <dbl>
#> 1      3377.
```

`basal_area()` also allows you to compute by groups.

``` r
by_census <- group_by(main_stemids, CensusID)
basal_area(by_census)
#> # A tibble: 2 x 2
#> # Groups:   CensusID [2]
#>   CensusID basal_area
#>      <dbl>      <dbl>
#> 1        1      1100.
#> 2        2      2278.
```

But if you want to compute on a subset of data, then you need to pick
the data first.

``` r
ten_to_twenty <- filter(by_census, DBH >= 10, DBH <= 20)
basal_area(ten_to_twenty)
#> # A tibble: 2 x 2
#> # Groups:   CensusID [2]
#>   CensusID basal_area
#>      <dbl>      <dbl>
#> 1        1       393.
#> 2        2       314.
```

### Abundance and basal area aggregated by year

Example data.

``` r
vft <- fgeo.analyze::example_byyr
vft
#> # A tibble: 8 x 13
#>   PlotName CensusID TreeID StemID Status   DBH Genus SpeciesName ExactDate 
#>   <chr>       <int>  <int>  <dbl> <chr>  <int> <chr> <chr>       <date>    
#> 1 luq             1      1    1.1 alive     10 Gn    spp         2001-01-01
#> 2 luq             1      1    1.2 dead      NA Gn    spp         2001-01-01
#> 3 luq             1      2    2.1 alive     20 Gn    spp         2001-01-01
#> 4 luq             1      2    2.2 alive     30 Gn    spp         2001-01-01
#> 5 luq             2      1    1.1 alive     20 Gn    spp         2002-01-01
#> 6 luq             2      1    1.2 gone      NA Gn    spp         2002-01-01
#> 7 luq             2      2    2.1 dead      NA Gn    spp         2002-01-01
#> 8 luq             2      2    2.2 dead      NA Gn    spp         2002-01-01
#> # ... with 4 more variables: PlotCensusNumber <int>, Family <chr>,
#> #   Tag <int>, HOM <int>
```

Abundance by year.

``` r
abundance_byyr(vft, DBH >= 10, DBH < 20)
#> # A tibble: 1 x 3
#>   species family yr_2001
#>   <chr>   <chr>    <dbl>
#> 1 Gn spp  f            1
abundance_byyr(vft, DBH >= 10)
#> # A tibble: 1 x 4
#>   species family yr_2001 yr_2002
#>   <chr>   <chr>    <dbl>   <dbl>
#> 1 Gn spp  f            2       1
```

Basal area by year.

``` r
basal_area_byyr(vft, DBH >= 10)
#> # A tibble: 1 x 4
#>   species family yr_2001 yr_2002
#>   <chr>   <chr>    <dbl>   <dbl>
#> 1 Gn spp  f        1100.    314.
```

### Demography

``` r
census1 <- fgeo.x::tree5
census2 <- fgeo.x::tree6
```

Demography functions output a list that you can convert to a more
convenient dataframe with `to_df()`.

``` r
recruitment_ctfs(census1, census2)
#> Detected dbh ranges:
#>   * `census1` = 10.9-323.
#>   * `census2` = 10.5-347.
#> Using dbh `mindbh = 0` and above.
#> $N2
#> [1] 29
#> 
#> $R
#> [1] 3
#> 
#> $rate
#> [1] 0.02413113
#> 
#> $lower
#> [1] 0.0084585
#> 
#> $upper
#> [1] 0.06812388
#> 
#> $time
#> [1] 4.525246
#> 
#> $date1
#> [1] 18937.96
#> 
#> $date2
#> [1] 20600.72
to_df(
  recruitment_ctfs(census1, census2, quiet = TRUE)
)
#> # A tibble: 1 x 8
#>      N2     R   rate   lower  upper  time  date1  date2
#>   <dbl> <dbl>  <dbl>   <dbl>  <dbl> <dbl>  <dbl>  <dbl>
#> 1    29     3 0.0241 0.00846 0.0681  4.53 18938. 20601.
```

Except if you use `split2`: This argument creates a complex data
structure that `to_df()` cannot handle.

``` r
not_recommended <- recruitment_ctfs(
  census1, census2, 
  split1 = census1$sp, 
  split2 = census1$quadrat, 
  quiet = TRUE
)
#> Warning: `split2` is deprecated.
#> * Bad: `split1 = x1, split2 = x2`
#> * Good: `split1 = interaction(x1, x2)`
#> This warning is displayed once per session.
# Errs
to_df(not_recommended)
#> Error:   Can't deal with data created with `split2` (deprecated).
#>   * Bad: `split1 = x1, split2 = x2`
#>   * Good: `split1 = interaction(x1, x2)`
```

Instead, pass the multiple grouping variables to `split` via
`interaction()`. This approach allows you to use any number of grouping
variables and the output always works with `to_df()`.

``` r
# Recommended
sp_quadrat <- interaction(census1$sp, census1$quadrat)
recruitment <- recruitment_ctfs(
  census1, census2, 
  split1 = sp_quadrat, 
  quiet = TRUE
)
to_df(recruitment)
#> # A tibble: 540 x 9
#>    groups         N2     R  rate lower upper  time date1 date2
#>    <chr>       <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#>  1 MATDOM.1007     1     0     0     0 0.410  4.50 18891 20535
#>  2 CASSYL.1010     1     0     0     0 0.411  4.49 18914 20555
#>  3 SLOBER.110      1     0     0     0 0.409  4.51 18897 20543
#>  4 SLOBER.1106     1     0     0     0 0.404  4.56 18849 20516
#>  5 CECSCH.1114     1     0     0     0 0.413  4.47 18948 20580
#>  6 PSYBRA.1318     1     0     0     0 0.412  4.48 19011 20646
#>  7 HIRRUG.1403     1     0     0     0 0.403  4.58 18834 20506
#>  8 CASSYL.1411     1     0     0     0 0.414  4.45 18931 20558
#>  9 SLOBER.1414     1     0     0     0 0.403  4.57 18952 20622
#> 10 GUAGUI.1419     1     0     0     0 0.406  4.54 19012 20670
#> # ... with 530 more rows
```

The same applies for other demography
functions.

``` r
to_df(mortality_ctfs(census1, census2, split1 = sp_quadrat, quiet = TRUE))
#> # A tibble: 540 x 10
#>    groups          N     D  rate lower upper  time date1 date2 dbhmean
#>    <chr>       <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>   <dbl>
#>  1 MATDOM.1007     1     0     0     0 0.410  4.50 18891 20535   240  
#>  2 CASSYL.1010     1     0     0     0 0.411  4.49 18914 20555    67  
#>  3 SLOBER.110      1     0     0     0 0.409  4.51 18897 20543   150  
#>  4 SLOBER.1106     1     0     0     0 0.404  4.56 18849 20516    50  
#>  5 CECSCH.1114     1     0     0     0 0.413  4.47 18948 20580   228  
#>  6 PSYBRA.1318     1     0     0     0 0.412  4.48 19011 20646    14  
#>  7 HIRRUG.1403     1     0     0     0 0.403  4.58 18834 20506    12.9
#>  8 CASSYL.1411     1     0     0     0 0.414  4.45 18931 20558    13.1
#>  9 SLOBER.1414     1     0     0     0 0.403  4.57 18952 20622    16.6
#> 10 GUAGUI.1419     1     0     0     0 0.406  4.54 19012 20670   108  
#> # ... with 530 more rows
growth <- to_df(growth_ctfs(census1, census2, split1 = sp_quadrat, quiet = TRUE))
growth
#> # A tibble: 540 x 8
#>    groups        rate     N  clim dbhmean  time date1 date2
#>    <chr>        <dbl> <dbl> <dbl>   <dbl> <dbl> <dbl> <dbl>
#>  1 MATDOM.1007  0         1    NA   240    4.50 18891 20535
#>  2 CASSYL.1010  0.445     1    NA    67    4.49 18914 20555
#>  3 SLOBER.110   0.666     1    NA   150    4.51 18897 20543
#>  4 SLOBER.1106  0         1    NA    50    4.56 18849 20516
#>  5 CECSCH.1114  1.79      1    NA   228    4.47 18948 20580
#>  6 PSYBRA.1318  0.447     1    NA    14    4.48 19011 20646
#>  7 HIRRUG.1403  1.66      1    NA    12.9  4.58 18834 20506
#>  8 CASSYL.1411 NA         0    NA    NA   NA       NA    NA
#>  9 SLOBER.1414  1.40      1    NA    16.6  4.57 18952 20622
#> 10 GUAGUI.1419 NA         0    NA    NA   NA       NA    NA
#> # ... with 530 more rows
```

A simple way to separate the grouping variables is with
`tidyr::separate()`.

``` r
tidyr::separate(
  growth, 
  groups, into = c("species", "quadrats")
)
#> # A tibble: 540 x 9
#>    species quadrats   rate     N  clim dbhmean  time date1 date2
#>    <chr>   <chr>     <dbl> <dbl> <dbl>   <dbl> <dbl> <dbl> <dbl>
#>  1 MATDOM  1007      0         1    NA   240    4.50 18891 20535
#>  2 CASSYL  1010      0.445     1    NA    67    4.49 18914 20555
#>  3 SLOBER  110       0.666     1    NA   150    4.51 18897 20543
#>  4 SLOBER  1106      0         1    NA    50    4.56 18849 20516
#>  5 CECSCH  1114      1.79      1    NA   228    4.47 18948 20580
#>  6 PSYBRA  1318      0.447     1    NA    14    4.48 19011 20646
#>  7 HIRRUG  1403      1.66      1    NA    12.9  4.58 18834 20506
#>  8 CASSYL  1411     NA         0    NA    NA   NA       NA    NA
#>  9 SLOBER  1414      1.40      1    NA    16.6  4.57 18952 20622
#> 10 GUAGUI  1419     NA         0    NA    NA   NA       NA    NA
#> # ... with 530 more rows
```

### Species-habitat associations

``` r
tree <- fgeo.data::luquillo_tree5_random
elevation <- fgeo.data::luquillo_elevation
# Pick alive trees, of 10 mm or more
census <- filter(tree, status == "A", dbh >= 10)
# Pick sufficiently abundant species
pick <- filter(add_count(census, sp), n > 50)
species <- unique(pick$sp)
# Use your habitat data or create it from elevation data
habitat <- fgeo_habitat(elevation, gridsize = 20, n = 4)
# A list or matrices
tt_lst <- tt_test(census, species, habitat)
#> Using `plotdim = c(320, 500)`. To change this value see `?tt_test()`.
#> Using `gridsize = 20`. To change this value see `?tt_test()`.
tt_lst
#> [[1]]
#>        N.Hab.1 Gr.Hab.1 Ls.Hab.1 Eq.Hab.1 Rep.Agg.Neut.1 Obs.Quantile.1
#> CASARB      35     1508       90        2              0         0.9425
#>        N.Hab.2 Gr.Hab.2 Ls.Hab.2 Eq.Hab.2 Rep.Agg.Neut.2 Obs.Quantile.2
#> CASARB      24      433     1162        5              0       0.270625
#>        N.Hab.3 Gr.Hab.3 Ls.Hab.3 Eq.Hab.3 Rep.Agg.Neut.3 Obs.Quantile.3
#> CASARB      11      440     1157        3              0          0.275
#>        N.Hab.4 Gr.Hab.4 Ls.Hab.4 Eq.Hab.4 Rep.Agg.Neut.4 Obs.Quantile.4
#> CASARB       8      774      824        2              0        0.48375
#> 
#> [[2]]
#>        N.Hab.1 Gr.Hab.1 Ls.Hab.1 Eq.Hab.1 Rep.Agg.Neut.1 Obs.Quantile.1
#> PREMON      94     1511       87        2              0       0.944375
#>        N.Hab.2 Gr.Hab.2 Ls.Hab.2 Eq.Hab.2 Rep.Agg.Neut.2 Obs.Quantile.2
#> PREMON      97     1403      196        1              0       0.876875
#>        N.Hab.3 Gr.Hab.3 Ls.Hab.3 Eq.Hab.3 Rep.Agg.Neut.3 Obs.Quantile.3
#> PREMON      39      212     1386        2              0         0.1325
#>        N.Hab.4 Gr.Hab.4 Ls.Hab.4 Eq.Hab.4 Rep.Agg.Neut.4 Obs.Quantile.4
#> PREMON      15       64     1535        1              0           0.04
#> 
#> [[3]]
#>        N.Hab.1 Gr.Hab.1 Ls.Hab.1 Eq.Hab.1 Rep.Agg.Neut.1 Obs.Quantile.1
#> SLOBER      21      413     1183        4              0       0.258125
#>        N.Hab.2 Gr.Hab.2 Ls.Hab.2 Eq.Hab.2 Rep.Agg.Neut.2 Obs.Quantile.2
#> SLOBER      25      558     1040        2              0        0.34875
#>        N.Hab.3 Gr.Hab.3 Ls.Hab.3 Eq.Hab.3 Rep.Agg.Neut.3 Obs.Quantile.3
#> SLOBER      21     1289      309        2              0       0.805625
#>        N.Hab.4 Gr.Hab.4 Ls.Hab.4 Eq.Hab.4 Rep.Agg.Neut.4 Obs.Quantile.4
#> SLOBER       8      833      764        3              0       0.520625
# A simple summary to help you interpret the results
summary(tt_lst)
#>   Species Habitat_1 Habitat_2 Habitat_3 Habitat_4
#> 1  CASARB   neutral   neutral   neutral   neutral
#> 2  PREMON   neutral   neutral   neutral   neutral
#> 3  SLOBER   neutral   neutral   neutral   neutral
# A combined matrix
Reduce(rbind, tt_lst)
#>        N.Hab.1 Gr.Hab.1 Ls.Hab.1 Eq.Hab.1 Rep.Agg.Neut.1 Obs.Quantile.1
#> CASARB      35     1508       90        2              0       0.942500
#> PREMON      94     1511       87        2              0       0.944375
#> SLOBER      21      413     1183        4              0       0.258125
#>        N.Hab.2 Gr.Hab.2 Ls.Hab.2 Eq.Hab.2 Rep.Agg.Neut.2 Obs.Quantile.2
#> CASARB      24      433     1162        5              0       0.270625
#> PREMON      97     1403      196        1              0       0.876875
#> SLOBER      25      558     1040        2              0       0.348750
#>        N.Hab.3 Gr.Hab.3 Ls.Hab.3 Eq.Hab.3 Rep.Agg.Neut.3 Obs.Quantile.3
#> CASARB      11      440     1157        3              0       0.275000
#> PREMON      39      212     1386        2              0       0.132500
#> SLOBER      21     1289      309        2              0       0.805625
#>        N.Hab.4 Gr.Hab.4 Ls.Hab.4 Eq.Hab.4 Rep.Agg.Neut.4 Obs.Quantile.4
#> CASARB       8      774      824        2              0       0.483750
#> PREMON      15       64     1535        1              0       0.040000
#> SLOBER       8      833      764        3              0       0.520625
# A dataframe
to_df(tt_lst)
#> # A tibble: 12 x 8
#>    habitat sp     N.Hab Gr.Hab Ls.Hab Eq.Hab Rep.Agg.Neut Obs.Quantile
#>  * <chr>   <chr>  <dbl>  <dbl>  <dbl>  <dbl>        <dbl>        <dbl>
#>  1 1       CASARB    35   1508     90      2            0        0.942
#>  2 2       CASARB    24    433   1162      5            0        0.271
#>  3 3       CASARB    11    440   1157      3            0        0.275
#>  4 4       CASARB     8    774    824      2            0        0.484
#>  5 1       PREMON    94   1511     87      2            0        0.944
#>  6 2       PREMON    97   1403    196      1            0        0.877
#>  7 3       PREMON    39    212   1386      2            0        0.132
#>  8 4       PREMON    15     64   1535      1            0        0.04 
#>  9 1       SLOBER    21    413   1183      4            0        0.258
#> 10 2       SLOBER    25    558   1040      2            0        0.349
#> 11 3       SLOBER    21   1289    309      2            0        0.806
#> 12 4       SLOBER     8    833    764      3            0        0.521
```

[Get started with
**fgeo**](https://forestgeo.github.io/fgeo/articles/fgeo.html)

## Information

EDIT: Run this chunk then delete it: TODO: Move files to .github/ but
refer to (FILE.md), not (.github/FILE.md)

    usethis::use_template("SUPPORT.md", package = "fgeo.template")
    usethis::use_template("CONTRIBUTING.md", package = "fgeo.template")
    usethis::use_template("CODE_OF_CONDUCT.md", package = "fgeo.template")
    usethis::use_template("ISSUE_TEMPLATE.md", package = "fgeo.template")

  - [Getting help](SUPPORT.md).
  - [Contributing](CONTRIBUTING.md).
  - [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

## READ AND DELETE THIS SECTION

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date.

You can also embed plots, for example:

![](man/figures/README-pressure-1.png)<!-- -->

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub\!
