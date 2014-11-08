# Regular Expressions in R

### grep
If we set the argument `value = TRUE`, `grep()` returns the matches, while `value = FALSE` returns their indices. The `invert` argument let's you get everything BUT the pattern you specify. `grepl()` is a similar function but returns a logical vector.


```r
strings <- c("one", "onetwo", "two", "one's")
grep("two", strings, value = TRUE)
```

```
## [1] "onetwo" "two"
```

```r
grep("two", strings, value = FALSE)
```

```
## [1] 2 3
```

```r
grep("two", strings, invert = TRUE, value = TRUE)
```

```
## [1] "one"   "one's"
```

```r
grepl("two", strings)
```

```
## [1] FALSE  TRUE  TRUE FALSE
```

## String functions related to regular expression
Regular expression is a pattern that describes a specific set of strings with a common structure. It is heavily used for string matching / replacing in all programming languages, although specific syntax may differ a bit. It is truly the heart and soul for string operations. In R, many string functions in `base` R as well as in `stringr` package use regular expressions, even Rstudio's search and replace allows regular expression, we will go into more details about these functions later this week:       

* identify match to a pattern: `grep(..., value = FALSE)`, `grepl()`, `stringr::str_detect()`
* extract match to a pattern: `grep(..., value = TRUE)`, `stringr::str_extract()`, `stringr::str_extract_all()`     
* locate pattern within a string, i.e. give the start position of matched patterns. `regexpr()`, `gregexpr()`, `stringr::str_locate()`, `string::str_locate_all()`     
* replace a pattern: `sub()`, `gsub()`, `stringr::str_replace()`, `stringr::str_replace_all()`     
* split a string using a pattern: `strsplit()`, `stringr::str_split()`     

## Regular expression syntax 

Regular expressions typically specify characters (or character classes) to seek out, possibly with information about repeats and location within the string. This is accomplished with the help of metacharacters that have specific meaning: `$ * + . ? [ ] ^ { } | ( ) \`. We will use some small examples to introduce regular expression syntax and what these metacharacters mean. 

### Escape sequences

There are some special characters in R that cannot be directly coded in a string. For example, let's say you specify your pattern with single quotes and you want to find strings with the single quote `'`. You would have to "escape" the single quote in the pattern, by preceding it with `\`, so it's clear it is not part of the string-specifying machinery: 


```r
grep('\'', strings, value = TRUE)
```

```
## [1] "one's"
```

