glassfish-bonita
================

A script to build a glassfish version of the Bonita tools.

Actions taken as part of the build;
- Merge the wars that include the REST API with the engine and the user experience without the engine or the
  client into a single war file
- Start with the web.xml from the user experience and then add the components from the REST war but change the url
  patterns to use a /r prefix


************************** WARNING **************************

Need to follow directions on http://stackoverflow.com/questions/11012821/jax-rs-custom-pathparam-validator

*********************** END WARNING *************************


Bonita Dev indicates it possible at

http://www.bonitasoft.org/forum/viewtopic.php?id=8934

Other hints

http://www.bonitasoft.org/forum/viewtopic.php?id=7434
http://www.bonitasoft.org/forum/viewtopic.php?id=6631

Public maven repos:

http://repository.ow2.org/nexus/content/repositories/releases/org/ow2/bonita/bonita-xcmis-war/5.7.1/


JAAS/SAM on GlassFish

http://epicjava.blogspot.com.au/2012/03/using-jaasjacc-on-glassfish-312-for_07.html


Custom Principal Config

http://docs.oracle.com/cd/E18930_01/html/821-2418/beacr.html


http://silviajquiroga.blogspot.com.au/2011/08/deploy-bonita-user-xp-541-on-glassfish.html
http://www.bonitasoft.org/forum/viewtopic.php?id=5524
