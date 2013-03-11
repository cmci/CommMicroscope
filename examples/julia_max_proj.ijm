// Read argument from MacroRunner (CommMicroscope) and does a maximal projection
// on lsm file only
filepath = getArgument();
if (endsWith(filepath,"lsm")) {
run("Bio-Formats Importer", "open=" + filepath + " autoscale color_mode=Default view=Hyperstack stack_order=XYCZT");
title = getTitle();
run("Z Project...", "start=1 stop=" + getSliceNumber() + " projection=[Max Intensity]");
close(title);
}