There are other characters in R that require escaping, and this rule applies to all string functions in R, including regular expressions. See [here](https://stat.ethz.ch/R-manual/R-devel/library/base/html/Quotes.html) for a complete list of R esacpe sequences.        

* `\'`: single quote. You don't need to escape single quote inside a double-quoted string, so we can also use `"'"` in the previous example.        
* `\"`: double quote. Similarly, double quotes can be used inside a single-quoted string, i.e. `'"'`.          
* `\n`: newline.   
* `\r`: carriage return.   
* `\t`: tab character.   

> Note: `cat()` and `print()` to handle escape sequences differently, if you want to print a string out with these sequences interpreted, use `cat()`.      


```r
print("a\nb")
```

```
## [1] "a\nb"
```

```r
cat("a\nb")
```

```
## a
## b
```

### Quantifiers

Quantifiers specify how many repetitions of the pattern.   

* `*`: matches at least 0 times.   
* `+`: matches at least 1 times.     
* `?`: matches at most 1 times.    
* `{n}`: matches exactly n times.    
* `{n,}`: matches at least n times.    
* `{n,m}`: matches between n and m times.     


```r
(strings <- c("a", "ab", "acb", "accb", "acccb", "accccb"))
```

```
## [1] "a"      "ab"     "acb"    "accb"   "acccb"  "accccb"
```

```r
grep("ac*b", strings, value = TRUE)
```

```
## [1] "ab"     "acb"    "accb"   "acccb"  "accccb"
```

```r
grep("ac+b", strings, value = TRUE)
```

```
## [1] "acb"    "accb"   "acccb"  "accccb"
```

```r
grep("ac?b", strings, value = TRUE)
```

```
## [1] "ab"  "acb"
```

```r
grep("ac{2}b", strings, value = TRUE)
```

```
## [1] "accb"
```

```r
grep("ac{2,}b", strings, value = TRUE)
```

```
## [1] "accb"   "acccb"  "accccb"
```

```r
grep("ac{2,3}b", strings, value = TRUE)
```

```
## [1] "accb"  "acccb"
```

### Position of pattern within the string 

* `^`: matches the start of the string.   
* `$`: matches the end of the string.   
* `\b`: matches the empty string at either edge of a _word_. Don't confuse it with `^ $` which marks the edge of a _string_.   
* `\B`: matches the empty string provided it is not at an edge of a word.    


```r
(strings <- c("abcd", "cdab", "cabd", "c abd"))
```

```
## [1] "abcd"  "cdab"  "cabd"  "c abd"
```

```r
grep("ab", strings, value = TRUE)
```

```
## [1] "abcd"  "cdab"  "cabd"  "c abd"
```

```r
grep("^ab", strings, value = TRUE)
```

```
## [1] "abcd"
```

```r
grep("ab$", strings, value = TRUE)
```

```
## [1] "cdab"
```

```r
grep("\\bab", strings, value = TRUE)
```

```
## [1] "abcd"  "c abd"
```

### Operators

* `.`: matches any single character, as shown in the first example. 
* `[...]`: a character list, matches any one of the characters inside the square brackets. We can also use `-` inside the brackets to specify a range of characters.   
* `[^...]`: an inverted character list, similar to `[...]`, but matches any characters __except__ those inside the square brackets.  
* `\`: suppress the special meaning of metacharacters in regular expression, i.e. `$ * + . ? [ ] ^ { } | ( ) \`, similar to its usage in escape sequences. Since `\` itself needs to be escaped in R, we need to escape these metacharacters with double backslash like `\\$`.   
* `|`: an "or" operator, matches patterns on either side of the `|`.  
* `(...)`: grouping in regular expressions. This allows you to retrieve the bits that matched various parts of your regular expression so you can alter them or use them for building up a new string. Each group can than be refer using `\\N`, with N being the No. of `(...)` used. This is called __backreference__.    


```r
(strings <- c("^ab", "ab", "abc", "abd", "abe", "ab 12"))
```

```
## [1] "^ab"   "ab"    "abc"   "abd"   "abe"   "ab 12"
```

```r
grep("ab.", strings, value = TRUE)
```

```
## [1] "abc"   "abd"   "abe"   "ab 12"
```

```r
grep("ab[c-e]", strings, value = TRUE)
```

```
## [1] "abc" "abd" "abe"
```

```r
grep("ab[^c]", strings, value = TRUE)
```

```
## [1] "abd"   "abe"   "ab 12"
```

```r
grep("^ab", strings, value = TRUE)
```

```
## [1] "ab"    "abc"   "abd"   "abe"   "ab 12"
```

```r
grep("\\^ab", strings, value = TRUE)
```

```
## [1] "^ab"
```

```r
grep("abc|abd", strings, value = TRUE)
```

```
## [1] "abc" "abd"
```

```r
gsub("(ab) 12", "\\1 34", strings)
```

```
## [1] "^ab"   "ab"    "abc"   "abd"   "abe"   "ab 34"
```

### Character classes

Character classes allows to -- surprise! -- specify entire classes of characters, such as numbers, letters, etc. There are two flavors of character classes, one uses `[:` and `:]` around a predefined name inside square brackets and the other uses `\` and a special character. They are sometimes interchangeable.   

* `[:digit:]` or `\d`: digits, 0 1 2 3 4 5 6 7 8 9, equivalent to `[0-9]`.  
* `\D`: non-digits, equivalent to `[^0-9]`.  
* `[:lower:]`: lower-case letters, equivalent to `[a-z]`.  
* `[:upper:]`: upper-case letters, equivalent to `[A-Z]`.  
* `[:alpha:]`: alphabetic characters, equivalent to `[[:lower:][:upper:]]` or `[A-z]`.  
* `[:alnum:]`: alphanumeric characters, equivalent to `[[:alpha:][:digit:]]` or `[A-z0-9]`.   
* `\w`: word characters, equivalent to `[[:alnum:]_]` or `[A-z0-9_]`.  
* `\W`: not word, equivalent to `[^A-z0-9_]`.  
* `[:xdigit:]`: hexadecimal digits (base 16), 0 1 2 3 4 5 6 7 8 9 A B C D E F a b c d e f, equivalent to `[0-9A-Fa-f]`.
* `[:blank:]`: blank characters, i.e. space and tab.  
* `[:space:]`: space characters: tab, newline, vertical tab, form feed, carriage return, space.
* `\s`: space, ` `.  
* `\S`: not space.  
* `[:punct:]`: punctuation characters, ! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ ` { | } ~.
* `[:graph:]`: graphical (human readable) characters: equivalent to `[[:alnum:][:punct:]]`.
* `[:print:]`: printable characters, equivalent to `[[:alnum:][:punct:]\\s]`.
* `[:cntrl:]`: control characters, like `\n` or `\r`, `[\x00-\x1F\x7F]`.  

Note:       

* `[:...:]` has to be used inside square brackets, e.g. `[[:digit:]]`.     
* `\` itself is a special character that needs escape, e.g. `\\d`. Do not confuse these regular expressions with R escape sequences such as `\t`.      

## General modes for patterns

There are different [syntax standards](http://en.wikipedia.org/wiki/Regular_expression#Standards) for regular expressions, and R offers two:

* POSIX extended regular expressions (default)
* Perl-like regular expressions.

You can easily switch between by specifying `perl = FALSE/TRUE` in `base` R functions, such as `grep()` and `sub()`. For functions in the `stringr` package, wrap the pattern with `perl()`. The syntax between these two standards are a bit different sometimes, see an example [here](http://www.inside-r.org/packages/cran/stringr/docs/perl). If you had previous experience with Python or Java, you are probably more familiar with the Perl-like mode. But for this tutorial, we will only use R's default POSIX standard.  

There's one last type of regular expression -- "fixed", meaning that the pattern should be taken literally. Specify this via `fixed = TRUE` (base R functions) or wrapping with `fixed()` (`stringr` functions). For example, `"A.b"` as a regular expression will match a string with "A" followed by any single character followed by "b", but as a fixed pattern, it will only match a literal "A.b".  


```r
(strings <- c("Axbc", "A.bc"))
```

```
## [1] "Axbc" "A.bc"
```

```r
pattern <- "A.b"
grep(pattern, strings, value = TRUE)
```

```
## [1] "Axbc" "A.bc"
```

```r
grep(pattern, strings, value = TRUE, fixed = TRUE)
```

```
## [1] "A.bc"
```

By default, pattern matching is case sensitive in R, but you can turn it off with `ignore.case = TRUE` (base R functions) or wrapping with `ignore.case()` (`stringr` functions). Alternatively, you can use `tolower()` and `toupper()` functions to convert everything to lower or upper case. Take the same example above: 


```r
pattern <- "a.b"
grep(pattern, strings, value = TRUE)
```

```
## character(0)
```

```r
grep(pattern, strings, value = TRUE, ignore.case = TRUE)
```

```
## [1] "Axbc" "A.bc"
```

### Some more advanced string functions     

There are some more advanced string functions that are somewhat related to regular expression, like splitting a string, get a subset of a string, pasting strings together etc. These functions are very useful for data cleaning, and we will get into more details about them later this week. Here is a short introduction.   

We can use `strsplit()` function to split a string into several words. The second argument `strsplit` is a regular expression used for splitting, and the function will return a list. We can use `unlist()` function to convert the list into a character vector. Or an alternative function `str_split_fixed()` will return a data frame.   



```r
library(stringr)
```

```
## Warning: package 'stringr' was built under R version 3.1.2
```

```r
strings <- "one-two-three"
(topic_split <- unlist(strsplit(strings, "-")))
```

```
## [1] "one"   "two"   "three"
```

```r
(topic_split <- str_split_fixed(strings, "-", 3)[1, ])
```

```
## [1] "one"   "two"   "three"
```

We can use `paste()` or `paste0()` functions to put them back together. `paste0()` function is equivalent to `paste()` with `sep = ""`. We can use `collapse = "-"` argument to concatenate a character vector into a string:        


```r
paste(topic_split, collapse = "-")
```

```
## [1] "one-two-three"
```

Another useful function is `substr()`:     


```r
substr(strings, 1, 3)
```

```
## [1] "one"
```

## Regular expression vs shell globbing

The term globbing in shell or Unix-like environment refers to pattern matching based on wildcard characters. A wildcard character can be used to substitute for any other character or characters in a string. Globbing is commonly used for matching file names or paths, and has a much simpler syntax. It is somewhat similar to regular expressions, and that's why people are often confused between them. Here is a list of globbing syntax and their comparisons to regular expression:   

  * `*`: matches any number of unknown characters, same as `.*` in regular expression.  
  * `?`: matches one unknown character, same as `.` in regular expression.  
  * `\`: same as regular expression.  
  * `[...]`: same as regular expression.  
  * `[!...]`: same as `[^...]` in regular expression.   

## Resources

  * Regular expression in R [official document](https://stat.ethz.ch/R-manual/R-devel/library/base/html/regex.html).  
  * Perl-like regular expression: regular expression in perl [manual](http://perldoc.perl.org/perlre.html#Regular-Expressions).   
  * [`qdapRegex` package](http://trinkerrstuff.wordpress.com/2014/09/27/canned-regular-expressions-qdapregex-0-1-2-on-cran/): a collection of handy regular expression tools, including handling abbreviations, dates, email addresses, hash tags, phone numbers, times, emoticons, and URL etc.   
  * Recently, there are some attemps to create human readable regular expression packages, [Regularity](https://github.com/andrewberls/regularity) in Ruby is a very successful one. Unfortunately, its implementation in R is still quite beta at this stage, not as friendly as Regularity yet. But keep an eye out, better packages may become available in the near future!    
  * There are some online tools to help learn, build and test regular expressions. On these websites, you can simply paste your test data and write regular expression, and matches will be highlighted.   
  + [regexpal](http://regexpal.com/)    
  + [RegExr](http://www.regexr.com/)   
