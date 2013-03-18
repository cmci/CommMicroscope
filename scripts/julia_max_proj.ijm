// Read argument from MacroRunner (CommMicroscope) and does a maximal projection
// on lsm file only. Change stop (=maximal number of sclices) accoringly


filepath = getArgument();
wait(1000); 
if (endsWith(filepath,"lsm")) {
run("Bio-Formats Importer", "open=" + filepath + " autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
run("Z Project...", "start=1 stop=9 projection=[Max Intensity]");
IJ.log(File.getParent(filepath));
saveAs("Tiff", filepath + "MAX.tif");
close(File.getName(filepath));
}