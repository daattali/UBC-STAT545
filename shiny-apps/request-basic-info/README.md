# Form submission via Shiny

Very basic form submission functionality, designed in a few hours to quickly
and easily ask students in our class for some basic information.

After a successful submission, the contents of the form are saved to a csv file with the timestamp, user name, and form contents.  

Every submission is its own csv file, so when we want to see all the results for a particular form, we need to have a (very simple) script concatenate all the csv files together or use the Download button.

The app is currently deployed at [https://daattali.shinyapps.io/request-basic-info/](https://daattali.shinyapps.io/request-basic-info/) for testing.

Admins can see all the previously submitted responses and download them.

The app hosted on `shinyapps` is a demo, so it doesn't ask for a login and instead
gives everyone admin access.  Also, since it's on shinyapps, there is no long-term
data persistance, so new submissions cannot be guaranteed to be kept for long.  
There are two "test" submissions that will always show up.
