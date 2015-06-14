# Form submission via Shiny

Very basic form submission functionality, designed in a few hours to quickly
and easily ask students in our class for some basic information.

After a successful submission, the contents of the form are saved to a csv file with the timestamp, user name, and form contents.  

Every submission is its own csv file, so when we want to see all the results for a particular form, we need to have a (very simple) script concatenate all the csv files together or use the Download button.

The app is currently deployed [on my personal shiny server](http://daattali.com/shiny/request-basic-info/) for testing.

Admins can see all the previously submitted responses and download them. When the app was given to students, it was hosted on a Shiny Server Pro that allowed authentication, and only if the logged in user was a course staff member then they would see the admin panel. Since my shiny server is the free version (as opposed to the Pro version), it does not support authentication, so for illustration purposes everyone is assumed to be an admin.
