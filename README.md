#Microscope Communicator

##Authors: 

Christian Tischer (ALMF, EMBL Heidelberg)

Kota Miura (CMCI, EMBL Heidelberg)

Antonio Politi (CBB, EMBL Heidelberg)

##Installation

 Create java using mvn package or download the jar file. You need a library "Apache Commons IO" (http://commons.apache.org/proper/commons-io//) as well. Place both files under plugins folder in Fiji. Refresh the menu or restart the Fiji.

Commands will be located under Plugins > ALMF >

##Descriptions

###Microscope Communicator (Outdated)

Select Microscope type, choose an action and a command to send. 

###ReadWriteWindowsRegistry

Allows to write and read from registry a specifc key

###Run a Macro on New Image

Select a folder to monitor appearance of new images (where captured images are saved). Upon appearance, A macro of your choice will be executed on that new file. Maximum interation could be set in the dialog as well.  

The file path should be retrieved in the macro by

*filepath = getArgument()*

During monitoring, a small window will be staying on your desktop. To force quit the monitoring, click stop or close button.

###Run a Jython on New Image

Similar to above, but runs Jython scripts. 

The file path to the new image will be stored in a variable called 

*newImagePath*

and can be used directly in the script. 

##Versions

###1.1.0 (20130215)
Added with Windows Registry reader/writer plugin. 

###1.0.0
The first version 







