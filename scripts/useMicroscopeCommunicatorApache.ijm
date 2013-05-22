//Example of using microscope communicator that implements Apache
//new files in directory are recognized and passed to the macro
//output is again through Registry

//get filename from MicroscopeCommunicator
imgpath = getArgument();

  
 /**
Check if file is lsm and weather it has been generated from Autofocus Job
Typical filname is

aString_JobName_Wxxx_Pxxx_Txxx.lsm
or
JobName_Wxxx_Pxxx_Txxx.lsm

JobNames created by AutofocusMacro version >2.2  contain the strings
Autofocus: 	 	 AF_
Acquisition: 	 AQ_
AlterAcquistion: AL_
Trigger1: 	 	 TR1_
Trigger2: 	 	 TR2_
**/

if (endsWith(imgpath, "lsm") & indexOf(imgpath, "AF_" ) > 0 )
	//open file
	open(imgpath);

	//Do some analysis
	getVoxelSize(scalex, scaley,scalez,unit);
	getDimensions(nWidth,nHeight,nChannels, n, nZ);

	
	//Write results to registry for sequential mode of analysis
	//Always pass strings
	//location or Registry for VBA Macro
	locationReg = "HKCU\\SOFTWARE\\VB and VBA Program Settings\\OnlineImageAnalysis\\macro"
	// unit of measurement.
	// 	unit = "px"
	// 	unit = "um" or "µm" (this is the output of Fiji) better to use "um" less confusion 
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=unit value=["+ unit +"] windows=REG_SZ");

	// X and Y coordinate
	// convention is 0,0 top left corner Xmax,Ymax bottom right corner (as in Fiji)
	// several points can be given separated by a comma i.e. 0.1, 0.5. You need equal number of points for X and Y
	// For focusing if you pass the center of the image this will not change the position of the stage. for example coordinates passed
	X = nWidth/2*scalex; Y = nHeight/2*scaley;
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=X value=["+ X +"] windows=REG_SZ");
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=Y value=["+ X +"] windows=REG_SZ");
	
	// Z coordinate of middle slice
	// convention is 0 is bottom of stack. In pixel unit one slice is one pixel. Passing the middle slice keep the focus constant
	Z = (n-1)/2*scalez;
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=Z value=["+ Z +"] windows=REG_SZ");

	// deltaZ: number of slices, width of acquisition
	// In pixel unit this is exactly the number of slices otherwise the value will be rounded up in the macro
	// A value of -1 is no changes in the number of slices, 0 is at least one slice
	deltaZ = -1
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=deltaZ value=["+ deltaZ +"] windows=REG_SZ");

	// Pass coordinates of ROI. You can define as many Roi as wanted
	// Separate the definition of one Roi with a semicolumn. For all specification the same number of roi is recquired
	// For one Roi only
	// roiType = "rectangle", "circle", "polyline", "ellipse"
	// for two or more Roi's
	// roiType = "type1 ; type2; ..."
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=roiType value=["+ roiType +"] windows=REG_SZ");
	
	// For one Roi
	// roiAim = "acquisition", "bleach"	
	// or roiAim = "aim1; aim2; ..."
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=roiAim value=["+ roiAim +"] windows=REG_SZ");
	
	// Coordinates of roi 
	// roiX and roiY = strings containinig coordinates of roi separated by a comma. a semicolum indicates additional roi
	// 	for rectangle  roiX = "upper_left_roi1, lower_right_roi1; upper_left_roi2, lower_right_roi2 "
	//	for circle     roiX = "center, a_point_on_radius"
	//  for polyline   roiX = "point1, point2, point3" (at least 3 points otherwise you have a line)
	//  for ellipse    roiX = 	???
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=roiX value=["+ roiX +"] windows=REG_SZ");
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=roiX value=["+ roiY +"] windows=REG_SZ");

	// Name of file that has being analyzed (for log keeping, this is at the moment not used)
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=fileAnalyzed value=["+ imgpath +"] windows=REG_SZ");

	// Task to perform the code
	// code = "nothing",  don't do anything give back control to VBA macro
	// code = "wait",     stop progression of VBA macro
	// code = "focus", 	  update all or some of the coordinates such as X, Y, Z and deltaZ. Eventually create Roi's. Imaging task is not changed
	// code = "fcs", 	  get positions from X, Y and Z and perform fcs measurement
	// code = "trigger1", perform imaging specified by trigger1 at position specified by X, Y, Z (and deltaZ), eventually using roi for acquisition or bleaching
	// code = "trigger2", perform imaging specified by trigger2 at position specified by X, Y, Z (and deltaZ), eventually using roi for acquisition or bleaching
	run("Read Write Windows Registry", "action=write location=[" + locationReg + "] key=code value=["+ code +"] windows=REG_SZ");


	//Write results to file for parallel annalysis
	// filaneme is for convention aString_JobName_Wxxx_Pxxx.txt to be written in the same directory as the corresponding series of images
	// one should write 
	// command command_value
	// The file is read by the VBAmacro before repeating a job at specified position
	
