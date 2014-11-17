# Homework 10 

Building my very own package called `rsalad`.

The package is [available on GitHub](https://github.com/daattali/rsalad) and all its documentation is there.

#### Questions
Some open questions raised by creating the package that I couldn't figure out after a few days:  

- How does `dplyr::n` work? I can't call it using `dplyr::n`, it says it can't be called directly. My problem was that I wasn't interested in "calling it directly", I wanted to use it inside a `summarise`, but I just want to be able to namespace it, but it wouldn't let me do it.
- How can I do unit testing on ggplot2 functions?
- Adding version information in DESCRIPTION file package dependencies: devtools functions and Hadley himself don't seem to add the version in Imports/Depends/Suggests. Why not do it by default? I would think that it's much safer to include >= version rather than just saying a package name, as I can only see the pros and no cons to it.
- When running check(), I get one warning, but that warning happens even when I create a brand new package with just one function in it. Why is this warning coming up and how do I fix it?

```
* checking Rd cross-references ... WARNING
Error in find.package(package, lib.loc) : 
  there is no package called 'cluster'
Calls: <Anonymous> -> lapply -> FUN -> find.package
Execution halted
```

- I dont' understand the `lazyeval` package.  I don't really understand how to work with ... and what substitute/quote/enquote/lazyeval:: do. I was able to grasp the basic concept enough to implement functions with both a standard evaluation and a non-standard evaluation versions, but I don't fully understand it. I wanted to use dplyr::mutate and dplyr::rename on column names that are a variable. Something like this:  
newName <- "newname"; df %>% rename\_(newName = oldCol)  
But I just couldn't find a way to do that.  
Or another example:  
df %>%
	dplyr::group\_by\_(col) %>%
	dplyr::summarise(total = length(unique((col2))))