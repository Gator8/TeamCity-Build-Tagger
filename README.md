# TeamCity-Build-Tagger

One of the more useful features of TeamCity is the ability to tag a build with just about anything you like. TeamCity then allows you to filter builds by the tags associated with those builds. The one downside to TeamCity is that there is no automatic way to tag a build at the end of the run.

TeamCity does however have a rich set of REST commands that you can use to craft such a feature.

When added as a build step, this powershell script uses the TeamCity REST api to grab the lit of changes associated with the running build and then parse through the list to find Jira ticket numbers embedded in the comments. The ticket numbers are then converted into individual TeamCity tags

To use this script, you will first need to edit the script and replace <b>USER</b> and <b>PASSWORD</b> with credentials to login to TeamCity.<p>
  Then, place the file on your agent machine in <b>c:\temp</b>. You can put it anywhere you want really, but you will have to make adjustments in the next step.<p>
Lastly, you will need to create a Powershell build step in your config. In the "Script file" box, point it to the lcoation of the script on the agent machine - relative to the checkout directory. Then Expand the Script arguments section and add: <b>%teamcity.build.id%</b> and <b>%teamcity.serverUrl%</b><p>
Save the step and run your build!

