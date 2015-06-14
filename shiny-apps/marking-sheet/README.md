# Marking sheet

A simple marking sheet, where students can mark their peer's assignment 
on several metrics and give comments.

The app is currently deployed [on my personal shiny server](http://daattali.com/shiny/peer-review/) for testing.

If you log in as an admin, you can see all the students' submissions. Since my shiny server doesn't have authentication, you are assumed to be an admin.

How to reset the app for a new assignment:

  * Keep class list in `data/XXXXX.csv` up-to-date
    - It is loaded by helper function `getClassList()` in `helpers.R`.
  * Change the default assignment selected in the drop-down menu
