---
title: "Write your own R package"
author: "Bernhard Konrad, Jennifer Bryan"
output:
  html_document:
    toc: true
    toc_depth: 4
---

### Overview

This is a step-by-step instruction on how to create your first R package.

In this tutorial we will develop a package *gameday* that provides the function `gday()`. This function takes one argument `team.name`, the name of your favorite [NHL](http://www.nhl.com/) team, and returns `TRUE` if this team has a game today, and `FALSE` otherwise. The function will actually be a one-liner because we can read this information from the web.

### Setting up the directory = RStudio project = R package = Git repo

R expects a certain folder structure for your package. Luckily, the package `devtools` does this work for us.
```
    library("devtools")
    create("~/gameday")
```
This creates a folder *gameday*, and populates it with several of files. Navigate to this folder and open `gameday.Rproj` with *RStudio*.

Before we talk about the files and folders that were created, let's put this under version control: *Tools > Version Control > Project Setup*. Then choose *Version control system: Git* and *initialize a new git repository for this project*. Then restart RStudio in this Project. (or use `git init` or use *SourceTree* New Repository)

Now, let's talk about the contents of our *gameday* directory.

### Files that R expects in a package

* Helper files that we don't have to worry about now:
    + `.gitignore` The usual ignore file for Git. We don't have to change it.
    + `.Rbuildignore` An ignore file for the R package building process. We can talk about this later.
    + `.Rhistory` The usual history file of your R session. We don't have to change it.
    + `gameday.Rproj` The usual file for an RStudio project. We don't have to change it.
    + `NAMESPACE` A very important file, but we will never edit this by hand. `roxygen2` will maintain this for us.

* `R/` finally, this is where the actual R code will go.
* `DESCRIPTION` holds meta information about your package. We will modify this first. (Technically, the presence of this very file signals to RStudio that the `gameday` Project is a package.)


### The DESCRIPTION File

Here is where we add information about the package (gameday) and its authors (us). Some fields are pre-filled, but many more fields can be added as necessary. The initial raw version may depend on your version of `devtools` but should look similar to this:
```
    Package: gameday
    Title: What the package does (one line)
    Version: 0.1
    Authors@R: "First last <first.last@example.com> [aut, cre]"
    Description: What the package does (one paragraph)
    Depends: R (>= 3.1.2)
    License: What license is it under?
    LazyData: true
```
Let's look at those in detail. **Bold** fields are mandatory:

+ **Package**. The name of the package. We will leave this as *gameday*.
+ **Title**. A one-line description of what the package does. Capitalize principal words, stick to a single line, don't use markup and do not end in a period.
+ **Version**. Convention has it that this should be in the format `<major>.<minor>.<patch>`. Since we are only in development we start a fourth digit, which, also by convention, starts with `9000`. Hence `0.0.0.9000` is a good starting point, and `0.0.0.9001` would be the next (development) version while `0.1.0` or `1.0.0` would be the first release version.
+ **Authors\@R**. Machine-readable description of the authors (`aut`), maintainer (`cre`), contributors (`ctb`) and others (see `?person`).
+ **Description**. One paragraph of what the packages does. Lines of 80 characters or less. Indent subsequent lines with 4 spaces (if you're lucky some of this formatting will be done automatically for you later, but don't count on this).
+ **License**. Who can use this package and for what? I suggest [*CC0*](http://creativecommons.org/publicdomain/zero/1.0/), which means that we dedicate our package to the public domain and waive all of our rights. Anyone can freely use/adapt/modify/sell this work without our permission. We also don't provide any warranties about liability or correctness. You can check out [other licenses](http://choosealicense.com/).
+ *LazyData*. Is a little technical, but setting this to `true` makes your package a better citizen with respect to memory.
+ There are [many more fields available](http://cran.r-project.org/doc/manuals/r-release/R-exts.html#The-DESCRIPTION-file).


Hence, a reasonable version of `DESCRIPTION` after editing would be
```
    Package: gameday
    Title: Let R tell you if your NHL team plays today
    Version: 0.0.0.9000
    Authors@R: as.person(c(
        "Bernhard Konrad <bernhard.konrad@gmail.com> [aut, cre]", 
        "Jennifer Bryan <jenny@stat.ubc.ca> [aut]"
        ))
    Description: Query live.nhle.com to check if your NHL team is listed on
        the teams that play today
    Depends: R (>= 3.1.2)
    License: CC0
    LazyData: true
```

### The actual R code

The R code that our package provides is in the *R* folder. So let's **create a new R script** and save it in the *R* folder with the name `gday.R`.

The content is the following:
```
    gday <- function(team.name="canucks") {
      url <- paste0("http://live.nhle.com/GameData/GCScoreboard/", Sys.Date(), ".jsonp")
      grepl(team.name, getURL(url), ignore.case=TRUE)
    }
```
We first construct the url where the data for today's matches is stored, and then `grepl` to check if `team.name` is among them. [See how the data file looks like](http://live.nhle.com/GameData/GCScoreboard/2014-11-09.jsonp) and compare with [today's matches on NHL.com](http://www.nhl.com/).

#### Import required packages
Notice that we use `RCurl::getURL`, which we have to add to our list of *dependencies* in `DESCRIPTION`, i.e.
```
    Depends: R (>= 3.1.2)
```
becomes
```
    Depends:
        R (>= 3.1.2),
        RCurl
```
However, including it under `Depends` will cause the package to be loaded to the user, which means the user will be able to call `RCurl` functions without explicitly loading the pacakge. Instead, we should use `Imports: RCurl`, which is almost the same as `Depends`. It will also load `RCurl` for our package, but with `Imports` the user will not be able to call `RCurl` functions without loading the pacage.

> Unless there is a good reason otherwise, you should alway list packages in Imports not Depends.  That’s because a good package is self-contained, and minimises changes to the global environment (including the search path). There are a few exceptions... (Hadley Wickham)

+ In `DESCRIPTION`:
```
        Depends: R (>= 3.1.2)
        Imports: RCurl
```
+ In `R/gday.R`
```
        #' @importFrom RCurl getURL
```

#### Documentation

So far so good. But what about [documentation](http://asset-1.soup.io/asset/1524/9224_10db.jpeg) (what you would see with `?gday`)? Luckily, `roxygen2` helps us with that and allows us to add the documentation as comments directly in the *R* script. All we have to do is start the line with `#' ` and use the `\@` notation like so:
```
    #' Is it Gameday?
    #'
    #' This function returns TRUE if your NHL team plays today
    #' and FALSE otherwise
    #' 
    #' You know then problem: You're in your office writing R code and
    #' suddenly have the urge to check whether your NHL team has a game today.
    #' Before you know it you just wasted 15 minutes browsing the lastest
    #' news on your favorite hockey webpage.
    #' Suffer no more! You can now ask R directly, without tempting yourself
    #' by firing up your web browser.
    #' 
    #' @param team.name
    #' @return \code{TRUE} if \code{team.name} has an NHL game on \code{date},
    #' \code{FALSE} otherwise
    #' @keywords misc
    #' @note case in \code{team.name} is ignored
    #' @export
    #' @examples
    #' gday("canucks")
    #' gday("Bruins")
```
A few of those tags need explanation

+ `\@keywords` must be taken from the [list of R keywords](https://svn.r-project.org/R/trunk/doc/KEYWORDS)
+ `\@export` makes the function `gday` available when the package is loaded, in contrast to a helper function that is only designed for internal use within the package.
+ There are [many more tags and explanations](http://r-pkgs.had.co.nz/man.html) if you want to learn more.


### Let devtools, roxygen2 compile the documenation for you

Phew, that was a lot of work, but now we can hand the rest over back to *R*. In particular, `devtools` and `roxygen2` will compile the documentation
```
    library("devtools")
    document()
```
When we run this the first time, the new folder `man` is created with the file `gday.Rd`. Go ahead an open it, this is what we would have had to write if it was not for `roxygen2` (the syntax resembles the markup language [LaTeX](http://en.wikipedia.org/wiki/LaTeX)).

Also observe that we now have a file `NAMESPACE` which, as expected, says that the package `gameday` provides the function `gday`.

### Build the package

As a final step, let's build the package. In *RStudio* use the *Build* tab and choose *Build & Reload*. That's it. Your package is now checked, installed and loaded. Your *R* session is also restarted. You are now able to run
```
    gday("canucks")
    gday("flames")
```

and will notice that (on 2014-11-10) the Vancouver Canucks are not playing, but the Calgary Flames do have a game. To see the rendered version of our function documentation, use
```
    ?gday
```

As you update the package, frequently run `document()` and then *Build & Reload* to test your latest version.

Congratulations, you just wrote your first *R* package!

### Documentation for the package itself

We now have a documentation for the `gday` function. Next, let's add a minimal documentation of the `gameday` package itself (what you would see with `?gameday`). For that, open a *New R script* and save it as *R/gameday.r*. The content should be something like
```
    #' My first R package: gameday
    #' 
    #' A one-line sentence on what this packages does
    #' 
    #' Single paragraph with more detail on the package.
    #' This can span several lines.
    #' 
    #' @docType package
    #' @name gameday
    NULL
```

+ `\@docType package` specifies that we document the package itself (instead of a function)
+ We don't have any *R* code to document here, but `roxygen2` needs some *R* code here. Hence the convention is to put the dummy code `NULL`.

### Vignette

Vignettes allow you to give a broader overview of your package, and show new users what it can be used for and how to use it. Vignettes tell the story of your package. The good news is that, as of *R 3.0.0* you can use *Rmarkdown* to write your vignettes (previously *LaTeX* was required). It gets better: `devtools` provides a template for your vignette, to make the process of writing this user-friendly guide as easy as possible:

+ In your package, call `library(devtools)` and then `use_vignette("overview")`. This creates `vignettes/overview.Rmd` and adds
```
        Suggests: knitr
        VignetteBuilder: knitr
```
to your `DESCRIPTION` file.
+ Open `vignettes/overview.Rmd` and check the YAML:
```
        ---
        title: "Vignette Title"
        author: "Vignette Author"
        date: "`r Sys.Date()`"
        output: rmarkdown::html_vignette
        vignette: >
          %\VignetteIndexEntry{Vignette Title}
          %\VignetteEngine{knitr::rmarkdown}
          \usepackage[utf8]{inputenc}
        ---
```        
    * Please change the *title* and *author*, as well as the *Vignette Title*. Don't be confused about *vignette: >*, this just means that the following LaTeX lines are read as-is instead of being interpreted as YAML. After your changes, `vignettes/overview.Rmd` YAML should look similar to this:
```    
        ---
        title: "Gameday Overview"
        author: "Bernhard Konrad"
        date: "`r Sys.Date()`"
        output: rmarkdown::html_vignette
        vignette: >
          %\VignetteIndexEntry{Gameday Overview}
          %\VignetteEngine{knitr::rmarkdown}
          %\usepackage[utf8]{inputenc}
        ---
```
* Now we can add the actual *Rmarkdown* of our vignette. This should show realistic usage -- usually something beyond the scope of the examples typically found in a help file. In packages that are more sophisticated than `gameday`, it's fair to say that a vignette is where you show how to combine several functions from your package to accomplish something interesting to your audience. 
* Once you have your vignette in an acceptable state it is time to turn the *Rmarkdown* source into the vignette as the R package expects it. Since vignettes may take a long time to complile, this is **not** automatically done by *Build & Reload*. Instead, use `devtools:build_vignettes()`. This puts all required files in the folder `inst/doc`.
* You can now *Build & Reload* your package, it will also make the vignette available. To view it, simply use `browseVignettes(package="gameday")`.

### Publish on GitHub

#### Commit locally

First we have to commit all our files to our local git repository. If you don't have a *Git* tab in *RStudio*, go to *Tools -> Version Control -> Project Setup* and choose *Git*. This will restart *RStudio*. Then, go to the *Git* tab, check all files and folders, click *commit*, add a *commit message* (eg "my first version of my first R package") and *commit*.

#### Create new, empty GitHub repository

We will now make our package publicly available on GitHub. If we want others to see and use our work we have to make this repository public.

1. Go to `github.com` and click on your username (should be on the top right).
2. Choose *Repositories -> New*
3. The repository name is *gameday*. You can leave *Description* empty. Choose **Public** and **do NOT initialize with a README**.
4. Copy the address of the repository. For me this is `https://github.com/daattali/gameday`.

#### Connect the git repository to GitHub

We have to tell *RStudio* where to put the files of our new package. For this, we have to briefly default back to the *Shell*:  
`git remote add origin https://github.com/daattali/gameday`.  
(or in *SourceTree* Repository -> Repository Settings -> Remotes -> Add)

#### Push to github
After you commit and push the contents of the package (repository), it is now freely available to the public on Github.  
**It gets better**: You can actually install your package from GitHub directly:  

        install_github("daattali/gameday")


### Tests

We all feel that we should be testing our code. In fact, most of us are, but not in an effective and efficient way:

> It's not that we don't test our code, it's that we don't store our tests so they can be re-run automatically. (Hadley Wickham)

We are used to inspecting our code interactively and smell-test our data. Formal testing, however, is regarded as very advanced and *"not worth it"* for the daily work. Turns out, a simple test suit like [`testthat`](http://vita.had.co.nz/papers/testthat.html) doesn't only make testing very easy, but will also make you spend less time fixing bugs and more time writing code.

We will use `testthat` to add tests to our package. It's syntax is designed to be very close to english:
```
    # save as test_me.R
    test_that("case is ignored", {
    expect_equal(gday("canucks"), gday("CANUCKS"))
    })
```
+ Save the script above as `test_me.R`.
+ The first argument is a string that explains what we are testing for. It completes the sentence *"Test that..."*
+ The second argument is a (list of) test(s), that is, a check that has to be satisfied. Above we use `expect_equal`, to check that both arguments `gday("canucks")` and `gday("CANUCKS")` give the same answer. There are more things we can test for:
    * `expect_true(x)`
    * `expect_false(x)`
    * `expect_is(x, y)` Is `x` of class `y`?
    * `expect_equal(x, y)`
    * `expect_equivalent(x, y)`
    * `expect_identical(x, y)`
    * `expect_matches(x, y)` Match character vector `x` against regular expression `y`.
    * `expect_output(x, y)` Match output of running `x` against regular expression `y`.
    * `expect_message(x, y)`
    * `expect_warning(x, y)` Match warning against regular expression `y`.
    * `expect_error(x, y)` Match error against regular expression `y`.
+ To run the test you can
    * `source` the corresponding *R* file,
    * run `test_file("testMe.R")`
    * run `test_dir(".")`
    * run `auto_test(code_path="./R", test_path=".")`
    * run `devtools:check()`
    
When you add tests to your package it makes sense to think about a folder structure for where to put the tests. Luckily, `devtools` also has a function for that:

+ `devtools::use_testthat()`

This sets up a handy test structure in the folder `tests` by adding the folder `tests/testthat/` (where our tests will go) as well as the *master file* `tests/testthat.R`:

    library(testthat)
    library(gameday)
    
    test_check("gameday")

It also adds `testthat` to the `Suggests` in our `DESCRIPTION`.

What is there to test about `gday()`? Since it relies on live data it is a little more challenging to write an informative test, but some useful tests are below. To begin with, we copy our test that checks the case to the new `tests/testthat/` folder. Other reasonable tests are:
```
    # save as tests/testthat/test_me.R
    test_that("case is ignored", {
      expect_equal(gday("canucks"), gday("CANUCKS"))
    })
    
    test_that("always returns logical", {
      expect_is(gday("canucks"), "logical")
    })
    
    test_that("asking for the city works just as well", {
      expect_equal(gday("canucks"), gday("Vancouver"))
    })
    
    test_that("Seattle does not have a NHL team", {
      expect_false(gday(team.name="Seattle"))
    }
```

Looks good, let's run the tests! What are our options:

+ *Build & Reload*  (`R CMD INSTALL ../gameday`) does **not** run the tests.
+ *Load All* (`devtools:load_all()`) does **not** run the tests.
+ *Test package* (`devtools::test()`) runs the tests.
+ *Check* (`devtools::check()`) runs the tests (also updates vignette, documentation, etc).
+ `devtools::auto_check('./R', './tests')` runs all the tests continuous.

Once these tests work, we can bump our package to version `0.1.0` and push it all to Github :)

