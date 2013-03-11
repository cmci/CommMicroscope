
microscope = "File system" //"LSM780"

do {
	
run("Close all forced");

run("Microscope Communicator", "microscope=["+microscope+"] action=[obtain image] command=[do nothing] choose=W:\\To_Tischi_from_Julia\\test_centrosome_detection_Juli\\DATA\\gooood\\bsp2\\A__L1_R33.lsm");

// image analysis
 
if (selectionType() > -1) {
	run("Microscope Communicator", "microscope=["+microscope+"] action=[submit command] command=[image selected particle]");
} else {
	run("Microscope Communicator", "microscope=["+microscope+"] action=[submit command] command=[do nothing]");
}

while(1);
